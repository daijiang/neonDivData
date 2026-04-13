#' Tick-borne pathogen status
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10092.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10092.001>.
#'
#' To clean the data, we:
#'
#' 1. Removed tests from batches that failed quality criteria (`criteriaMet != "Y"` in `tck_pathogenqa`).
#' 2. Removed samples where `sampleCondition != "OK"` or `testResult` is `NA`.
#' 3. Applied the DNA quality fix: identified ticks (`testingID`) whose `HardTick DNA Quality` test was not `"Positive"` and dropped all test rows for those ticks (not just the DNA quality row itself), because pathogen results from ticks with degraded DNA are unreliable.
#' 4. Removed `HardTick DNA Quality` and `Ixodes pacificus` test rows; unified `"Borrelia burgdorferi"` into `"Borrelia burgdorferi sensu lato"`.
#' 5. Extracted `lifeStage` from the last dot-delimited segment of `subsampleID`.
#' 6. Aggregated to one row per location x date x pathogen x life stage: `value` = `n_positive_test / n_tests`.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id (named location).
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier.
#' - `unique_sample_id`: Identity of unique samples (`namedLocation_collectDate`).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Pathogen name (standardized).
#' - `taxon_name`: Pathogen name (same as `taxon_id`).
#' - `taxon_rank`: Taxonomic rank inferred from name (`"genus"` for sp./spp. names, otherwise `"species"`).
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Positivity rate (`n_positive_test / n_tests`).
#' - `unit`: Unit of the values in the `value` column (`"positive tests per pathogen per sampling event"`).
#' - `lifeStage`: Life stage of the host tick (extracted from `subsampleID`).
#' - `testProtocolVersion`: The protocol version used to test the sample.
#' - `release`: Version of data release by NEON.
#' - `n_tests`: Number of tests conducted.
#' - `n_positive_test`: Number of tests that were positive.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Melissa Chen, Wynne Moss, Brendan Hobart, Matt Bitters
#'
"data_tick_pathogen"
