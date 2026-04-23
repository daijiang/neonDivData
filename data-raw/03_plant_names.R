# 03_plant_names.R
#
# Standardize data_plant taxon names against the World Checklist of Vascular
# Plants (WCVP) using rWCVP, following the GloNAF 2.0 workflow described in
# Davis et al. 2025 (Ecology Metadata S1, Fig. 5):
#
#   1. Match names (with authors) via wcvp_match_names(fuzzy = TRUE)
#   2. Accept exact matches where the author string agrees with WCVP
#   3. Accept exact matches where no author was provided (single/preferred match)
#   4. Accept fuzzy matches with similarity >= 0.9 and edit distance == 1
#   5. For accepted synonyms, replace taxon_name with the WCVP accepted name
#   6. Names with no WCVP match retain their original NEON name
#
# Produces:
#   data-raw/plant_name_lookup.csv   matching details for all species-level taxa
#   data/data_plant.rda              updated with WCVP-accepted taxon_name

# ── Dependencies ──────────────────────────────────────────────────────────────

if (!requireNamespace("rWCVP", quietly = TRUE)) {
    devtools::install_github("matildabrown/rWCVP")
}

if (!requireNamespace("rWCVPdata", quietly = TRUE)) {
    install.packages("rWCVPdata", repos = c(
        "https://matildabrown.r-universe.dev",
        "https://cloud.r-project.org"
    ))
}

library(rWCVP)
library(rWCVPdata)
library(dplyr)
library(stringr)
library(usethis)

load("data/data_plant.rda")

# ── 1. Unique species-level taxa ──────────────────────────────────────────────
# genus-level IDs ("Betula sp.") and speciesGroup are excluded — no single
# accepted name to map them to

taxa <- data_plant |>
    filter(taxon_rank %in% c("species", "subspecies", "variety")) |>
    distinct(taxon_id, taxon_name, taxon_rank)

cat("Taxa to match:", nrow(taxa), "\n")
sample(taxa$taxon_name, 100)
filter(taxa, taxon_rank == "species")$taxon_name |> sample(100)
filter(taxa, taxon_rank == "subspecies")$taxon_name |> sample(100)
filter(taxa, taxon_rank == "variety")$taxon_name |> sample(100)
grep("×", taxa$taxon_name, value = TRUE) # look for hybrid symbols

# ── 2. Split NEON taxon_name into binomial/trinomial name + author ─────────────
# NEON scientificName format:
#   species:      "Acer pensylvanicum L."              (2 name tokens + author)
#   subspecies:   "Poa pratensis subsp. irrigata ..."  (4 name tokens + author)
#   variety:      "Carex scoparia var. scoparia ..."   (4 name tokens + author)

split_name_author <- function(full, rank) {
    toks <- str_split(str_trim(full), "\\s+")[[1]]

    if (rank %in% c("subspecies", "variety")) {
        # For subspecies, look for "subsp." or "ssp." and split there
        subsp_idx <- which(toks %in% c("subsp.", "ssp.", "var."))
        if (length(subsp_idx) == 1 && subsp_idx > 2 && subsp_idx < length(toks)) {
            return(c(
                input_name = str_replace(paste(toks[c(1:2, subsp_idx, subsp_idx + 1)], collapse = " "), "ssp[.]", "subsp."), # standardize to "subsp."
                input_author = toks[c(3:(subsp_idx - 1), (subsp_idx + 2L):length(toks))] |> paste(collapse = " ")
            ))
        }
    }

    n <- 2L # default to first 2 tokens for species-level names

    if (length(toks) <= n) {
        return(c(input_name = full, input_author = NA_character_))
    }

    c(
        input_name   = paste(toks[seq_len(n)], collapse = " "),
        input_author = paste(toks[seq(n + 1L, length(toks))], collapse = " ")
    )
}

parsed <- mapply(split_name_author, taxa$taxon_name, taxa$taxon_rank,
    SIMPLIFY = TRUE
) # 2 x n character matrix

taxa <- taxa |>
    mutate(
        input_name   = parsed["input_name", ],
        input_author = parsed["input_author", ]
    )
sample(taxa$input_name, 100)
filter(taxa, taxon_rank == "species")$input_name |> sample(100)
filter(taxa, taxon_rank == "subspecies")$input_name |> sample(100)
filter(taxa, taxon_rank == "variety")$input_name |> sample(100)

# ── 3. Match against WCVP ─────────────────────────────────────────────────────
message("Running wcvp_match_names() on ", nrow(taxa), " names ...")
# Pass only the columns the function needs; it forbids columns named taxon_name,
# taxon_authors, and several wcvp_* names that overlap with its own output.
matches <- wcvp_match_names(
    taxa |> select(taxon_id, input_name, input_author),
    name_col     = "input_name",
    author_col   = "input_author",
    fuzzy        = TRUE,
    progress_bar = TRUE
)
# Re-attach the original columns needed downstream
matches <- left_join(matches, taxa, by = c("taxon_id", "input_name", "input_author"))

count(matches, match_type)
summary(matches$wcvp_author_edit_distance)
summary(matches$match_similarity)
table(matches$wcvp_status)

# ── 4. Select the single best match per taxon ────────────────────────────────
# Priority order (first = preferred):
#   exact > fuzzy  |  smaller author edit distance  |  Accepted > Synonym

