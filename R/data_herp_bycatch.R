#' Vertebrate Herpetofauna Bycatch sampled from pitfall traps
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10022.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10022.001>.
#'
#' To process data we:
#' 1. Cleaned trappingDays.
#'    - So that is is the number of days a trap was set before being collected.
#'    - Correct trap days to account for entries where the trap set date was not updated based on a previous collection.
#' 2. Create a boutID that identifies all trap collection events at a site in the same bout essentially replacing eventID.
#' 3. Update collectDate to reference the most common collection day in a bout, maintaining one collectDate per bout.
#' 4. sampleType provides the group that was caught in the pit fall trap. This was changed to have three levels
#'    - "vert bycatch herp" - these are the samples
#'    - "no data collected" - these samples in fielddata not in sorting
#'    - "not herp" - this is a aggregate of all the other types "other carabid", "invert bycatch", "carabid", "vert bycatch mam"
#'    And we only kept "vert bycatch herp" in the final data product.
#'
#' @note  This script was derived from the script written by Kari Norman to process the pit fall traps of beetles.
#' Additional variables were added and missing samples were retained in herp_bycatch.
#'
#' @format A data frame (tibble) with the following columns:
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
#' - `trappingDays`: Cleaned up decimal days between trap setting and collecting events
#' - `release`: Version of data release by NEON.
#' - `nativeStatusCode`: 	The process by which the taxon became established in the location only provided for vert bycatch herp
#' - `neon_trap_id`: Identifier for trap.
#' - `remarksSorting`: Technician notes; free text comments accompanying the record from sorting table
#' - `remarksFielddata`: Technician notes; free text comments accompanying the record from fielddata table
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#'
#' @source <https://data.neonscience.org>
#'
#' @references Hoekman, David, Katherine E. LeVan, Cara Gibson, George E. Ball, Robert A. Browne, Robert L. Davidson, Terry L. Erwin, et al. “Design for Ground Beetle Abundance and Diversity Sampling within the National Ecological Observatory Network.” Ecosphere 8, no. 4 (2017): e01744.
#'
#' @author Matt Helmus and Kari Norman
#'
"data_herp_bycatch"
