#' Fish survey data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.20107.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.20107.001>.
#'
#' We downloaded all fish data (i.e., fsh_perPass, fsh_fieldData, fsh_bulkCount, fsh_perFish), including the complete taxon table for fish, for both stream and lake sites surveyed via the NEON API. We joined the ‘fsh_perPass’, ‘fsh_fieldData’, and ‘fsh_bulkCount’ datasets to produce a table with bulk-processed data that merged ‘fsh_perPass’, ‘fsh_fieldData’, and ‘fsh_perFish’ to concatenate individual-level data. Finally both individual-level and bulk-processed datasets were appended into a single table. For each finer-resolution taxon in the individual-level dataset, we considered the relative abundance as one since each row represented a single individual fish. Whenever possible, we substituted missing data by cross-referencing other data columns, omitted completely redundant data columns, and retained records with species-level taxonomic resolution. For the appended dataset, we also calculated the relative abundance for each species per sampling reach or segment at a given site. To calculate species-specific catch per unit effort ('catch_per_effort'), we normalized the relative abundance by either average electrofishing time (i.e., ‘efTime’, ‘efTime2’) or trap deployment time (i.e., the difference between ‘netEndTime’ and ‘netSetTime’). In this case, we assumed that size of the traps used, water depths, number of netters used, and the reach lengths (a significant proportion of bouts had reach lengths missing) to be comparable across different sampling reaches and segments.
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `siteID`: NEON site code.
#' - `namedLocation`:	Name of the measurement location in the NEON database.
#' - `reachID`:	An identifier for the set of information associated with the reach.
#' - `eventID`:	An identifier for the set of information associated with the event,
#' which includes information about the place and time of the event.
#' - `samplerType`:	Type of sampler used to collect the sample.
#' - `taxonID`: Species code, based on one or more sources.
#' - `scientificName`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `catch_per_effort`: Number of fish catched per hour.
#' - `number_of_fish`: Number of fish catched.
#' - `n_obs`: Number of observations.
#' - `startDate`: The start date-time or interval during which an event occurred.
#' - `netSetTime`: Time the net was set.
#' - `netEndTime`: Time the net was pulled.
#' - `netDeploymentTime`:	Total time of deployment of the net in hour.
#' - `netLength`: Length of the net (meter).
#' - `netDepth`:	Deployment depth of the net (meter).
#' - `fixedRandomReach`:	An indication of whether the reach is fixed or random.
#' - `measuredReachLength`:	The length of the reach as measured by the technicians when the reach was established.
#' - `efTime`: Operational time of the electrofisher in second.
#' - `efTime2`:	Operational time of the electrofisher for the second electrofisher in second.
#' - `passStartTime`: The start time of the pass.
#' - `passEndTime`:	The end time of the pass.
#'  - `passNumber`:	Number of the sampling pass within a reach.
#'  - `year`: Observation year.
#'  - `month`: Observation month.
#'  - `mean_efishtime`: Average efish time in second.
#' @source <https://data.neonscience.org>
"data_fish"
