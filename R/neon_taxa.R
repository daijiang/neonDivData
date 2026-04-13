#' Taxonomic names of all groups
#'
#' This data frame was assembled from all taxonomic data products in the package.
#' It is updated each release by `data-raw/02_clean_save_data.R` and preserves
#' taxa from previous releases so that names are not lost between NEON data versions.
#'
#' @note NEON source tables use either `taxonID` or `acceptedTaxonID` depending on
#' the data product. Both are standardized to `taxon_id` here.
#'
#' @format A data frame with the following columns:
#'
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`: Scientific name associated with the taxon ID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `taxon_group`: The taxonomic group the taxon belongs to (e.g. `"ALGAE"`, `"BEETLES"`).
#'
"neon_taxa"
