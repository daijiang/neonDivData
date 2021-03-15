#' Taxanomic names of all groups
#'
#' This data frame was put together from each data product.
#'
#' @note Some taxonomic groups used `taxonID` (renamed as `taxon_id` here) in the data product while other groups used `acceptedTaxonID`. In addition, all data were from NEON and we did not do extra clean up.
#'
#' @format A data frame with the following columns:
#'
#' - `taxon_id`: Species code, based on one or more sources. For algae, macroinvertebrate, and tick, this is from the `acceptedTaxonID` column (which was removed here) so that all taxonomic groups have the same variable name. In another word, algae, macroinvertebrate, and tick only have `acceptedTaxonID` and we just renamed it to `taxon_id` for these groups following other groups.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `taxon_group`: The taxonomic group that the location information can be used for.
#' Note that some taxa groups may have the same 'plotID' but their
#' latitude/longitude may differ slightly, which justifies the need of this column.
#'
"neon_taxa"
