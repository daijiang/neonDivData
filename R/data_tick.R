#' Ticks sampled using drag cloths
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10093.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10093.001>.
#'
#' To clean the data, we:
#'
#' 1. Mapped life stage from `tck_taxonomyProcessed` sex/age codes to `Larva`, `Nymph`, or `Adult`; rows with unmappable values are dropped.
#' 2. Aggregated taxonomy counts by `sampleID`, `acceptedTaxonID`, and `LifeStage`; concatenated `release` values.
#' 3. Applied the IXOSP2 reconciliation fix: when field counts (from `tck_fielddata`) exceed lab counts for a given life stage, the difference is assigned to Order Ixodida (`IXOSP2`, `"Ixodida sp."`) rather than using fragile string-matching.
#' 4. Left-joined downward from field effort to lab taxonomy to preserve empty drag events (`targetTaxaPresent == "N"`), which receive `individualCount = 0`.
#' 5. Abundance = `individualCount / totalSampledArea` (count per square meter); invalid or non-finite values are dropped except for empty drag rows.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of unique samples (`plotID_collectDate`).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`: Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Abundance (count per square meter).
#' - `unit`: Unit of the values in the `value` column.
#' - `LifeStage`: Life stage of the tick (`Larva`, `Nymph`, or `Adult`).
#' - `release`: Version of data release by NEON.
#' - `remarks_field`: Technician notes; free text comments accompanying the record.
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
