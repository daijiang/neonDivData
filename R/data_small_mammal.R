#' Small mammal box trap data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10072.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10072.001>.
#'
#' To process data we:
#' 1. Remove all records that are designated as "dead", "escaped", or "nontarget".
#' 2. Remove all records designated as recaptures (i.e., only first captures are retained)

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
#' - `year`: Observation year.
#' - `month`: Observation month.
#' - `n_trap_nights_per_bout_per_plot`: Number of trap nights per bout per plot.
#' - `n_nights_per_bout`: Number of nights per bout.
#' - `nativeStatusCode`: Whether the species is a native or non-native species.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a
#' given location; 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `release`: Version of data release by NEON.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Marta Jarzyna
#' @source <https://data.neonscience.org>
#'
"data_small_mammal"