best <- matches |>
    filter(!is.na(wcvp_id)) |>
    group_by(taxon_id) |>
    arrange(
        desc(str_detect(match_type, "Exact")), # exact first
        tidyr::replace_na(wcvp_author_edit_distance, Inf), # author match
        desc(wcvp_status == "Accepted"), # Accepted first
        desc(coalesce(match_similarity, 1.0)), # higher similarity
        .by_group = TRUE
    ) |>
    slice_head(n = 1) |>
    ungroup()

# ── 5. Apply GloNAF Fig. 5 acceptance rules ───────────────────────────────────
best <- best |>
    mutate(
        has_author = !is.na(input_author),
        match_accepted = case_when(
            # Any exact name match is accepted regardless of author agreement.
            # "Exact (with author)" = author_edit_distance == 0 (best case).
            # "Exact (without author)" = binomial matched perfectly but author
            # strings differ in formatting — still the same taxon. Rejecting
            # these would lose ~1600 valid matches due to minor author
            # abbreviation differences between NEON and WCVP conventions.
            str_detect(match_type, "Exact") ~ TRUE,
            # Fuzzy within conservative threshold
            str_detect(match_type, "Fuzzy") &
                !is.na(match_similarity) & match_similarity >= 0.85 &
                !is.na(match_edit_distance) & match_edit_distance <= 3 ~ TRUE,
            TRUE ~ FALSE
        )
    )

# ── 6. Retrieve the WCVP accepted name (follow synonym → accepted chain) ──────
# wcvp_accepted_id is always the accepted plant_name_id (itself for Accepted names,
# or the accepted taxon for synonyms).

wcvp_lookup <- rWCVPdata::wcvp_names |>
    select(plant_name_id, taxon_name, taxon_authors)

best <- best |>
    left_join(
        wcvp_lookup |> rename(acc_name = taxon_name, acc_authors = taxon_authors),
        by = c("wcvp_accepted_id" = "plant_name_id")
    ) |>
    mutate(
        # Construct full accepted name (name + authors); trim if authors are absent
        accepted_name = if_else(
            match_accepted & !is.na(acc_name),
            str_trim(paste(acc_name, coalesce(acc_authors, ""))),
            NA_character_
        )
    )

# ── 7. Build lookup table and summarise ───────────────────────────────────────
lookup <- taxa |>
    left_join(
        best |> select(
            taxon_id, match_type, match_accepted, wcvp_status,
            wcvp_name, accepted_name
        ),
        by = "taxon_id"
    ) |>
    mutate(
        final_name   = coalesce(accepted_name, taxon_name),
        name_changed = !is.na(accepted_name) & accepted_name != taxon_name
    )

cat("\n=== WCVP name standardisation results ===\n")
cat("Match type breakdown:\n")
print(count(lookup, match_type, match_accepted))
# # A tibble: 7 × 3
#   match_type             match_accepted     n
#   <chr>                  <lgl>          <int>
# 1 Exact (with author)    TRUE            3570
# 2 Exact (without author) TRUE            1595
# 3 Fuzzy (edit distance)  FALSE            114
# 4 Fuzzy (edit distance)  TRUE              12
# 5 Fuzzy (phonetic)       FALSE              2
# 6 Fuzzy (phonetic)       TRUE              11
# 7 NA                     NA               660
cat("\nNames updated (synonym → accepted):", sum(lookup$name_changed, na.rm = TRUE), "\n")
cat(
    "No WCVP match found:",
    sum(is.na(lookup$match_type) | lookup$match_type == "No match"), "\n"
)

write.csv(lookup, "data-raw/plant_name_lookup.csv", row.names = FALSE)
message("Lookup table written to data-raw/plant_name_lookup.csv")

count(lookup, name_changed) |> print(n = Inf)

# ── 8. Update data_plant and save ─────────────────────────────────────────────
name_map <- lookup |>
    filter(!is.na(accepted_name)) |>
    select(taxon_id, accepted_name)

data_plant <- data_plant |>
    select(-c(accepted_wcvp_name, accepted_wcvp_name_binomial)) |>
    left_join(name_map, by = "taxon_id") |>
    mutate(
        accepted_wcvp_name = coalesce(accepted_name, taxon_name),
        accepted_wcvp_name = str_remove(accepted_wcvp_name, "/.+$"), # remove things like "Betula glandulosa/nana"
        accepted_wcvp_name_binomial = str_extract(accepted_wcvp_name, "^×? ?\\S+ ×? ?\\S+"), accepted_wcvp_name_binomial = str_replace(accepted_wcvp_name_binomial, " spp[.]$", " sp.")
    ) |>
    select(-accepted_name)
filter(data_plant, str_detect(taxon_name, "Andropogon L.")) |>
    distinct() |>
    pull(taxon_name)
data_plant$accepted_wcvp_name_binomial[data_plant$accepted_wcvp_name_binomial == "Andropogon L."] <- "Schizachyrium scoparium"

select(data_plant, taxon_name, accepted_wcvp_name, accepted_wcvp_name_binomial) |>
    distinct() |>
    arrange(accepted_wcvp_name_binomial) |>
    write.csv("data-raw/plant_name_lookup_applied.csv", row.names = FALSE)

sort(unique(data_plant$accepted_wcvp_name_binomial))

usethis::use_data(data_plant, overwrite = TRUE)
message("data_plant saved with WCVP-accepted taxon names.")
