#' Ground beetles sampled from pitfall traps
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10022.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10022.001>.
#'
#' BRIEF STEPS WE HAVE TOOK TO PREPARE THIS PRODUCT...
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
"data_beetle"
