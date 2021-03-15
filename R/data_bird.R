#' Breeding landbird point counts data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10003.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10003.001>.
#'
#' The bird data provided by NEON is already well organized. We only removed some columns that likely won't be used in biodiversity studies.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]). The sampling protocol has evolved over time, so users are advised to check whether the `samplingProtocolVersion` fits their data requirements and subset as necessary.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `pointID`: Identifier for a point location.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`. `NA` represents no bird observed.
#' - `unit`: Unit of the values in the `value` column.
#' - `pointCountMinute`: The minute of sampling within the point count period.
#' - `targetTaxaPresent`: Indicator of whether the sample contained individuals of the target taxa.
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location;
#' 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `observerDistance`: Radial distance between the observer and the individual(s) being observed (unit: meter).
#' - `detectionMethod`: How the individual(s) was (were) first detected by the observer.
#' - `visualConfirmation`: Whether the individual(s) was (were) seen after the initial detection.
#' - `sexOrAge`: Sex of individual if detectable, age of individual if individual can not be sexed.
#' - `release`: Version of data release by NEON.
#' - `observedHabitat`: Observer assessment of dominant habitat at the sampling point at sampling time.
#' - `observedAirTemp`: The air temperature (celsius) measured with a handheld weather meter.
#' - `kmPerHourObservedWindSpeed`: The average wind speed measured with a handheld weather meter, in kilometers per hour.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' `remarks`: Remarks of record.
#' - `clusterCode`: Alphabetic code (A-Z) linked to clusters (groups of individuals of the same species) spanning multiple records. It is only used to link clusters that take up multiple lines on the data sheet.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Daijiang Li, Eric Sokol
#'
"data_bird"
