#' Mosquitoes sampled from CO2 traps
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10043.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10043.001>.
#'
#' To clean the data and preserve sampling effort, we performed the following steps:
#' 1. Extracted the `mos_trapping` table as the base dataset, filtering for records where traps were successfully deployed (`trapHours > 0`).
#' 2. Downward joined the `mos_sorting` and `mos_expertTaxonomistIDProcessed` tables to retain empty traps (zero-catch) for sampling effort tracking.
#' 3. Replaced 0 counts with `NA` where no `taxonID` was provided by the expert taxonomist.
#' 4. Handled split-vial laboratory processing by summing counts of duplicate `taxonID`s within the same `sampleID`, while keeping `sex` distinct.
#' 5. Calculated estimated total individuals using the modern NEON `proportionIdentified` column. For older archived data, this was calculated backward-compatibly using `subsampleWeight / totalWeight`.
#' 6. Filtered out compromised samples (`sampleCondition != "No known compromise"`) and coarse taxonomic identifications (`taxonRank == "family"`).
#' 7. Calculated final abundance (`value`) as the estimated total individuals divided by `trapHours`.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]). We retained records without a `taxon_id` (where `value` is `NA`) to preserve sampling effort for traps that caught zero mosquitoes.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples, usually it has location and date information.
#' - `subsampleID`: Unique identifier associated with each subsample per sampleID.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:  Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name` (abundance). `NA` represents a trap that caught zero target taxa.
#' - `unit`: Unit of the values in the `value` column ('count per trap hour').
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location;
#' 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `proportionIdentified`: Proportion of the total catch that was subsampled and identified.
#' - `release`: Version of data release by NEON.
#' - `remarks_sorting`: Technician notes; free text comments accompanying the sorting record.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' - `sex`: M for male, F for female, U for unknown.
#' - `sortDate`: Date sample was sorted.
#' - `trapHours`: Number of hours between trap setting and collecting events.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Natalie Robinson, Daijiang Li
#'
"data_mosquito"
