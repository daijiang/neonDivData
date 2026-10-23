#' Breeding landbird point count data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10003.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10003.001>.
#'
#' To clean the data, we:
#'
#' 1. Filtered `brd_perpoint` to `samplingImpractical == "OK"` to retain only surveyed points.
#' 2. Left-joined downward from point survey records to `brd_countdata` by `eventID`, `plotID`, and `pointID` to preserve zero-bird survey points. Points without any count record were dropped.
#' 3. Kept every detection record. Rows that look identical (same species, minute, distance, and cluster size) are separate detections and are not collapsed.
#' 4. Collapsed each point count with no birds detected (all minutes `targetTaxaPresent == "N"`) into one zero row. Minute-level `targetTaxaPresent == "N"` rows at points where birds were detected in other minutes carry no information and were dropped.
#' 5. `value` = cluster size (count of individuals); `unique_sample_id` = `eventID`.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]); coordinates are for the plot (grid) center, not the point. The sampling protocol has evolved over time, so users are advised to check whether the `samplingProtocolVersion` fits their data requirements and subset as necessary.
#'
#' **Zero rows.** A point count with no birds detected is kept as one row with `taxon_id = NA` and `value = 0`. This zero-row convention is shared by all neonDivData observation datasets.
#'
#' **Records to consider removing.** Each row is one detection (one cluster in one minute), so counts for a species at a point must be summed. Before analysis, consider:
#' - `incidental_observation == TRUE` (`pointCountMinute == 88`): birds observed outside the timed count, with unknown location (user guide section 3.5).
#' - Flyovers (`detectionMethod`), which have no distance measured.
#' - Records not identified to species (`taxon_rank` of class, family, subfamily, genus, or speciesGroup, e.g. "Aves sp." or slash taxa); `redundant_genus` marks genus-level records that co-occur with a species of the same genus in the same point count.
#' - Detections with an unknown cluster size (`value = NA`).
#' - Most points are surveyed twice per season (`boutNumber`).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `pointID`: Identifier for a point location.
#' - `unique_sample_id`: Identity of the sampling bout at a site (equals `eventID`, e.g. `BRD.HARV.2019.1`); a single point count is identified by `unique_sample_id`, `plotID`, and `pointID` together (point numbers repeat across plots).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources. `NA` for zero rows.
#' - `taxon_name`: Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Cluster size (count of individuals observed); `0` for zero-bird points; `NA` when a bird was detected but its cluster size was not recorded.
#' - `unit`: Unit of the values in the `value` column.
#' - `boutNumber`: Sampling bout within the season (most points are surveyed twice per year).
#' - `pointCountMinute`: The minute of sampling within the point count period; 88 = observed outside the count; `NA` for zero rows.
#' - `incidental_observation`: `TRUE` when `pointCountMinute == 88`.
#' - `targetTaxaPresent`: Indicator of whether the sample contained individuals of the target taxa.
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same point count.
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent; 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `observerDistance`: Radial distance between the observer and the individual(s) being observed (meter).
#' - `detectionMethod`: How the individual(s) was (were) first detected by the observer.
#' - `visualConfirmation`: Whether the individual(s) was (were) seen after the initial detection.
#' - `sexOrAge`: Sex of individual if detectable, age of individual if individual cannot be sexed.
#' - `release`: Version of data release by NEON.
#' - `startCloudCoverPercentage`: Observer estimate of percent cloud cover at start of sampling.
#' - `endCloudCoverPercentage`: Observer estimate of percent cloud cover at end of sampling.
#' - `startRH`: Relative humidity as measured by handheld weather meter at the start of sampling.
#' - `endRH`: Relative humidity as measured by handheld weather meter at the end of sampling.
#' - `observedHabitat`: Observer assessment of dominant habitat at the sampling point at sampling time.
#' - `observedAirTemp`: The air temperature (Celsius) measured with a handheld weather meter.
#' - `kmPerHourObservedWindSpeed`: The average wind speed measured with a handheld weather meter, in kilometers per hour.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' - `remarks`: Remarks recorded for the point count (from `brd_perpoint`).
#' - `clusterCode`: Alphabetic code (A-Z) linking clusters of individuals of the same species spanning multiple records.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Daijiang Li, Eric Sokol
#'
"data_bird"
