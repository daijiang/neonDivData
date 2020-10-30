#' Ticks sampled using drag cloths
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10093.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10093.001>.
#'
#' BRIEF STEPS WE HAVE TOOK TO PREPARE THIS PRODUCT...
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `collectDate`: Date of the collection event.
#' - `eventID`: An identifier for the set of information associated with the event, which includes information about the place and time of the event.
#' - `sampleID`: Identifier for sample.
#' - `sampleCode`: Barcode of a sample.
#' - `samplingMethod`: Name or code for the method used to collect or test a sample.
#' - `totalSampledArea`: Total area sampled (square Meter).
#' - `targetTaxaPresent`: Indicator of whether the sample contained individuals of the target taxa ('Y' or 'N').
#' - `remarks_field`: Technician notes; free text comments accompanying the record.
#' - `acceptedTaxonID`: Accepted species code, based on one or more sources.
#' - `LifeStage`: Life stage of the sample ('Adult', 'Larva', or 'Nymph').
#' - `IndividualCount`: Number of individuals of the same type.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `scientificName`: Scientific name, associated with the taxonID. This is the name of the lowest level taxonomic rank that can be determined.
#'
"data_tick"
