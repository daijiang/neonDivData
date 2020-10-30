#' Tick-borne pathogen status
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10092.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10092.001>.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `collectDate`:	Date of the collection event.
#' - `endDate`: The end date-time or interval during which an event occurred.
#' - `hostSpecies`: Host tick species.
#' - `lifeStage`: Life stage of the host (all Nymph).
#' - `testedDate`: Date test was conducted.
#' - `testingID`: Identifier for the group of specimens for testing.
#' - `batchID`: Identifier for batch or analytical run.
#' - `testResult`: Result of the test.
#' - `testPathogenName`	The name of the pathogen.
#'
"data_tick_pathogen"
