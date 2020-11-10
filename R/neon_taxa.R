#' Taxanomic names of all groups
#'
#' This data frame was put together from each data product, with the extra column of `identificationReferences`.
#'
#' @note Some taxonomic groups used `taxonID` in the data product while other groups used `acceptedTaxonID`.
#' In addition, all data were from NEON and we did not do extra clean up. For example, sometimes, a species
#' does not have family information (`NA`) while another co-genera species does.
#'
#' @format A data frame with the following columns:
#'
#' - `taxonID`: Species code, based on one or more sources.
#' - `acceptedTaxonID`: Accepted species code, based on one or more sources.
#' - `scientificName`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `family`: The scientific name of the family in which the taxon is classified.
#' Not every taxonomic group has this information here.
#' - `identificationReferences`: A list of sources (concatenated and semicolon separated)
#' used to derive the specific taxon concept; including field guide editions, books,
#' or versions of NEON keys used.
#' - `taxa`: The taxa group that the location information can be used for.
#' Note that some taxa groups may have the same 'plotID' but their
#' latitude/longitude may differ slightly, which justifies the need of this column.
#' - `neonDPI`: The NEON data product ID. See `neonUtilities:::table_types` for all
#' available data types and their data product IDs provided by NEON.
#'
"neon_taxa"
