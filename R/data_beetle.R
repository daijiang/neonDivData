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
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `sampleID`: Identifier for sample.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `trapID`: Identifier for trap.
#' - `setDate`: Date that trap was set.
#' - `collectDate`: Date of the collection event.
#' - `trappingDays`: Decimal days between trap setting and collecting events.
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location;
#' 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `identificationSource`: Source of identification.
#' - `taxonID`: Species code, based on one or more sources.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `scientificName`: Scientific name, associated with the taxonID. This is the name of the lowest level taxonomic rank that can be determined.
#' - `count`: Number of individuals. `NA` represents no beetles catche in the trap.
#'
#' @author Kari Norman
#'
"data_beetle"
