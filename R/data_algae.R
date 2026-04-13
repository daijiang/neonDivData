#' Periphyton, seston, and phytoplankton collection
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20166.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20166.001>.
#'
#' To clean the data, we:
#'
#' 1. Filtered `alg_biomass` to `analysisType == "taxonomy"` records only.
#' 2. Computed a fallback bottle volume (`preservativeVolume + labSampleVolume`) used when `perBottleSampleVolume` is `NA` or `0`.
#' 3. Joined `alg_taxonomyProcessed` to `alg_biomass` to `alg_fieldData` via `sampleID` and `parentSampleID`.
#' 4. Filtered to `algalParameterUnit == "cellsPerBottle"` and `sampleCondition == "Condition OK"`.
#' 5. Computed cell density: water column samples (`seston`/`phytoplankton`) as cells/mL; benthic samples as cells/cm².
#' 6. Resolved within-sample duplicates by summing density across records sharing the same `sampleID` and `acceptedTaxonID`.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples (equals `sampleID`).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted taxon code.
#' - `taxon_name`: Scientific name associated with the taxon ID.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Cell density value.
#' - `unit`: Either `cells/mL` (water column) or `cells/cm2` (benthic).
#' - `sampleCondition`: Condition of the sample (all `"Condition OK"`).
#' - `perBottleSampleVolume`: Sample volume per bottle (milliliter); fallback-filled where originally missing.
#' - `release`: Version of data release by NEON.
#' - `habitatType`: Habitat type sampled.
#' - `algalSampleType`: Type of algal sample collected.
#' - `samplerType`: Type of sampler used to collect the sample.
#' - `benthicArea`: Area of the benthos sampled (square meter).
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format NEON.DOC.######vX.
#' - `substratumSizeClass`: Size class of the substratum sampled.
#' - `phytoDepth1`: First phytoplankton sample depth (meter) at sampling location.
#' - `phytoDepth2`: Second phytoplankton sample depth (meter) at sampling location.
#' - `phytoDepth3`: Third phytoplankton sample depth (meter) at sampling location.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Lara Jansen
#'
"data_algae"
