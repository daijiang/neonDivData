#' Fish survey data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20107.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20107.001>.
#' Sampling methods and the design are detailed here: https://www.neonscience.org/data-collection/fish and https://www.neonscience.org/observatory/observatory-blog/one-fish-two-fish-learn-how-neon-samples-fish
#' We downloaded all fish data (i.e., fsh_perPass, fsh_fieldData, fsh_bulkCount, fsh_perFish), including the complete taxon table for fish, for both stream and lake sites surveyed via the NEON API. We joined the ‘fsh_perPass’, ‘fsh_fieldData’, and ‘fsh_bulkCount’ datasets to produce a table with bulk-processed data that merged ‘fsh_perPass’, ‘fsh_fieldData’, and ‘fsh_perFish’ to concatenate individual-level data. Finally both individual-level and bulk-processed datasets were appended into a single table. If ‘fsh_bulkCount’ dataset does not have a ‘taxonRank’ column, we added that information based on data stored in ‘scientificName’ column particularly to separate species level identifications. For each finer-resolution taxon in the individual-level dataset, we considered the relative abundance as one since each row represented a single individual fish. Whenever possible, we substituted missing data by cross-referencing other data columns, omitted completely redundant data columns, and retained records with species-level taxonomic resolution. For the appended dataset, we also calculated the relative abundance for each species per sampling reach or segment at a given site. To calculate species-specific catch per unit effort ('catch_per_effort'), we normalized the relative abundance by either average electrofishing time (i.e., ‘efTime’, ‘efTime2’) or trap deployment time (i.e., the difference between ‘netEndTime’ and ‘netSetTime’). In this case, we assumed that size of the traps used, water depths, number of netters used, and the reach lengths (a significant proportion of bouts had reach lengths missing) to be comparable across different sampling reaches and segments.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `pointID`: NEON sampling point identifier.
#' - `unique_sample_id`: Identity of unique samples, usually it has location and date information.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`.
#' - `unit`: Unit of the values in the `value` column.
#' - `reachID`: An identifier for the set of information associated with the reach.
#' - `samplerType`: Type of sampler used to collect the sample.
#' - `fixedRandomReach`:	An indication of whether the reach is fixed or random.
#' - `measuredReachLength`:	The length of the reach as measured by the technicians when the reach was established (meters).
#' - `efTime`: Operational time of the electrofisher (second).
#' - `passStartTime`: The start time of the pass.
#' - `passEndTime`:	The end time of the pass.
#' - `mean_efishtime`: Average efish time (in second).
#' - `release`:	Version of data release by NEON.
#' - `netSetTime`: Time the net was set.
#' - `netEndTime`: Time the net was pulled.
#' - `netDeploymentTime`:	Total time of deployment of the net (hours).
#' - `netLength`: Length of the net (meter).
#' - `netDepth`:	Deployment depth of the net (meter).
#' - `efTime2`:	Operational time of the electrofisher for the second electrofisher (second).
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @source <https://data.neonscience.org>; https://data.neonscience.org/data-products/DP1.20107.001#collectionAndProcessing
#' #' @referencesJensen, Jensen, B., S. Parker, and C. Scott. 2017. Neon user guide to fish electrofishing, gill netting, and fyke netting counts (NEON.DP1.20107). NEON, National Ecological Observatory Network, Boulder, CO, USA.
#'
#' @author Stephanie Parker, Thilina Surasinghe
#'
 "data_fish"
