# Download all NEON taxon data products and save as timestamped RDS files.
# Excludes fish (DP1.20107.001) and herp bycatch (DP1.10022.001 bycatch table).
# Requires NEON_TOKEN environment variable to be set.

neon_products <- c(
    mosquito          = "DP1.10043.001",
    algae             = "DP1.20166.001",
    small_mammal      = "DP1.10072.001",
    plant             = "DP1.10058.001",
    beetle            = "DP1.10022.001",
    macroinvertebrate = "DP1.20120.001",
    bird              = "DP1.10003.001",
    tick              = "DP1.10093.001",
    tick_pathogen     = "DP1.10092.001",
    zooplankton       = "DP1.20219.001"
)
# Define batch timestamp once so all files share the same "version ID"
now <- format(Sys.time(), "%Y%m%d")
out_dir <- "./data-raw/NEON_raw_data/"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

for (taxon in names(neon_products)) {
    dpID <- neon_products[[taxon]]

    message("--- Downloading ", taxon, " (", dpID, ") ---")

    dat <- neonUtilities::loadByProduct(
        dpID = dpID,
        site = "all",
        check.size = FALSE,
        package = "expanded",
        include.provisional = FALSE,
        token = Sys.getenv("NEON_TOKEN")
    )

    file_n <- paste0(out_dir, taxon, "_", dpID, "_", now, ".RDS")
    saveRDS(dat, file = file_n)

    # Crucial for memory management with large NEON datasets
    rm(dat)
    # gc()

    message("Successfully saved: ", file_n)
}
