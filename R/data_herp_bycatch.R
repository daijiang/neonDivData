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
#' @format A data frame (tibble) with the following columns:
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `trapID`: Identifier for trap.
#' - `setDate`: Date that trap was set
#' - `collectDate`: Date of the collection event
#' - `eventID`: Cleaned up identifier for the set of information associated with the event, which includes information about the place and time of the event
#' - `trappingDays`: Cleaned up decimal days between trap setting and collecting events
#' - `taxonID`: Species code, based on one or more sources only provided for vert bycatch herp
#' - `scientificName`: Scientific name, associated with the taxonID. This is the name of the lowest level taxonomic rank that can be determined only provided for vert bycatch herp
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen only provided for vert bycatch herp
#' - `individualCount`: Number of individuals of the same type, summed across types for all sampleTypes but vert bycatch herp
#' - `nativeStatusCode`: 	The process by which the taxon became established in the location only provided for vert bycatch herp
#' - `remarksSorting`: Technician notes; free text comments accompanying the record from sorting table
#' - `remarksFielddata`: Technician notes; free text comments accompanying the record from fielddata table
#'
#' @source <https://data.neonscience.org>
#' @references Hoekman, David, Katherine E. LeVan, Cara Gibson, George E. Ball, Robert A. Browne, Robert L. Davidson, Terry L. Erwin, et al. “Design for Ground Beetle Abundance and Diversity Sampling within the National Ecological Observatory Network.” Ecosphere 8, no. 4 (2017): e01744.
#' @author Matt Helmus and Kari Norman
#'
"data_herp_bycatch"
