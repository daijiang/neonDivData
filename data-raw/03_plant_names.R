# 03_plant_names.R
#
# Standardize data_plant taxon names against the World Checklist of Vascular
# Plants (WCVP) by joining against the shared plant name base
# (species_name_standardization project), instead of re-matching with rWCVP here.
#
# The name base standardizes raw names (authorship included) against WCVP via
# rWCVP. Join on the RAW name (sp_original = NEON taxon_name, with authors), never
# on the canonical name: the same canonical name can resolve to different accepted
# taxa depending on its author (homonyms).
#
# Location of the name base: set SP_NAME_BASE, e.g. in ~/.Renviron. Defaults to
# the copy on bot211.botany.wisc.edu.
#
# Produces:
#   data-raw/plant_name_lookup.csv           NEON plant taxa x name base (audit trail);
#                                            in_name_base = FALSE lists names to add
#                                            as a source to the name base
#   data-raw/plant_name_lookup_applied.csv   before/after name table
#   data/data_plant.rda                      with accepted_wcvp_name,
#                                            accepted_wcvp_name_binomial,
#                                            species_group_assigned

library(dplyr)
library(stringr)
library(usethis)

name_base_file <- Sys.getenv(
    "SP_NAME_BASE",
    "/media/dli/Data/common_data/species_name_standardization/data_output/sp_names_all.rds"
)
if (!file.exists(name_base_file)) {
    stop("Plant name base not found at ", name_base_file,
        ".\n  Copy sp_names_all.rds locally and set SP_NAME_BASE to its path.",
        call. = FALSE
    )
}

nb <- readRDS(name_base_file)
wcvp_version <- attr(nb, "wcvp_version") # read before dplyr verbs drop it
message("Name base: ", nrow(nb), " names; WCVP ", wcvp_version)

load("data/data_plant.rda")

# ── 1. Species-level NEON taxa ────────────────────────────────────────────────
# genus-level IDs ("Betula sp.") keep their NEON name; speciesGroup taxa are
# handled in step 8b
taxa <- data_plant |>
    filter(taxon_rank %in% c("species", "subspecies", "variety")) |>
    distinct(taxon_id, taxon_name, taxon_rank)

# ── 2. Join on the raw name (sp_original) ─────────────────────────────────────
lookup <- taxa |>
    left_join(
        select(
            nb, sp_original, sp_clean, sp_author, accepted_taxon_name,
            accepted_wcvp_name_binomial, wcvp_taxon_rank = taxon_rank, taxon_status,
            match_name, match_status, match_way, resolved_match_type,
            accepted_plant_name_id, ipni_id
        ),
        by = c("taxon_name" = "sp_original")
    ) |>
    mutate(
        in_name_base = !is.na(match_way),
        wcvp_version = wcvp_version
    )

cat("Species-level NEON taxa:", nrow(lookup), "\n")
cat("  in name base:", sum(lookup$in_name_base), "\n")
cat("  with an accepted WCVP name:", sum(!is.na(lookup$accepted_taxon_name)), "\n")
cat("  missing from name base (add neonDivData as a source):", sum(!lookup$in_name_base), "\n")
print(count(lookup, match_way))

write.csv(lookup, "data-raw/plant_name_lookup.csv", row.names = FALSE)
message("Lookup table written to data-raw/plant_name_lookup.csv")

# ── 8. Update data_plant ─────────────────────────────────────────────────────
# accepted_wcvp_name: the accepted WCVP name; names without one (not in the name
# base, no match, or deliberately left unresolved there) keep their NEON name,
# except autonyms ("Polygonum scandens L. var. scandens"), which are the species
# itself and take the species' accepted name.
#
# accepted_wcvp_name_binomial, in order of preference:
#   1. the accepted binomial from the name base. Like the name base, this keeps
#      section aggregates: WCVP holds "Taraxacum sect. Taraxacum" as the accepted
#      name of Taraxacum officinale, and that is its binomial too;
#   2. for subspecies/varieties without one, the accepted binomial of their NEON
#      species, so a species is never split between its accepted name and its
#      old NEON name (e.g. "Fallopia scandens" vs "Polygonum scandens");
#   3. the NEON binomial.
# Genus + epithet (hybrid sign allowed), or a section aggregate
binomial_pattern <- "^×? ?[A-Z][^ ]* (×? ?[a-zà-öø-ÿ][a-zà-öø-ÿ-]*|sect\\. [A-Z][a-z-]+)$"

neon_binomial <- function(x) {
    b <- str_replace(str_extract(x, "^×? ?\\S+ ×? ?\\S+"), " spp[.]$", " sp.")
    coalesce(b, x) # one-word names, e.g. "×Triticosecale"
}

# accepted name / binomial of each NEON species (most common if a binomial has
# several NEON spellings or authors)
species_res <- lookup |>
    filter(taxon_rank == "species", !is.na(accepted_taxon_name)) |>
    mutate(binom = word(taxon_name, 1, 2)) |>
    count(binom, sp_name = accepted_taxon_name, sp_binomial = accepted_wcvp_name_binomial) |>
    group_by(binom) |>
    slice_max(n, n = 1, with_ties = FALSE) |>
    ungroup() |>
    select(-n)

