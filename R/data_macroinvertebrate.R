#' Macroinvertebrate data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20120.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20120.001>.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `siteID`: NEON site code.
#' - `sampleID`: Identifier for sample.
#' - `namedLocation`:	Name of the measurement location in the NEON database.
#' - `collectDate`: Date of the collection event.
#' - `scientificName`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxonID`: Accepted species code, based on one or more sources. This is renamed from the `acceptedTaxonID` column so that column names are consistent across different taxonomic groups.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `subsamplePercent`: Percent of the total sample contained in the subsample.
#' - `individualCount`:	Number of individuals of the same type.
#' - `estimatedTotalCount`: Estimated total count of individuals within a sample,
#' of given taxon, life stage, and size class.
#' - `benthicArea`: Area sampled (square meter).
#' - `density`: Number of macroinvertebrates per square meter.
#'
#' @author Stephanie Parker, Eric Sokol
#'
"data_macroinvertebrate"
