#' Breeding landbird point counts data
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10003.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10003.001>.
#'
#' The bird data provided by NEON is already well organized. We only removed some columns that likely won't be used in biodiversity studies. Users may want to remove records with `targetTaxaPresent == "N"` (such records were reserved here to provide information about sampling effort) and those with species identified above genus levels.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `pointID`: Identifier for a point location.
#' - `startDate`: The start date-time or interval during which an event occurred.
#' - `pointCountMinute`: The minute of sampling within the point count period.
#' - `targetTaxaPresent`: Indicator of whether the sample contained individuals of the target taxa.
#' - `taxonID`: Species code, based on one or more sources.
#' - `scientificName`: Scientific name, associated with the taxonID. This is the name of the lowest level taxonomic rank that can be determined.
#' - `taxonRank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `vernacularName`: A common or vernacular name.
#' - `family`: The scientific name of the family in which the taxon is classified.
#' - `nativeStatusCode`: The process by which the taxon became established in the location.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location;
#' 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `observerDistance`: Radial distance between the observer and the individual(s) being observed (unit: meter).
#' - `detectionMethod`: How the individual(s) was (were) first detected by the observer.
#' - `visualConfirmation`: Whether the individual(s) was (were) seen after the initial detection.
#' - `sexOrAge`: Sex of individual if detectable, age of individual if individual can not be sexed.
#' - `clusterSize`: Number of individuals in a cluster (a group of individuals of the same species).
#' - `clusterCode`: Alphabetic code (A-Z) linked to clusters (groups of individuals of the same species) spanning multiple records. It is only used to link clusters that take up multiple lines on the data sheet.
#' - `startCloudCoverPercentage`: Observer estimate of percent cloud cover at start of sampling.
#' - `endCloudCoverPercentage`: Observer estimate of percent cloud cover at end of sampling.
#' - `startRH`: Relative humidity as measured by handheld weather meter at the start of sampling.
#' - `endRH`: Relative humidity as measured by handheld weather meter at the end of sampling.
#' - `observedHabitat`: Observer assessment of dominant habitat at the sampling point at sampling time.
#' - `observedAirTemp`: The air temperature (celsius) measured with a handheld weather meter.
#' - `kmPerHourObservedWindSpeed`: The average wind speed measured with a handheld weather meter, in kilometers per hour.
#'
#' @author Daijiang Li
#'
"data_bird"
