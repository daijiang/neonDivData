#' Ground beetle abundance data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10022.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10022.001>.
#'
#' To clean the data, we:
#'
#' 1. Filtered `bet_fielddata` to `sampleCollected == "Y"`; computed `trappingDays` from set/collect dates; adjusted for traps collected multiple times from the same set date; consolidated trap condition issues into `trapConditionFlag` from `cupStatus`, `lidStatus`, and `fluidLevel`.
#' 2. Built a taxonomy resolution hierarchy: Expert ID overrides Parataxonomist ID; both override Sorting taxonomy. Unpinned `other carabid` individuals are excluded because their sorting-level taxonomy is too coarse (2013-2016 protocol).
#' 3. Computed unpinned counts per subsample (sorting total minus pinned individuals); clamped to zero where anomalous.
#' 4. Left-joined downward from field effort to taxonomy to preserve zero-catch trap events (`value = NA`).
#' 5. Abundance = `count / trappingDays` (count per trap day).
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of unique samples (equals `sampleID`).
#' - `trapID`: Identifier for the trap.
#' - `observation_datetime`: Observation date (collection date).
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`: Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Abundance (count per trap day); `NA` for zero-catch events.
#' - `unit`: Unit of the values in the `value` column.
#' - `boutID`: Sampling bout identifier (`siteID_collectDate`).
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent; 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `release`: Version of data release by NEON.
#' - `remarks`: Remarks (technical notes) of record.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' - `samplingImpractical`: Flag indicating whether sampling was impractical.
#' - `trapConditionFlag`: Consolidated trap condition flag from cup, lid, and fluid level status.
#' - `trappingDays`: Number of days between trap setting and collecting events.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#'
#' @author Kari Norman
#'
"data_beetle"
