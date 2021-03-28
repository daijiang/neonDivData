#' Ground beetles sampled from pitfall traps
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10022.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10022.001>.
#'
#' To process data we:
#' 1. Remove all non-carabid bycatch samples.
#' 2. Use the most expert taxonomy when available.
#' 3. Update abundances based on new taxonomy.
#' 4. Create a boutID that identifies all trap collection events at a site in the same bout (replacing eventID).
#' 5. Update collectDate to reference the most common collection day in a bout, maintaining one collectDate per bout.
#' 6. Create a new `trappingDays` column for the number of days a trap was set before being collected.
#' 7. Correct trap days to account for entries where the trap set date was not updated based on a previous collection.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
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
#' - `boutID`: Identifier for bout.
#' - `trapID`: Identifier for trap.
#' - `trappingDays`: Decimal days between trap setting and collecting events.
#' - `release`: Version of data release by NEON.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location;
#' 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' `remarks`: Remarks of record.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#'
#'
#' @author Kari Norman
#'
"data_beetle"
