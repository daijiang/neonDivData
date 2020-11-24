#' Periphyton, seston, and phytoplankton collection
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20166.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20166.001>.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `siteID`: NEON site code.
#' - `sampleID`: Identifier for sample.
#' - `eventID`:	An identifier for the set of information associated with the event,
#' which includes information about the place and time of the event.
#' - `namedLocation`:	Name of the measurement location in the NEON database.
#' - `habitatType`:	Habitat type sampled.
#' - `taxonID`: Species code, based on one or more sources.
#' - `scientificName`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `family`: The scientific name of the family in which the taxon is classified.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `collectDate`: Date of the collection event.
#' - `density`: Density of algae.
#' - `cell_density_standardized_unit`: Unit of `density`.
#' - `algalParameterValue`: Value of the algalParameter.
#' - `algalParameter`: Parameter used for analysis of algal assemblages.
#' - `perBSVol`: Per bottle sample volumn (milliliter).
#' - `fieldSampleVolume`: Sample volume collected in the field (milliliter).
#' - `algalSampleType`: Type of algal sample collected.
#' - `benthicArea`: Area of the benthos sampled (square Meter).
#'
#' @author Lara Jansen
#'
"data_algae"
