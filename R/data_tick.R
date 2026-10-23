#' Ticks sampled using drag cloths
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10093.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10093.001>.
#'
#' To clean the data, we:
#'
#' 1. Kept field samples with `samplingImpractical` of `OK` or missing. Drags coded as having no ticks (`targetTaxaPresent == "N"`) that nonetheless have lab-identified ticks were recoded to `"Y"`.
#' 2. Mapped life stage from `tck_taxonomyProcessed` sex/age codes to `Larva`, `Nymph`, or `Adult`; rows with unmappable values are dropped. Lab records are not filtered on `sampleCondition`, because damaged ticks are still identified and counted.
#' 3. Aggregated taxonomy counts by `sampleID`, `acceptedTaxonID`, and `LifeStage`; concatenated `release` values.
#' 4. Reconciled field and lab counts (2014-2018 only; see note): when field counts exceed lab counts, the unidentified remainder is added as `Ixodidae sp.` (`IXOSP`, family rank), the code NEON itself uses for unidentified ticks. The remainder is capped so the sample total equals the larger of the field and lab totals, avoiding double counts when field staff assigned ticks to the wrong life stage.
#' 5. Left-joined downward from field effort to lab taxonomy to preserve empty drag events (`targetTaxaPresent == "N"`).
#' 6. Abundance = `individualCount / totalSampledArea` (count per square meter). Samples with ticks but no usable counts (e.g. lost samples after 2018 without lab data) are dropped.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Zero rows.** A drag with no ticks is kept as one row with `taxon_id = NA` and `value = 0`. This zero-row convention is shared by all neonDivData observation datasets.
#'
#' **Protocol change in 2019.** From 2014 to 2018, field staff counted ticks by life stage, and the lab did not always identify every tick (invoice limits, subsampling of large larval samples). Field counts stopped in 2019; since then the lab counts every tick. `count_source` shows whether a count comes from the lab, from the field-count remainder, or both. Abundance of `IXOSP` (especially larvae) is therefore much higher before 2019.
#'
#' **Flags.** `sampleCondition` gives non-OK field sample conditions (e.g. "Entire sample lost", "Tick count estimated"); `NA` if no compromise. `samplingMethod` distinguishes drag and flag sampling, which differ in efficiency. `redundant_genus` marks genus-level records that co-occur with a finer identification of the same genus and life stage in the same sample.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of unique samples (`plotID_collectDate`, where collectDate includes the time).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources. `NA` for zero rows.
#' - `taxon_name`: Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Abundance (count per square meter); `0` for zero rows.
#' - `unit`: Unit of the values in the `value` column.
#' - `LifeStage`: Life stage of the tick (`Larva`, `Nymph`, or `Adult`).
#' - `count_source`: Source of the count: "lab", "field count excess", or "field count excess + lab"; `NA` for zero rows.
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus and life stage in the same sample.
#' - `release`: Version of data release by NEON.
#' - `remarks_field`: Technician notes; free text comments accompanying the record.
#' - `sampleCondition`: Non-OK condition of the field sample; `NA` if no known compromise.
#' - `samplingMethod`: Name or code for the method used to collect or test a sample.
#' - `targetTaxaPresent`: Indicator of whether the sample contained individuals of the target taxa ('Y' or 'N').
#' - `totalSampledArea`: Total area sampled (square meter).
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Wynne Moss, Melissa Chen, Brendan Hobart, Matt Bitters
#'
"data_tick"
