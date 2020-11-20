#' Small mammal box trap data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10072.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10072.001>.
#'
#' To process data we:
#' 1. Remove all records that are designated as "dead", "escaped", or "nontarget".
#' 2. Remove all records designated as recaptures (i.e., only first captures are retained)

#' 
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `trapCoordinate`: Relative coordinate of the trap within the given plotID (A1 - J10). If row or column coordinate is unknown, X is used.
#' - `trapStatus`: Categorical descriptor of trap status; 0 - no data; 1 - trap not set; 2 - trap disturbed/door closed but empty; 3 - trap door open or closed w/ spoor left; 4 - >1 capture in one trap; 5 - capture; 6 - trap set and empty.
#' - `year`: Observation year.
#' - `month`: Observation month.
#' - `day`: Observation day.
#' - `taxonID`: Species code, based on one or more sources.
#' - `scientificName`: Scientific name, associated with the taxonID. This is the name of the lowest level taxonomic rank that can be determined.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `family`: The family of the species.
#' - `nativeStatusCode`: Whether the species is a native or non-native species.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a
#' given location; 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `sex`: M for male, F for female, U for unknown.
#' - `lifeStage`:	The age class of the individual at the time the Occurrence was recorded.
#' juvenile = obvious signs of a very young individual, small size, distinctive pelage coloration; subabult; adult.
#' - `pregnancyStatus`:	Condition at time of capture; if mature: 'pregnant' | 'not'.
#' - `tailLength`: length of tail; in millimeters.
#' - `totalLength`: total length (head + body); in millimeters.
#' - `weight`: Live weight as measured with a spring scale; in grams.
#'
#' @source <https://data.neonscience.org>
"data_small_mammal"
