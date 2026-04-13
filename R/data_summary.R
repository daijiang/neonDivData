#' Summary of NEON data products included in this package
#'
#' One row per taxonomic group. Computed directly from the cleaned datasets
#' by `data-raw/02_clean_save_data.R`.
#'
#' @format A data frame with the following columns:
#' - `taxon_group`: Taxonomic group name (e.g. `"ALGAE"`, `"BEETLES"`).
#' - `neon_product_id`: NEON data product ID (e.g. `"DP1.20166.001"`).
#' - `r_object`: Name of the R data object for this group (e.g. `"data_algae"`).
#' - `n_taxa`: Number of unique taxa included.
#' - `n_sites`: Number of NEON sites with data.
#' - `sites`: All site codes that have data, separated by `|`.
#' - `start_date`: The earliest observation date in the dataset.
#' - `end_date`: The latest observation date in the dataset.
#' - `variable_names`: The variable name(s) in the `value` column.
#' - `units`: The unit(s) of the `value` column.
#'
"data_summary"
