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
#' @note  Details of locations (e.g. latitude/longitude coordinates can be found in [neon_locations]).
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `namedLocation`: Name of the measurement location in the NEON database.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `subplotID`: This is the NEON provided subplot ID in the format of `subplot_id`, then `subsubplot_id` and 1 or 10 (m^2); if the sampling unit is 100 m^2, the values are 31, 32, 40, and 41.
#' - `boutNumber`: Number of sampling bout, most sites sample only 1 bout.
#' - `year`: Observation year.
#' - `endDate`: The end date-time or interval during which an event occurred.
#' - `taxonID`: Species code, based on one or more sources. Mostly from the USDA PLANTS Database.
#' - `scientificName`: Scientific name, associated with the taxonID. This is the name of the lowest level taxonomic rank that can be determined.
#' - `taxonRank`: The rank of `scientificName`: 'genus', 'species', 'speciesGroup', 'subSpecies', or 'variety.' Species accounts for the majority of the entries. _Higher ranks have already been filtered out_ because we think they are too vague for biodiversity research.
#' - `family`: The family of the species.
#' - `nativeStatusCode`: Whether the species is a native or non-native species. 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location; 'N': Native; 'N?': Probably Native; 'I': Introduced; 'I?': Probably Introduced; 'NI': Native and Introduced, some infrataxa are native and others are introduced; 'NI?': Probably Native and Introduced, some infrataxa are native and others are introduced; 'UNK': Status unknown.
#' - `percentCover`: Ocular estimate of cover of the index (e.g., species) as a percent within 1 m^2 subsubplots.
#' - `heightPlantOver300cm`: Indicator of whether individuals of the species in the sample are taller than 300 cm.
#' - `heightPlantSpecies`: Ocular estimate of the height (centimeter) of the plant species (if height is < 300 cm).
#' - `sample_area_m2`: The area of the sampling unit that the observed plant was located in.
#' - `subplot_id`: Subplot ID; each plot normally has four 100 m^2 subplots (31, 32, 40, 41).
#' - `subsubplot_id`: Subsubplot ID (1, 2, 3, 4) for sampling units at 1 m^2 or 10 m^2.
#'
#' @source <https://data.neonscience.org>
#' @references Barnett, D.T., Adler, P.B., Chemel, B.R., Duffy, P.A., Enquist, B.J., Grace, J.B., Harrison, S., Peet, R.K., Schimel, D.S., Stohlgren, T.J. and Vellend, M., 2019. The plant diversity sampling design for the national ecological observatory network. Ecosphere, 10(2), p.e02603.
"data_plant"

#' @importFrom tibble tibble
NULL


