#' Zooplankton density data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20219.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20219.001>. Zooplankton are collected from the water column of lakes near NEON sensor infrastructure. The type of sampler used depends on the depth of water at the sampling location. Multiple tows or traps are collected at each location and composited into a single sample. Zooplankton sampling is quantitative and based on the volume of water collected during sampling.
#'
#' Here, we:
#' - Only keep those with `sampleCondition` to be "condition OK" for the `zoo_taxonomyProcessed` table.
#' - Combined the `zoo_fieldData` and the `zoo_taxonomyProcessed`.
#' - Calculated zooplankton density as the ratio of `adjCountPerBottle` and `towsTrapsVolume`.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples, usually it has location and date information.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`.
#' - `unit`: Unit of the values in the `value` column.
#' - `release`: Version of data release by NEON.
#' - `samplerType`:	Type of sampler used to collect the sample.
#' - `towsTrapsVolumn`: Sample volume collected for zooplankton.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Lara Jansen; Stephanie Parker
#'
"data_zooplankton"
