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
#' @author Melissa Chen, Wynne Moss, Brendan Hobart, Matt Bitters
#'
"data_tick_pathogen"