name_map <- lookup |>
    mutate(
        binom = word(taxon_name, 1, 2),
        infra_epithet = str_match(taxon_name, " (?:var|ssp|subsp)\\. ([a-z-]+)")[, 2],
        autonym = taxon_rank != "species" & infra_epithet %in% word(taxon_name, 2)
    ) |>
    left_join(species_res, by = "binom") |>
    mutate(
        # defensive: never take a base "binomial" of another shape
        base_binomial = if_else(
            str_detect(accepted_wcvp_name_binomial, binomial_pattern) %in% TRUE,
            accepted_wcvp_name_binomial, NA_character_
        ),
        sp_binomial = if_else(str_detect(sp_binomial, binomial_pattern) %in% TRUE, sp_binomial, NA_character_),
        accepted_name = coalesce(accepted_taxon_name, if_else(autonym, sp_name, NA_character_)),
        accepted_binomial = coalesce(
            base_binomial,
            if_else(taxon_rank != "species" & is.na(accepted_taxon_name), sp_binomial, NA_character_)
        )
    ) |>
    select(taxon_id, accepted_name, accepted_binomial)

data_plant <- data_plant |>
    select(-any_of(c("accepted_wcvp_name", "accepted_wcvp_name_binomial", "species_group_assigned"))) |>
    left_join(name_map, by = "taxon_id") |>
    mutate(
        accepted_wcvp_name = coalesce(accepted_name, taxon_name),
        accepted_wcvp_name_binomial = coalesce(accepted_binomial, neon_binomial(taxon_name))
    ) |>
    select(-accepted_name, -accepted_binomial)

# ── 8b. Assign speciesGroup taxa to one member species ───────────────────────
# NEON speciesGroup taxa (e.g. "Fraxinus americana/pennsylvanica") are groups of
# species that observers could not tell apart. To keep these records usable, each
# is assigned to one member:
#   - the first-listed member by default;
#   - if the first-listed member is not recorded (as a species) at the same site,
#     the first later-listed member that is;
#   - parts that are not binomials (e.g. "Andropogon L." in
#     "Andropogon L./Schizachyrium scoparium") are never assigned.
# The assigned member is mapped to its WCVP-accepted name when that species also
# occurs elsewhere in data_plant. Assigned records are flagged with
# species_group_assigned = TRUE; the original NEON name stays in taxon_name.

# one row per listed member; a part starting with a lowercase epithet takes the
# genus of the previous part ("Fraxinus americana/pennsylvanica")
sg_members <- data_plant |>
    filter(taxon_rank %in% "speciesGroup") |>
    distinct(taxon_id, taxon_name) |>
    mutate(part = str_split(taxon_name, "/")) |>
    tidyr::unnest(part) |>
    mutate(part = str_trim(part)) |>
    group_by(taxon_id) |>
    mutate(
        position = row_number(),
        genus = if_else(str_detect(part, "^[A-Z]"), word(part, 1), NA_character_)
    ) |>
    tidyr::fill(genus) |>
    ungroup() |>
    mutate(
        epithet = if_else(str_detect(part, "^[A-Z]"), word(part, 2), word(part, 1)),
        member = if_else(str_detect(epithet, "^[a-z-]+$"), paste(genus, epithet), NA_character_)
    ) |>
    filter(!is.na(member)) |>
    select(taxon_id, position, member)

# NEON binomial -> WCVP-accepted names, from species-level records
species_map <- data_plant |>
    filter(taxon_rank %in% c("species", "subspecies", "variety")) |>
    mutate(binom = word(taxon_name, 1, 2)) |>
    count(binom, accepted_wcvp_name, accepted_wcvp_name_binomial) |>
    group_by(binom) |>
    slice_max(n, n = 1, with_ties = FALSE) |>
    ungroup() |>
    select(binom, map_name = accepted_wcvp_name, map_binomial = accepted_wcvp_name_binomial)

site_species <- data_plant |>
    filter(taxon_rank %in% c("species", "subspecies", "variety")) |>
    distinct(siteID, binom = word(taxon_name, 1, 2)) |>
    mutate(at_site = TRUE)

sg_assigned <- data_plant |>
    filter(taxon_rank %in% "speciesGroup") |>
    distinct(siteID, taxon_id) |>
    inner_join(sg_members, by = "taxon_id", relationship = "many-to-many") |>
    left_join(site_species, by = c("siteID", "member" = "binom")) |>
    group_by(siteID, taxon_id) |>
    # first-listed member if recorded at the site (or if no member is);
    # otherwise the first listed member that is recorded at the site
    arrange(position, .by_group = TRUE) |>
    summarise(
        assigned = if (isTRUE(at_site[1]) || !any(at_site %in% TRUE)) member[1] else member[at_site %in% TRUE][1],
        .groups = "drop"
    ) |>
    left_join(species_map, by = c("assigned" = "binom")) |>
    transmute(
        siteID, taxon_id,
        sg_name = coalesce(map_name, assigned),
        sg_binomial = coalesce(map_binomial, assigned)
    )

cat("speciesGroup assignments (site x group):\n")
print(count(sg_assigned, sg_binomial, sort = TRUE), n = Inf)

data_plant <- data_plant |>
    left_join(sg_assigned, by = c("siteID", "taxon_id")) |>
    mutate(
        species_group_assigned = taxon_rank %in% "speciesGroup",
        accepted_wcvp_name = if_else(species_group_assigned, coalesce(sg_name, taxon_name), accepted_wcvp_name),
        accepted_wcvp_name_binomial = if_else(species_group_assigned, coalesce(sg_binomial, taxon_name), accepted_wcvp_name_binomial)
    ) |>
    select(-sg_name, -sg_binomial)

select(data_plant, taxon_name, accepted_wcvp_name, accepted_wcvp_name_binomial) |>
    distinct() |>
    arrange(accepted_wcvp_name_binomial) |>
    write.csv("data-raw/plant_name_lookup_applied.csv", row.names = FALSE)

sort(unique(data_plant$accepted_wcvp_name_binomial)) |> length()

usethis::use_data(data_plant, overwrite = TRUE)
message("data_plant saved with WCVP-accepted taxon names.")
