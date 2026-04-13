# 02_clean_save_data.R
#
# Read raw NEON data from data-raw/NEON_raw_data/, clean each taxon with the
# corresponding clean_neon_*() function, apply any additional post-processing
# inherited from the legacy pipeline, and save all datasets as package data
# via usethis::use_data().
#
# Run from the package root (e.g., via devtools::load_all() or interactively).

library(tidyverse)
library(usethis)

source("data-raw/00_taxon_clean.R")

#' Clean NEON Data (Dispatcher)
#'
#' @param neon_data_list List of raw NEON tables
#' @param taxon Character string of the taxon group
#'
clean_neon_data <- function(neon_data_list, taxon) {
    clean_functions <- list(
        algae = clean_neon_algae,
        beetle = clean_neon_beetle,
        bird = clean_neon_bird,
        macroinvertebrate = clean_neon_macroinvertebrate,
        mosquito = clean_neon_mosquito,
        plant = clean_neon_plant,
        small_mammal = clean_neon_small_mammal,
        tick = clean_neon_tick,
        tick_pathogen = clean_neon_tick_pathogen,
        zooplankton = clean_neon_zooplankton
    )

    if (!taxon %in% names(clean_functions)) {
        stop(paste("Taxon", taxon, "is not yet supported."))
    }

    # Dispatch to the specific cleaning function
    res <- clean_functions[[taxon]](neon_data_list)
    return(res)
}

# =============================================================================
# 1. Read raw data and clean
# =============================================================================

raw_dir <- "data-raw/NEON_raw_data/"

# Return the most recent RDS file for a given taxon prefix.
# Files are named <prefix>_<dpID>_<YYYYMMDD>.RDS so alphabetical sort gives latest.
latest_rds <- function(prefix, dir = raw_dir) {
    files <- list.files(dir,
        pattern = paste0("^", prefix, "_DP.*\\.RDS$"),
        full.names = TRUE
    )
    if (!length(files)) stop("No RDS file found for prefix: ", prefix)
    sort(files, decreasing = TRUE)[[1]]
}

taxon_names <- c(
    "algae", "beetle", "bird", "macroinvertebrate", "mosquito",
    "plant", "small_mammal", "tick", "tick_pathogen", "zooplankton"
)

# Read, dispatch to clean_neon_data(), store results
cleaned <- setNames(vector("list", length(taxon_names)), taxon_names)

for (taxon in taxon_names) {
    f <- latest_rds(taxon)
    message("--- Reading ", basename(f), " ---")
    raw <- readRDS(f)
    message("--- Cleaning ", taxon, " ---")
    cleaned[[taxon]] <- clean_neon_data(raw, taxon)
    rm(raw)
    gc()
    message("    ", format(nrow(cleaned[[taxon]]), big.mark = ","), " rows\n")
}

# Unpack into individual named objects (required by usethis::use_data())
data_algae <- cleaned$algae
data_beetle <- cleaned$beetle
data_bird <- cleaned$bird
data_macroinvertebrate <- cleaned$macroinvertebrate
data_mosquito <- cleaned$mosquito
data_plant <- cleaned$plant
data_small_mammal <- cleaned$small_mammal
data_tick <- cleaned$tick
data_tick_pathogen <- cleaned$tick_pathogen
data_zooplankton <- cleaned$zooplankton


# =============================================================================
# 2. Post-processing (legacy steps from 02_data_to_neonDivData.R)
# =============================================================================

# Macroinvertebrate: ponarDepth / snagLength / snagDiameter arrive as character
# from NEON's raw tables and are not coerced inside clean_neon_macroinvertebrate().
data_macroinvertebrate <- data_macroinvertebrate |>
    mutate(
        ponarDepth   = as.numeric(ponarDepth),
        snagLength   = as.numeric(snagLength),
        snagDiameter = as.numeric(snagDiameter)
    )

### Decided to keep non-finite values in the cleaned datasets for now to keep sampling effort.
# # Drop non-finite values from all taxa except plant.
# # For plant, NA in value = presence/absence record (not a missing count), so we
# # keep those rows intentionally.
# data_algae             <- filter(data_algae,             is.finite(value))
# data_beetle            <- filter(data_beetle,            is.finite(value))
# data_bird              <- filter(data_bird,              is.finite(value))
# data_macroinvertebrate <- filter(data_macroinvertebrate, is.finite(value))
# data_mosquito          <- filter(data_mosquito,          is.finite(value))
# data_small_mammal      <- filter(data_small_mammal,      is.finite(value))
# data_tick              <- filter(data_tick,              is.finite(value))
# data_tick_pathogen     <- filter(data_tick_pathogen,     is.finite(value))
# data_zooplankton       <- filter(data_zooplankton,       is.finite(value))

# =============================================================================
# 3. neon_taxa
# Build from all cleaned datasets; preserve taxa from previous release so
# taxa that disappear between NEON releases are not lost.
# =============================================================================

