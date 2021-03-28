#' Periphyton, seston, and phytoplankton collection
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20166.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20166.001>.
#'
#' Here, we:
#' - Only records from the ‘alg_biomass’ with the ‘analysis_type’ taxonomy were used for the observation table.
#' - Combined the preservative sample volume  and lab’s recorded volumes from the ‘alg_biomass’ file and ‘alg_tax_long’ for total sample volume. If missing ‘perBottleSampleVolume’, they were created using NEON domain lab volumes. This new volume column was labeled ‘perBSVol’.
#' - Combined ‘Alg_field_data’ with ‘alg_biomass’ via ‘parentSampleID’ to add in field conditions and ‘benthicArea’.
#' - Corrected sample units from ‘cellsperBottle’ to density by dividing ‘algalParameterValue’ updated sample volume ‘perBSVol. Benthic samples units were then corrected to density by multiplying ‘algalParameterValue’ by ‘fieldSampleVolume’ and dividing by ‘benthicArea’ sampled.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples, usually it has location and date information.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`.
#' - `unit`: Unit of the values in the `value` column.
#' - `sampleCondition`: Condition of samples.
#' - `perBottleSampleVolume`: Per bottle sample volumn (milliliter).
#' - `release`: Version of data release by NEON.
#' - `habitatType`: Habitat type sampled.
#' - `algalSampleType`: Type of algal sample collected.
#' - `benthicArea`: Area of the benthos sampled (square Meter).
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format NEON.DOC.######vX.
#' - `substratumSizeClass`: Size class of the substratum sampled.
#' - `samplerType`: Type of sampler used to collect the sample.
#' - `phytoDepth1`: First phytoplankton sample depth at sampling location
#' - `phytoDepth2`: Second phytoplankton sample depth at sampling location
#' - `phytoDepth3`: Third phytoplankton sample depth at sampling location
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Lara Jansen
#'
"data_algae"
