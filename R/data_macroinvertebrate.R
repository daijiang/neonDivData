#' Aquatic macroinvertebrate density data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20120.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20120.001>.
#'
#' To clean the data, we:
#'
#' 1. Deduplicated `inv_fieldData` by `sampleID` using `slice(1)` as a guard against duplicate field records (none occur in the current release).
#' 2. Filtered `inv_taxonomyProcessed` to `targetTaxaPresent == "Y"` and non-missing `estimatedTotalCount`; summed `estimatedTotalCount` and `individualCount` across size-class records sharing the same `sampleID` and `acceptedTaxonID` (user guide section 3.10).
#' 3. Kept processed samples with no target taxa (`targetTaxaPresent == "N"`) as zero rows.
#' 4. Inner-joined taxonomy to field data (inner join required because `benthicArea` is needed to compute density; records without field metadata are dropped).
#' 5. Density = `estimatedTotalCount / benthicArea` (count per square meter, user guide equation 1).
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Zero rows.** A processed sample with no target taxa is kept as one row with `taxon_id = NA` and `value = 0`. This zero-row convention is shared by all neonDivData observation datasets.
#'
#' **Flags.** `sampleCondition` lists non-OK conditions of the taxonomy records (e.g. "damaged, affecting taxonomy"), and `dataQF` gives NEON field quality flags (e.g. "kicknet with incorrect mouth size used", which underestimates density); both are `NA` when no problem was recorded. `redundant_genus` marks genus-level records that co-occur with a finer identification of the same genus in the same sample; many macroinvertebrates are identified only to family or higher, so check `taxon_rank` before estimating richness.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples (equals `sampleID`).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources. `NA` for zero rows.
#' - `taxon_name`: Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Density (count per square meter); `0` for zero rows.
#' - `unit`: Unit of the values in the `value` column.
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same sample.
#' - `estimatedTotalCount`: Estimated total count (summed across size classes).
#' - `individualCount`: Raw individual count (summed across size classes).
#' - `subsamplePercent`: Percent of the total sample contained in the subsample (character; multiple values are separated by "|").
#' - `release`: Version of data release by NEON.
#' - `sampleCondition`: Non-OK conditions of the taxonomy records (separated by "|"); `NA` if all OK.
#' - `dataQF`: NEON data quality flag for the field sample; `NA` if none.
#' - `benthicArea`: Area sampled (square meter).
#' - `habitatType`: Habitat type sampled.
#' - `samplerType`: Type of sampler used to collect the sample.
#' - `substratumSizeClass`: Size class of the substratum sampled.
#' - `remarks`: Remarks of record.
#' - `ponarDepth`: Depth (meter) of petite ponar sample.
#' - `snagLength`: Length (centimeter) of snag sampled.
#' - `snagDiameter`: Diameter (centimeter) of snag sampled.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Stephanie Parker, Eric Sokol
#'
"data_macroinvertebrate"
