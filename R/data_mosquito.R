#' Mosquitoes sampled from CO2 traps
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10043.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10043.001>.
#'
#' Here, we:
#' 1. Removed trapping records that had no `collectDate`, `eventID`, `namedLocation`, and/or `sampleID`
#' 2. Removed sorting records that had no `collectDate`, `sampleID`, `namedLocation`, and/or `subsampleID`
#' 3. Removed archive records that had no `startCollectDate`, `archiveID`, and/or `namedLocation`
#' 4. Removed expert taxonomy records that had no `collectDate`, `subsampleID`, and/or `namedLocation`
#' 5. Verified there were no duplicated trapping, sorting, or archive records
#' 6. Verified there were no trapping `sampleID` values missing from the sorting table
#' 7. Verified there were no sorting `subsampleID` values missing from the expert taxonomist table
#' 8. Converted blanks to NA throughout the datasets
#' 9. Convert 0 to NA for unidentified samples - where `individualCount` in the expert taxonomist table was 0 and there was no listed `taxonID`
#' 10. Left-joined the trapping table to the sorting table and verified barcode consistency between tables
#' 11. Left-joined the expert taxonomy table to the trapping/sorting table and verified barcode and lab name consistency between tables
#' 12. Renamed columns and added estimated total individuals as: number individuals iD'ed * (total subsample weight/ subsample weight)
#' 13. Left-joined archive table and verified barcode consistency between tables
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `unique_sample_id`: Identity of unique samples, usually it has location and date information.
#' - `sampleID`: Identifier for sample.
#' - `subsampleID`: Unique identifier associated with each subsample per sampleID.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`.
#' - `unit`: Unit of the values in the `value` column.
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location;
#' 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `release`: Version of data release by NEON.
#' - `samplingProtocolVersion`: The NEON document number and version where detailed information regarding the sampling method used is available; format 'NEON.DOC.######vX'.
#' - `sex`: M for male, F for female, U for unknown.
#' - `sortDate`: Date sample was sorted.
#' - `subsampleWeight`:	Weight of subsample in gram.
#' - `totalWeight`: Weight of entire sample in gram.
#' - `trapHours`: Number of hours between trap setting and collecting events.
#' - `weightBelowDetection`: Notes regarding the weight relative to scale detection limit.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Natalie Robinson
#'
#'
"data_mosquito"
