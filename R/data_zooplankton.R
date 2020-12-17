#' Zooplankton density data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20219.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20219.001>. Zooplankton are collected from the water column of lakes near NEON sensor infrastructure. The type of sampler used depends on the depth of water at the sampling location. Multiple tows or traps are collected at each location and composited into a single sample. Zooplankton sampling is quantitative and based on the volume of water collected during sampling.
#'
#' Here, we:
#' - Only keep those with `sampleCondition` to be "condition OK" for the `zoo_taxonomyProcessed` table.
#' - Combined the `zoo_fieldData` and the `zoo_taxonomyProcessed`.
#' - Calculated zooplankton density as the ratio of `adjCountPerBottle` and `towsTrapsVolume`.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `siteID`: NEON site code.
#' - `namedLocation`:	Name of the measurement location in the NEON database.
#' - `sampleID`: Identifier for sample.
#' - `samplerType`:	Type of sampler used to collect the sample.
#' - `subsampleType`:	Indicates type of subsample generated.
#' - `taxonID`: Species code, based on one or more sources.
#' - `scientificName`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `density`: Density of zooplankton, with unit to be count per liter.
#' - `collectDate`: Date of the collection event.
#' - `zooMinimumLength`: Minimum length of individuals in zooplankton taxonomic group subsample (millimeter).
#' - `zooMaximumLength`: Maximum length of individuals in zooplankton taxonomic group subsample (millimeter).
#' - `zooMeanLength`: Mean length of individuals in zooplankton taxonomic group subsample (millimeter).
#'
#' @author Lara Jansen; Stephanie Parker
#'
"data_zooplankton"
