#' Tick-borne pathogen status
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10092.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10092.001>.
#'
#' To clean the data, we:
#'
#' 1. Removed samples with flagged quality checks
#' 2. Removed samples with missing metadata (domain/site/plotID; Lat/Long; plotType; nlcdClass, elevation, collectDate, subsampleID, batchID, testingID, testPathogenName
#' 3. Removed samples where sampleCondition!=“OK”
#' 4. Removed samples where testResult==NA
#' 5. Removed samples where HardTick DNA Quality (under testPathogenName) are not ‘Positive’, and then removed hardtack DNA and Ixodes pacificus tests.
#' 6. Combined B. burgdeferi and B burgdeferi sensu lato into a single test pathogen type (B. burgedferi sensu lato)
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of unique samples, usually it has location and date information.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`.
#' - `unit`: Unit of the values in the `value` column.
#' - `lifeStage`: Life stage of the host (all Nymph).
#' - `batchID`: Identifier for batch or analytical run.
#' - `testProtocolVersion`: The protocol version used to test the sample.
#' - `release`: Version of data release by NEON.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Melissa Chen, Wynne Moss, Brendan Hobart, Matt Bitters
#'
"data_tick_pathogen"
