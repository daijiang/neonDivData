#' Small mammal box trap data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10072.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10072.001>.
#'
#' To process data we:
#' 1. Filter nights from `mam_perplotnight` where `samplingImpractical` is not `"OK"` (field added 2020; pre-2020 records without this field are retained).
#' 2. Compute trapping effort as the number of unique trap coordinates deployed per night-uid, summed across all valid nights within a bout per plot (`n_trap_nights_per_bout_per_plot`).
#' 3. Identify bouts using `eventID` from `mam_perplotnight`; fall back to year_month for records lacking an `eventID`.
#' 4. Retain only capture records with `trapStatus` `"5 - capture"` or `"4 - more than 1 capture in one trap"`, restricting to taxa identified to genus or finer rank.
#' 5. Resolve within-bout recaptures: tagged individuals (non-missing `tagID`) are counted once per bout; untagged individuals (missing `tagID`) are each treated as unique using their row identifier.
#' 6. Compute `value` as `100 * raw_count / n_trap_nights_per_bout_per_plot` (unique individuals per 100 trap nights per plot per month).
#' 7. Retain effort-only rows (bouts with no qualifying captures) with `taxon_id`, `taxon_name`, `taxon_rank`, and `value` set to `NA`.
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
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#'
#' @author Marta Jarzyna
#' @source <https://data.neonscience.org>
#'
"data_small_mammal"
