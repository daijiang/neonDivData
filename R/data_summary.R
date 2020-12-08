#' Data product last modification time
#'
#' This data frame records the last modify time for each data product in this package.
#'
#' @format A data frame with the following columns:
#' - `taxa`: The taxa group that the location information can be used for.
#' Note that some taxa groups may have the same 'plotID' but their
#' latitude/longitude may differ slightly, which justifies the need of this column.
#' - `neon_DPI`: The NEON data product ID. See `neonUtilities:::table_types` for all
#' available data types and their data product IDs provided by NEON.
#' - `data_product`: The name of corresponding data products for each taxonomic group.
#' - `n_site`: Number of NEON sites included.
#' - `n_species`: Number of species included. Note that we did not clean species anmes though
#' we did remove records with species identified above genus level for well studied groups such as
#' plant and fish. However, we keep all records regardless of their species identification levels
#' for taxonomic groups that are hard to identifiy (e.g. macroinvertebrate, beetle).
#' - `start_year`: The earliest year that have records.
#' - `end_year`: The latest year that have records.
#' - `modify_time`: The last modification time.
#'
"data_summary"
