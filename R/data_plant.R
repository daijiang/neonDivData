#' Plant survey data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10058.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10058.001>
#'
#' The detailed design of NEON plant survey can be found in [Barnett et al. 2019](https://esajournals.onlinelibrary.wiley.com/doi/10.1002/ecs2.2603).
#' Here, we:
#'
#' 1. Removed 1 m^2 data with `targetTaxaPresent = N`
#' 2. Removed rows missing values for plotID, subplotID, boutNumber, endDate, and/or taxonID
#' 3. Removed duplicate taxa between nested subplots (each taxon should be represented once for the bout/plotID/year). For example, if a taxon/date/bout/plot combo is present in 1 m^2 data, remove from 10 m^2 and above
#' 4. Stacked species occurrence from different scales into a long data frame. Therefore,
#'     + to get the species list at 1 m^2 scale, we need all the data with `sample_area_m2 == 1` (e.g. `dplyr::filter(plants, sample_area_m2 == 1)`); the unique sample unit id can then be generated with `paste(plants$plotID, plants$subplot_id, plants$subsubplot_id, sep = "_")`
#'     + to get the species list at 10 m^2 scale, we need all the data with `sample_area_m2 <= 10` (e.g. `dplyr::filter(plants, sample_area_m2 <= 10)`); the unique sample unit id can then be generated with `paste(plants$plotID, plants$subplot_id, plants$subsubplot_id, sep = "_")`
#'     + to get the species list at 100 m^2 scale, we need use the whole data set since the maximum value of `sample_area_m2` is 100 (i.e. a 10 m by 10 m subplot); the unique sample unit id can then be generated with `paste(plants$plotID, plants$subplot_id, sep = "_")`
#'     + to get the species list at 400 m^2 scale (i.e. one plot with four subplots), we need aggregate the data at `plotID` level (the sample unit is the plot now).
#'
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of unique samples, usually it has location and date information.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen. Values are 'genus', 'species', 'speciesGroup', 'subSpecies', or 'variety.' Species accounts for the majority of the entries. _Higher ranks have already been filtered out_ because we think they are too vague for biodiversity research.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`. If the individual was observed out of 1 square meter subplots, the value will be `NA`.
#' - `unit`: Unit of the values in the `value` column.
#' - `presence_absence`: All 1s since every record represent a species.
#' - `subplotID`: This is the NEON provided subplot ID in the format of `subplot_id`, then `subsubplot_id` and 1 or 10 (m^2); if the sampling unit is 100 m^2, the values are 31, 32, 40, and 41.
#' - `subplot_id`: Subplot ID; each plot normally has four 100 m^2 subplots (31, 32, 40, 41).
#' - `subsubplot_id`: Subsubplot ID (1, 2, 3, 4) for sampling units at 1 m^2 or 10 m^2.
#' - `boutNumber`: Number of sampling bout, most sites sample only 1 bout.
#' - `nativeStatusCode`: Whether the species is a native or non-native species. 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location; 'N': Native; 'N?': Probably Native; 'I': Introduced; 'I?': Probably Introduced; 'NI': Native and Introduced, some infrataxa are native and others are introduced; 'NI?': Probably Native and Introduced, some infrataxa are native and others are introduced; 'UNK': Status unknown.
#' - `heightPlantOver300cm`: Indicator of whether individuals of the species in the sample are taller than 300 cm.
#' - `heightPlantSpecies`: Ocular estimate of the height (centimeter) of the plant species (if height is < 300 cm).
#' - `release`: Version of data release by NEON.
#' - `sample_area_m2`: The area of the sampling unit that the observed plant was located in. Potential values are 1, 10, or 100.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#'
#'
#' @source <https://data.neonscience.org>
#' @references Barnett, D.T., Adler, P.B., Chemel, B.R., Duffy, P.A., Enquist, B.J., Grace, J.B., Harrison, S., Peet, R.K., Schimel, D.S., Stohlgren, T.J. and Vellend, M., 2019. The plant diversity sampling design for the national ecological observatory network. Ecosphere, 10(2), p.e02603.
#' @author Daijiang Li, Michael Just
#'
"data_plant"

#' @importFrom tibble tibble
NULL


