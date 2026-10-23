#' Ground beetle abundance data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10022.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10022.001>.
#'
#' To clean the data, we:
#'
#' 1. Filtered `bet_fielddata` to `sampleCollected == "Y"`. `trappingDays` is the number of days since the trap was set, or since its previous collection when a trap was collected more than once from the same set date. Placeholder `eventID`s in a few 2014-2015 records were rebuilt from site, year, and week.
#' 2. Built a taxonomy resolution hierarchy: Expert ID overrides Parataxonomist ID; both override Sorting taxonomy. For the rare individuals with more than one expert record, the most recent expert ID was used. Unpinned `other carabid` individuals are excluded because their sorting-level taxonomy is too coarse (2013-2016 protocol).
#' 3. Computed unpinned counts per subsample (sorting total minus pinned individuals); clamped to zero where anomalous.
#' 4. Dropped collected samples with no record at all in `bet_sorting` (mostly 2013-2014); these were never processed, so their catch is unknown.
#' 5. Left-joined downward from field effort to taxonomy so that sorted samples with no carabids are kept as zero rows.
#' 6. Abundance = `count / trappingDays` (count per trap day).
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Zero rows.** A trap sample that was collected and sorted but contained no carabids is kept as one row with `taxon_id = NA` and `value = 0`. This zero-row convention is shared by all neonDivData observation datasets.
#'
#' **Flags.** Trap and sample problems are flagged rather than removed: `trapConditionFlag` lists cup, lid, and fluid level problems (e.g. "lid: Disturbed; fluid: High"; user guide section 5.4), `sampleCondition` gives non-OK sample conditions (e.g. "sample incomplete"), and `samplingImpractical` is carried through. All are `NA` when no problem was recorded. `redundant_genus` marks genus-level records that co-occur with a finer identification of the same genus in the same sample.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of unique samples (equals `sampleID`).
#' - `trapID`: Identifier for the trap.
#' - `observation_datetime`: Collection date of the trap.
#' - `taxon_id`: Accepted species code, based on one or more sources. `NA` for zero rows.
#' - `taxon_name`: Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Abundance (count per trap day); `0` for zero-catch samples.
#' - `unit`: Unit of the values in the `value` column.
#' - `boutID`: Sampling bout identifier (`siteID_boutDate`, where the bout date is the most common collection date of the bout; collection can span two days).
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent; 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same sample.
#' - `release`: Version of data release by NEON.
#' - `remarks`: Remarks (technical notes) of record.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' - `samplingImpractical`: Reason sampling was impractical; `NA` if sampling was OK.
#' - `sampleCondition`: Non-OK condition of the field sample; `NA` if OK.
#' - `trapConditionFlag`: Cup, lid, and fluid level problems; `NA` if none.
#' - `trappingDays`: Number of days the trap was set before this collection (numeric).
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#'
#' @author Kari Norman
#'
"data_beetle"
