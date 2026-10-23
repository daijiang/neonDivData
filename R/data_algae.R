#' Periphyton, seston, and phytoplankton collection
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20166.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20166.001>.
#'
#' To clean the data, we:
#'
#' 1. Filtered `alg_biomass` to `analysisType == "taxonomy"` records only.
#' 2. Computed a fallback bottle volume (`preservativeVolume + labSampleVolume`, user guide equation 1) used when `perBottleSampleVolume` is `NA` or `0` (2014 samples).
#' 3. Kept `alg_taxonomyProcessed` records with `algalParameterUnit == "cellsPerBottle"` and a taxon ID.
#' 4. Reconciled diatom counts following user guide section 3.9. Soft algae + diatom counts are quantitative, while diatom slide counts give species-level relative abundance only. For samples with both, the total diatom count from the soft algae analysis was split among slide taxa in proportion to their slide counts, and replaced the soft algae diatom records. When a sample had slide data but no soft algae diatoms, slide counts were used as reported. Adding both analyses would double count diatoms. The method used for each record is given in `count_method`.
#' 5. Joined taxonomy to `alg_biomass` and `alg_fieldData` via `sampleID` and `parentSampleID`.
#' 6. Computed cell density: water column samples (`seston`/`phytoplankton`) as cells/mL; benthic samples as cells/cm² (cells per bottle / bottle volume x field sample volume / benthic area).
#' 7. Resolved within-sample duplicates (separate morphotype or size records of one taxon) by summing density across records sharing the same `sampleID` and `acceptedTaxonID`.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Temporal coverage.** NEON did not analyze algal taxonomy between November 2020 and December 2023, and the data product was suspended in 2024 (user guide section 3.3). Samples collected in late 2020 were counted only as natural units or valves, not cells, so cell density in this dataset ends in July 2020.
#'
#' **Zero rows.** Algal samples always contain cells, so this dataset has no zero rows (the zero-row convention of the other datasets does not apply).
#'
#' **Flags.** `sampleCondition` gives non-OK conditions of the taxonomy sample; `NA` if OK. Seston taxonomy exists only for 2014-2017 and has very low counts. `redundant_genus` marks genus-level records that co-occur with a finer identification of the same genus in the same sample.
#'
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
#' - `count_method`: How the count was obtained: "soft algae count", "diatom slide proportion x soft algae diatom count", or "diatom slide count".
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same sample.
#' - `sampleCondition`: Non-OK condition of the taxonomy sample; `NA` if OK.
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