taxon_group_map <- c(
    algae             = "ALGAE",
    beetle            = "BEETLES",
    bird              = "BIRDS",
    macroinvertebrate = "MACROINVERTEBRATES",
    mosquito          = "MOSQUITOES",
    plant             = "PLANTS",
    small_mammal      = "SMALL_MAMMALS",
    tick              = "TICKS",
    tick_pathogen     = "TICK_PATHOGENS",
    zooplankton       = "ZOOPLANKTON"
)

neon_taxa <- mapply(
    function(dat, grp) {
        distinct(select(dat, any_of(c("taxon_id", "taxon_name", "taxon_rank")))) |>
            mutate(taxon_group = grp)
    },
    cleaned, taxon_group_map,
    SIMPLIFY = FALSE
) |>
    bind_rows() |>
    distinct() |>
    bind_rows(neonDivData::neon_taxa) |> # preserve taxa from previous release
    distinct() |>
    arrange(taxon_group, taxon_id)

if (FALSE) {
    # Sanity check: compare old vs new taxon counts per group
    neonDivData::neon_taxa |>
        group_by(taxon_group) |>
        summarize(n_taxa = n_distinct(taxon_id), .groups = "drop")
    neon_taxa |>
        group_by(taxon_group) |>
        summarize(n_taxa = n_distinct(taxon_id), .groups = "drop")
}

use_data(neon_taxa, overwrite = TRUE)

# =============================================================================
# 4. neon_location
# Build from all cleaned datasets; preserve locations from previous release.
# =============================================================================

loc_vars <- c(
    "location_id", "siteID", "plotID",
    "latitude", "longitude", "elevation",
    "nlcdClass", "aquaticSiteType"
)

neon_location <- lapply(cleaned, function(dat) {
    distinct(select(dat, any_of(loc_vars)))
}) |>
    bind_rows() |>
    distinct() |>
    group_by(location_id) |>
    slice_head(n = 1) |>
    ungroup() |>
    bind_rows(neonDivData::neon_location) |> # preserve locations from previous release
    distinct() |>
    group_by(location_id) |>
    slice_head(n = 1) |>
    ungroup() |>
    select(location_id, siteID, plotID, latitude, longitude, elevation, nlcdClass, aquaticSiteType) |>
    arrange(siteID, plotID, location_id)

use_data(neon_location, overwrite = TRUE)

# =============================================================================
# 5. data_summary
# One row per taxon group; computed directly from the cleaned data.
# =============================================================================

neon_product_ids <- c(
    algae             = "DP1.20166.001",
    beetle            = "DP1.10022.001",
    bird              = "DP1.10003.001",
    macroinvertebrate = "DP1.20120.001",
    mosquito          = "DP1.10043.001",
    plant             = "DP1.10058.001",
    small_mammal      = "DP1.10072.001",
    tick              = "DP1.10093.001",
    tick_pathogen     = "DP1.10092.001",
    zooplankton       = "DP1.20219.001"
)

data_summary <- mapply(
    function(dat, taxon, dpid, grp) {
        tibble::tibble(
            taxon_group = grp,
            neon_product_id = dpid,
            r_object = paste0("data_", taxon),
            n_taxa = n_distinct(dat$taxon_id, na.rm = TRUE),
            n_sites = n_distinct(dat$siteID, na.rm = TRUE),
            sites = paste(sort(unique(na.omit(dat$siteID))), collapse = "|"),
            start_date = tryCatch(
                as.Date(min(dat$observation_datetime, na.rm = TRUE)),
                error = function(e) NA_character_
            ),
            end_date = tryCatch(
                as.Date(max(dat$observation_datetime, na.rm = TRUE)),
                error = function(e) NA_character_
            ),
            variable_names = paste(unique(na.omit(dat$variable_name)), collapse = " OR "),
            units = paste(unique(na.omit(dat$unit)), collapse = " OR ")
        )
    },
    cleaned, names(cleaned), neon_product_ids, taxon_group_map,
    SIMPLIFY = FALSE
) |>
    bind_rows()

data_summary <- select(
    data_summary, taxon_group, neon_product_id, r_object, n_taxa,
    n_sites, start_date, end_date, variable_names, units, sites, everything()
)
use_data(data_summary, overwrite = TRUE)

# =============================================================================
# 6. Save observation datasets
# =============================================================================

message("Saving observation datasets...")
use_data(data_algae, overwrite = TRUE)
use_data(data_beetle, overwrite = TRUE)
use_data(data_bird, overwrite = TRUE)
use_data(data_macroinvertebrate, overwrite = TRUE)
use_data(data_mosquito, overwrite = TRUE)
use_data(data_plant, overwrite = TRUE)
use_data(data_small_mammal, overwrite = TRUE)
use_data(data_tick, overwrite = TRUE)
use_data(data_tick_pathogen, overwrite = TRUE)
use_data(data_zooplankton, overwrite = TRUE)

message("All done. Run devtools::document() to sync Rd files if needed.")
