#' Zooplankton density data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20219.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20219.001>. Zooplankton are collected from the water column of lakes near NEON sensor infrastructure. The type of sampler used depends on the depth of water at the sampling location. Multiple tows or traps are collected at each location and composited into a single sample. Zooplankton sampling is quantitative and based on the volume of water collected during sampling.
#'
#' To clean the data, we:
#'
#' 1. Deduplicated `zoo_fieldData` by `sampleID` using `slice(1)` to guard against NEON's known aquatic duplicate metadata issue.
#' 2. Summed `adjCountPerBottle` across size-class and life-stage records sharing the same `sampleID` and `taxonID`. `adjCountPerBottle` is already corrected for subsampling by the laboratory. Records are not filtered on `sampleCondition`: most non-OK values are life-stage notes ("other (specified in remarks)", e.g. "Copepodids") or affect body length measurements only.
#' 3. Inner-joined taxonomy to field data (inner join required because `towsTrapsVolume` is needed to compute density; records without field metadata are dropped).
#' 4. Density = `sum(adjCountPerBottle) / towsTrapsVolume` (count per liter), per user guide equation 2.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Zero rows.** NEON reports no zooplankton samples without target taxa, so this dataset has no zero rows (the zero-row convention of the other datasets does not apply).
#'
#' **Flags.** `sampleCondition` lists non-OK conditions of the taxonomy records (separated by "|"); `NA` if all OK. Consider excluding "damaged, affecting analysis". Tow net (whole water column) and Schindler trap samples differ in volume and depth sampled (`samplerType`), so check comparability before pooling. `redundant_genus` marks genus-level records that co-occur with a finer identification of the same genus in the same sample.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id (named location).
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples (equals `sampleID`).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted taxon code.
#' - `taxon_name`: Scientific name associated with the taxon ID.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Density (count per liter).
#' - `unit`: Unit of the values in the `value` column (`"count per liter"`).
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same sample.
#' - `release`: Version of data release by NEON.
#' - `sampleCondition`: Non-OK conditions of the taxonomy records (separated by "|"); `NA` if all OK.
#' - `samplerType`: Type of sampler used to collect the sample.
#' - `towsTrapsVolume`: Sample volume (liter) collected for zooplankton.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Lara Jansen, Stephanie Parker
#'
"data_zooplankton"
