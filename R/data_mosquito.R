#' Mosquitoes sampled from CO2 traps
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10043.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10043.001>.
#'
#' To clean the data, we:
#'
#' 1. Kept deployed trap-nights from `mos_trapping` (`trapHours > 0`; `samplingImpractical` of `OK` or missing; `targetTaxaPresent` of `Y`, `N`, or `U`).
#' 2. Left-joined `mos_trapping` to `mos_sorting` (by `sampleID`) and to `mos_expertTaxonomistIDProcessed` (by `subsampleID`), keeping traps that caught nothing.
#' 3. Summed duplicate expert records of the same taxon and sex within a sample.
#' 4. Kept expert identifications below family rank, and zero rows for traps (or identified subsamples) with no target taxa. Uncertain traps (`targetTaxaPresent == "U"`) without expert identifications were dropped.
#' 5. Estimated total individuals per sample = `individualCount / proportionIdentified` (equivalent to the weight-based correction in the NEON user guide).
#' 6. Abundance = estimated total individuals / `trapHours` (count per trap hour).
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Zero rows.** A trap-night that caught no mosquitoes is kept as one row with `taxon_id = NA` and `value = 0`. NEON does not assign a `sampleID` to empty traps, so their `unique_sample_id` is built from the plot and the collection time in UTC (`plotID.YYYYMMDDTHHMMZ.empty`); this format differs from NEON sampleIDs, which use local time, so the two cannot collide. This zero-row convention is shared by all neonDivData observation datasets.
#'
#' **Flags.** Compromised samples and trap problems are flagged rather than removed: `sampleCondition` collects non-OK conditions from trapping, sorting, and expert identification (e.g. "trapping: Cold chain broken"), and `trapConditionFlag` collects fan, catch cup, and CO2 problems (e.g. "fan: Off; CO2: Absent"). Both are `NA` when no problem was recorded. Genus-level identifications are kept; `redundant_genus` marks those that co-occur with a finer identification of the same genus in the same sample. Day and night traps are distinguished by `nightOrDay`.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples (equals `sampleID`; `plotID.YYYYMMDDTHHMMZ.empty` for empty traps).
#' - `subsampleID`: Unique identifier associated with each subsample per sampleID.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources. `NA` for zero rows.
#' - `taxon_name`: Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Abundance (count per trap hour); `0` for zero-catch traps.
#' - `unit`: Unit of the values in the `value` column ('count per trap hour').
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent; 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same sample.
#' - `proportionIdentified`: Proportion of the total catch that was subsampled and identified.
#' - `release`: Version of data release by NEON.
#' - `remarks_sorting`: Technician notes; free text comments accompanying the sorting record.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' - `sex`: M for male, F for female, U for unknown.
#' - `sortDate`: Date sample was sorted.
#' - `trapHours`: Number of hours between trap setting and collecting events.
#' - `nightOrDay`: Whether the trap was deployed during the night or the day.
#' - `sampleCondition`: Non-OK sample conditions from trapping, sorting, and expert identification; `NA` if none.
#' - `trapConditionFlag`: Trap operation problems (fan, catch cup, CO2); `NA` if none.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Natalie Robinson, Daijiang Li
#'
"data_mosquito"
