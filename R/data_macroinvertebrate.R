#' Macroinvertebrate data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20120.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20120.001>.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`.
#' - `unit`: Unit of the values in the `value` column.
#' - `subsamplePercent`: Percent of the total sample contained in the subsample.
#' - `release`: Version of data release by NEON.
#' - `benthicArea`: Area sampled (square meter).
#' - `habitatType`: Habitat type sampled.
#' - `samplerType`: Type of sampler used to collect the sample.
#' - `substratumSizeClass`: Size class of the substratum sampled.
#' - `neon_sample_id`: NEON sample ID.
#' - `remarks`: Remarks of record.
#' - `ponarDepth`: Depth of petite ponar sample.
#' - `snagLength`: Length of snag sampled.
#' - `snagDiameter`: Diameter of snag sampled.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Stephanie Parker, Eric Sokol
#'
"data_macroinvertebrate"
