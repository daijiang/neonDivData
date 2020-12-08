#' Mosquitoes sampled from CO2 traps
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10043.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10043.001>.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `eventID`: An identifier for the set of information associated with the event, which includes information about the place and time of the event.
#' - `sampleID`: Identifier for sample.
#' - `taxonID`: Species code, based on one or more sources.
#' - `scientificName`: Scientific name, associated with the taxonID. This is the name of the lowest level taxonomic rank that can be determined.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `family`: The scientific name of the family in which the taxon is classified.
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location;
#' 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `sex`: M for male, F for female, U for unknown.
#' - `collectDate`: Date of the collection event.
#' - `startCollectDate`: Earliest known collection date for this sample.
#' - `endCollectDate`: Latest known collection date for this sample.
#' - `individualCount`: Number of individuals of the same type.
#' - `estimated_totIndividuals`: Estimated total number of individuals.
#' - `trapHours`: Number of hours between trap setting and collecting events.
#' - `nightOrDay`: Whether sampling occurred primarily during the day or at night.
#' - `totalWeight`: Weight of entire sample in gram.
#' - `subsampleWeight`:	Weight of subsample in gram.
#'
#' @author Natalie Robinson
#'
#'
"data_mosquito"
