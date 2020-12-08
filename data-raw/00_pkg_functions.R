# Packages used
if(!require(xfun)) install.packages("xfun")
if(!require(neonUtilities)) devtools::install_github("NEONScience/NEON-utilities/neonUtilities")
xfun::pkg_attach2(c("tidyverse", "neonUtilities", "lubridate"))
# library(googledrive)
# remotes::install_github("EDIorg/ecocomDP")
# remotes::install_github("EDIorg/EMLassemblyline", dependencies = TRUE, upgrade = "never")
# library(ecocomDP)
'%>%' <- dplyr::`%>%`

essential_cols = c(
  "siteID", "plotID", "decimalLatitude", "decimalLongitude",
  "taxonRank", "taxonID", "scientificName", "family", "nativeStatusCode"
)


map_neon_data_to_ecocomDP.ALGAE <- function(
  neon.data.product.id = "DP1.20166.001",
  ...){

  # Authors:

  # get all tables
  all_tabs_in <- neonUtilities::loadByProduct(
    # hard coded arguments
    dpID = neon.data.product.id,
    check.size = FALSE,

    # dots for passing user input
    ...

    # # required input from users
    # site = c("MAYF", "PRIN"),
    # startdate = "2016-1",
    # enddate = "2018-11",

    # # optional input from users
    # avg = "all",
    # nCores = 1,
    # forceParallel = FALSE,
  )

  # saveRDS(all_tabs_in, "~/Documents/allTabs_algae.rds")
  # all_tabs_in = readRDS("~/Documents/allTabs_algae.rds")

  # tables needed for ALGAE to populate the ecocomDP tables
  if("alg_fieldData" %in% names(all_tabs_in)){
    alg_field_data <- tibble::as_tibble(all_tabs_in$alg_fieldData)
  }else{
    # alg_field_data <- data.frame()
    # if no data, return an empty list
    warning(paste0(
      "WARNING: No field data available for NEON data product ",
      neon.data.product.id, " for the dates and sites selected."))
    return(list())
  }


  if("alg_taxonomyProcessed" %in% names(all_tabs_in)){
    alg_tax_long <- tibble::as_tibble(all_tabs_in$alg_taxonomyProcessed)
  }else{
    # alg_tax_long <- data.frame()
    # if no data, return an empty list
    warning(paste0(
      "WARNING: No taxon count data available for NEON data product ",
      neon.data.product.id, " for the dates and sites selected."))
    return(list())
  }


  if("alg_biomass" %in% names(all_tabs_in)){
    alg_biomass <- tibble::as_tibble(all_tabs_in$alg_biomass) %>%
      dplyr::mutate(estBSVolume = preservativeVolume + labSampleVolume) %>%
      dplyr::filter(analysisType == 'taxonomy')
  }else{
    # if no data, return an empty list
    warning(paste0(
      "WARNING: Missing required data for calculating taxon densities for NEON data product ",
      neon.data.product.id, " for the dates and sites selected."))
    return(list())
  }


  #Observation table

  #join algae biomass and taxonomy data

  # Note that observational data are in the tax table returned by the lab,
  # however, we need "fieldSampleVolume" from the biomass table to standardize
  # algal counts returned by the lab. Thus we"re joining tables here by sampleID,
  # but only keeping sampleID, parentSampleID, and fieldSampleVolume from the biomass table.

  alg_tax_biomass <- alg_biomass %>%
    dplyr::select(parentSampleID, sampleID, fieldSampleVolume, estBSVolume) %>%
    dplyr::distinct() %>%
    dplyr::left_join(alg_tax_long, by = "sampleID") %>%
    dplyr::mutate(perBSVol =
                    dplyr::case_when(
                      perBottleSampleVolume == 0 ~ estBSVolume,
                      perBottleSampleVolume > 0 ~ perBottleSampleVolume)) %>%
    dplyr::distinct()


  # only keep cols in alg_field_data that are unique to that table
  field_data_names_to_keep <- c("parentSampleID",
                                dplyr::setdiff(names(alg_field_data),
                                               names(alg_tax_biomass)))

  alg_field_data <- alg_field_data[, field_data_names_to_keep] %>%
    dplyr::distinct()

  # create the observation table by joining with alg_field_data
  data_algae <- alg_tax_biomass %>%
    dplyr::left_join(alg_field_data, by = "parentSampleID") %>%
    dplyr::filter(algalParameterUnit == "cellsPerBottle")%>%
    dplyr::mutate(
      density = dplyr::case_when(
        algalSampleType %in% c("seston", "phytoplankton") ~ algalParameterValue / perBSVol,
        TRUE ~ (algalParameterValue / perBSVol) * (fieldSampleVolume / benthicArea * 10000)
        # add phytoplankton back in when applicable
      ),
      cell_density_standardized_unit = dplyr::case_when(
        algalSampleType %in% c("phytoplankton","seston") ~ "cells/mL",
        TRUE ~ "cells/m2"))

  table(data_algae$sampleCondition)
  table(data_algae$targetTaxaPresent) # all Y

  data_algae = dplyr::filter(data_algae, sampleCondition == "Condition OK")[, c("domainID", "siteID",
                                                                                "sampleID", "eventID", "namedLocation", "aquaticSiteType",
                                                                                "decimalLatitude", "decimalLongitude", "geodeticDatum",
                                                                                "coordinateUncertainty", "elevation", "elevationUncertainty",
                                                                                "habitatType", "acceptedTaxonID", "scientificName", "family", "taxonRank",
                                                                                "identificationReferences",
                                                                                "collectDate", "density", "cell_density_standardized_unit",
                                                                                "algalParameterValue",
                                                                                # "algalParameterUnit",
                                                                                "algalParameter",
                                                                                "perBSVol",
                                                                                "fieldSampleVolume",
                                                                                "algalSampleType",
                                                                                "benthicArea"
  )] %>%
    dplyr::distinct()

  table(data_algae$taxonRank)
  # table(data_algae$algalParameterUnit)
  table(data_algae$algalParameter)
  table(data_algae$cell_density_standardized_unit)

  return(data_algae)
}


map_neon_data_to_ecocomDP.BEETLE <- function(
  neon.data.product.id = "DP1.10022.001",
  ...){
  # author: Kari Norman

  # download data
  beetles_raw <- neonUtilities::loadByProduct(dpID = neon.data.product.id,
                                              ...)

  # helper function to calculate mode of a column/vector
  Mode <- function(x) {
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
  }

  ### Clean Up Sample Data ###

  # start with the fielddata table, which describes all sampling events
  data_beetles <- tibble::as_tibble(beetles_raw$bet_fielddata) %>%
    dplyr::select(sampleID, domainID, siteID, namedLocation,
                  trapID, setDate, collectDate, eventID, trappingDays) %>%
    # eventID's are inconsistently separated by periods, so we remove them
    dplyr::mutate(eventID = stringr::str_remove_all(eventID, "[.]")) %>%
    #calculate a new trapdays column
    dplyr::mutate(trappingDays = lubridate::interval(lubridate::ymd(setDate),
                                                     lubridate::ymd(collectDate)) %/%
                    lubridate::days(1))

    #Find the traps that have multiple collectDates/bouts for the same setDate
    #need to calculate their trap days from the previous collectDate, not the setDate
  adjTrappingDays <- data_beetles %>%
    select(namedLocation, trapID, setDate, collectDate, trappingDays, eventID) %>%
    group_by_at(vars(-collectDate, -trappingDays, -eventID)) %>%
    filter(n_distinct(collectDate) > 1) %>%
    group_by(namedLocation, trapID, setDate) %>%
    mutate(diffTrappingDays = trappingDays - min(trappingDays)) %>%
    mutate(adjTrappingDays = case_when(
      diffTrappingDays == 0 ~ trappingDays,
      TRUE ~ diffTrappingDays)) %>%
    select(-c(trappingDays, diffTrappingDays))

  data_beetles <- data_beetles %>%
    #update with adjusted trapping days where needed
    left_join(adjTrappingDays) %>%
    mutate(trappingDays = case_when(
      !is.na(adjTrappingDays) ~ adjTrappingDays,
      TRUE ~ trappingDays
    )) %>%
    select(-adjTrappingDays, -setDate) %>%
    # for some eventID's (bouts) collection happened over two days,
    # change collectDate to the date that majority of traps were collected on
    dplyr::group_by(eventID) %>%
    dplyr::mutate(collectDate = Mode(collectDate)) %>%
    dplyr::ungroup() %>%
    # there are also some sites for which all traps were set and collect on the same date, but have multiple eventID's
    # we want to consider that as all one bout so we create a new ID based on the site and collectDate
    tidyr::unite(boutID, siteID, collectDate, remove = FALSE) %>%
    dplyr::select(-eventID) %>%
    # join with bet_sorting, which describes the beetles in each sample
    dplyr::left_join(beetles_raw$bet_sorting %>%
                       # only want carabid samples, not bycatch
                       dplyr::filter(sampleType %in% c("carabid", "other carabid")) %>%
                       dplyr::select(sampleID, subsampleID, sampleType, taxonID,
                                     scientificName, taxonRank, identificationReferences,
                                     individualCount),
                     by = "sampleID")

  ### Clean up Taxonomy of Samples ###

  #Some samples were pinned and reidentified by more expert taxonomists, replace taxonomy with their ID's (in bet_parataxonomist) where available
  data_pin <- data_beetles %>%
    dplyr::left_join(beetles_raw$bet_parataxonomistID %>%
                       dplyr::select(subsampleID, individualID, taxonID, scientificName,
                                     taxonRank) %>%
                       dplyr::left_join(dplyr::distinct(dplyr::select(beetles_raw$bet_expertTaxonomistIDProcessed, taxonID, family))),
                     by = "subsampleID") %>%
    dplyr::mutate_if(is.factor, as.character) %>%
    dplyr::mutate(taxonID = ifelse(is.na(taxonID.y), taxonID.x, taxonID.y)) %>%
    dplyr::mutate(taxonRank = ifelse(is.na(taxonRank.y), taxonRank.x, taxonRank.y)) %>%
    dplyr::mutate(scientificName = ifelse(is.na(scientificName.y), scientificName.x, scientificName.y)) %>%
    dplyr::mutate(identificationSource = ifelse(is.na(scientificName.y), "sort", "pin")) %>%
    dplyr::select(-ends_with(".x"), -ends_with(".y"))

  # some subsamples weren't fully ID'd by the pinners, so we have to recover the unpinned-individuals
  lost_indv <- data_pin %>%
    dplyr::filter(!is.na(individualID)) %>%
    dplyr::group_by(subsampleID, individualCount) %>%
    dplyr::summarise(n_ided = dplyr::n_distinct(individualID)) %>%
    dplyr::filter(n_ided < individualCount) %>%
    dplyr::mutate(unidentifiedCount = individualCount - n_ided) %>%
    dplyr::select(subsampleID, individualCount = unidentifiedCount) %>%
    dplyr::left_join(dplyr::select(data_beetles, -individualCount), by = "subsampleID") %>%
    dplyr::mutate(identificationSource = "sort")

  # add unpinned-individuals back to the pinned id's, adjust the individual counts so pinned individuals have a count of 1
  data_pin <- data_pin %>%
    dplyr::mutate(individualCount = ifelse(identificationSource == "sort", individualCount, 1)) %>%
    dplyr::bind_rows(lost_indv)


  #Join expert ID's to beetle dataframe
  data_expert <- dplyr::left_join(data_pin,
                                  dplyr::select(beetles_raw$bet_expertTaxonomistIDProcessed,
                                                individualID,taxonID,scientificName,
                                                taxonRank),
                                  by = 'individualID', na_matches = "never") %>%
    dplyr::distinct()

  #Update with expert taxonomy where available
  data_expert <- data_expert %>%
    dplyr::mutate_if(is.factor, as.character) %>%
    dplyr::mutate(taxonID = ifelse(is.na(taxonID.y), taxonID.x, taxonID.y)) %>%
    dplyr::mutate(taxonRank = ifelse(is.na(taxonRank.y), taxonRank.x, taxonRank.y)) %>%
    dplyr::mutate(scientificName = ifelse(is.na(scientificName.y), scientificName.x, scientificName.y)) %>%
    dplyr::mutate(identificationSource = ifelse(is.na(scientificName.y), identificationSource, "expert")) %>%
    dplyr::select(-ends_with(".x"), -ends_with(".y"))

  #Get raw counts table
  beetles_counts <- data_expert %>%
    dplyr::select(-c(subsampleID, sampleType, identificationSource, individualID)) %>%
    dplyr::group_by_at(dplyr::vars(-individualCount)) %>%
    dplyr::summarise(count = sum(individualCount)) %>%
    dplyr::ungroup() %>%
    dplyr::distinct()

  # get relevant location info from the data
  table_location_raw <- beetles_raw$bet_fielddata %>%
    dplyr::select(domainID, siteID, plotID, namedLocation, plotType, nlcdClass, decimalLatitude,
                  decimalLongitude, geodeticDatum, coordinateUncertainty,
                  elevation, elevationUncertainty) %>%
    dplyr::distinct()


  data_beetle <-  dplyr::left_join(beetles_counts, table_location_raw,
                                 by = c("domainID", "siteID", "namedLocation"))
  all(paste0(data_beetle$plotID, ".basePlot.bet") == data_beetle$namedLocation)
  # data_beetle = dplyr::select(data_beetle, -namedLocation)
  return(data_beetle)
}

map_neon_data_to_ecocomDP.FISH <- function(
  neon.data.product.id = "DP1.20107.001",
  ...){
  # Authors: Stephanie Parker, Thilina Surasinghe (sparker@battelleecology.org, tsurasinghe@bridgew.edu)

  # get taxon table from API, may take a few minutes to load
  # Fish electrofishing, gill netting, and fyke netting counts
  # http://data.neonscience.org/data-product-view?dpCode=DP1.20107.001
  full_taxon_fish <- neonUtilities::getTaxonTable(taxonType = 'FISH', recordReturnLimit = NA, stream = "true")

  # -- make ordered taxon_rank list for a reference (subspecies is smallest rank, kingdom is largest)

  # -- make ordered taxon_rank list for a reference (subspecies is smallest rank, kingdom is largest)
  # a much simple table with useful levels of taxonomic resolution;
  # this might not be needed if taxon rank is extracted  from scientific names using stringr functions
  taxon_rank_fish <- c('superclass', 'class', 'subclass', 'infraclass', 'superorder',
                       'order', 'suborder', 'infraorder', 'section', 'subsection',
                       'superfamily', 'family', 'subfamily', 'tribe', 'subtribe', 'genus',
                       'subgenus','speciesGroup','species','subspecies') %>% rev() # get the reversed version

  # get data FISH via api -- will take a while --  package = "basic" is also possible
  all_fish <- neonUtilities::loadByProduct(dpID = neon.data.product.id,
                                           package = "expanded", avg = "all", ...)
  # The object returned by loadByProduct() is a named list of data frames.
  # To work with each of them, select them from the list using the $ operator.

  # this joins reach-level data, you can just join by any two of these, and the results are the same, dropping the unique ID
  # join field data table with the pass tables from all_fish
  fsh_dat1 <- dplyr::left_join(x = all_fish$fsh_perPass, y = all_fish$fsh_fieldData, by = c('reachID', "siteID")) %>%
    dplyr::filter(is.na(samplingImpractical) | samplingImpractical == "") %>% #remove records where fish couldn't be collected, both na's and blank data
    tibble::as_tibble()

  # get rid of dupe col names and .x suffix
  fsh_dat1 <- fsh_dat1[, !grepl('\\.y', names(fsh_dat1))]
  names(fsh_dat1) <- gsub('\\.x', '', names(fsh_dat1))

  # add individual fish counts; perFish data = individual level per each specimen captured
  # this joins reach-level field data with individual fish measures
  fsh_dat_indiv <- dplyr::left_join(all_fish$fsh_perFish, fsh_dat1, by = "eventID") %>%
    tibble::as_tibble()

  # get rid of dupe col names and .x suffix
  fsh_dat_indiv <- fsh_dat_indiv[, !grepl('\\.y', names(fsh_dat_indiv))]
  names(fsh_dat_indiv) <- gsub('\\.x', '', names(fsh_dat_indiv))

  # fill in missing reachID from event ID
  fsh_dat_indiv$reachID <- ifelse(is.na(fsh_dat_indiv$reachID),
                                  substr(fsh_dat_indiv$eventID, 1, 16),
                                  fsh_dat_indiv$reachID)


  # add bulk fish counts; bulk count data = The number of fish counted during bulk processing in each pass
  # this will join all the reach-level field data with the species data with bulk counts
  fsh_dat_bulk <- dplyr::left_join(all_fish$fsh_bulkCount, fsh_dat1, by = "eventID") %>%
    tibble::as_tibble()

    # get rid of dupe col names and .x suffix
  fsh_dat_bulk <- fsh_dat_bulk[, !grepl('\\.y', names(fsh_dat_bulk))]
  names(fsh_dat_bulk) <- gsub('\\.x', '', names(fsh_dat_bulk))

  #fill in missing reachID
  fsh_dat_bulk$reachID <- ifelse(is.na(fsh_dat_bulk$reachID),
                                 substr(fsh_dat_bulk$eventID, 1, 16),
                                 fsh_dat_bulk$reachID)

  # combine indiv and bulk counts
  fsh_dat <- dplyr::bind_rows(fsh_dat_indiv, fsh_dat_bulk)

  # add count = 1 for indiv data
  # before row_bind, the indiv dataset did not have a col for count
  # after bind, the bulk count col has "NAs" need to add "1", since indiv col has individual fish per row
  fsh_dat$count <- ifelse(is.na(fsh_dat$bulkFishCount), 1, fsh_dat$bulkFishCount)


  # in case the bulk count data set does not have a column on taxonomic rank, as such, need to add it here.
  # in scientificName column-- species identified below species level (genus, family, order, phylum)-- appear as sp. or spp.
  # both sp. and spp. identifications should be marked low-res identifications, aka above species level in ranking
  # and exclude from this analyses
  # fsh_dat <- fsh_dat %>%
  #   dplyr::mutate(taxonRank = dplyr::case_when(stringr::str_detect(string = scientificName, pattern = " spp.$") ~ "not_sp_level1",
  #                                              stringr::str_detect(string = scientificName, pattern = " sp.$") ~ "not_sp_level2", TRUE ~ "species"))

  # get all records that have rank <= genus
  fsh_dat_fine <- dplyr::filter(fsh_dat, taxonRank %in% c("species", "subspecies", "genus"))

  # select passes with no fish were caught
  no_fsh <- dplyr::filter(all_fish$fsh_perPass, targetTaxaPresent == "N")

  # all records from fieldData where sampling was done, where sampling was not impractical
  fsh_sampled <- dplyr::filter(all_fish$fsh_fieldData, is.na(samplingImpractical) | samplingImpractical == "")

  #join the no-fish dataset with the field dataset where sampling was done
  no_fsh2 <- dplyr::left_join(x = no_fsh, y = fsh_sampled, by = c("reachID", "siteID", "domainID", "namedLocation"))

  # get rid of dupe col names and .x suffix
  no_fsh2 <- no_fsh2[, !grepl('\\.y', names(no_fsh2))]
  names(no_fsh2) <- gsub('\\.x', '', names(no_fsh2))

  # fill in missing reachID from event ID
  no_fsh2$reachID <- ifelse(is.na(no_fsh2$reachID),
                            substr(no_fsh2$eventID, 1, 16),
                            no_fsh2$reachID)

  # add a count variables, which should be zero since these are the reaches with zero fish captures
  no_fsh2 <- no_fsh2 %>% dplyr::mutate(count =  rep_len(0, length.out = nrow(no_fsh2)),
                                         scientificName = NA, taxonID = NA) %>%
    dplyr::mutate( dplyr::across(c("scientificName", "taxonID"), ~as.character(.)))

  # join the no_fish sampling sessions to the sampling sessions with fish
  fsh_dat_fine <- dplyr::bind_rows(fsh_dat_fine, no_fsh2)

  # need to convert POSIXct format into as.character and then back to date-time format
  # then, fill in missing site ID info and missing startDate into
  fsh_dat_fine$startDate <- dplyr::if_else(is.na(fsh_dat_fine$startDate),
                                      lubridate::as_datetime(substr(as.character(fsh_dat_fine$passStartTime), 1, 10)), fsh_dat_fine$startDate) # 1-10: number of characters on date
  fsh_dat_fine$siteID <- dplyr::if_else(is.na(fsh_dat_fine$siteID),
                                   substr(fsh_dat_fine$eventID, 1, 4), fsh_dat_fine$siteID) # four characters on site

  # grouping vars for aggregating density measurements
  my_grouping_vars <- c('domainID','siteID','aquaticSiteType','namedLocation',
                        'startDate', 'endDate', 'reachID','eventID','samplerType', 'aquaticSiteType', 'netSetTime', 'netEndTime',
                        'netDeploymentTime', 'netLength', 'netDepth', 'fixedRandomReach','measuredReachLength','efTime', 'efTime2',
                        "passStartTime", "passEndTime", 'netDeploymentTime', 'scientificName', 'taxonID', 'passNumber', 'taxonRank', 'targetTaxaPresent')
  # added a few metrics to quantify catch per unit effort such as 'passNumber', efish time, net deployment time
    # aggregate densities for each species group, pull out year and month from StartDate

  fsh_dat_aggregate <- fsh_dat_fine %>%
    dplyr::select(!!c(all_of(my_grouping_vars), 'count')) %>%
    dplyr::group_by_at(dplyr::vars(all_of(my_grouping_vars))) %>%
    dplyr::summarize(
      number_of_fish = sum(count),
      n_obs = dplyr::n()) %>%
    dplyr::mutate(
      year = startDate %>% lubridate::year(),
      month = startDate %>% lubridate::month()
    ) %>% dplyr::ungroup()

  # some aquaticSiteType are NA, replace NAs if-based wildcarding namedLocation
  # grepl is for wildcarding
  fsh_dat_aggregate$aquaticSiteType <- dplyr::if_else(is.na(fsh_dat_aggregate$aquaticSiteType),
                                                      if_else(grepl("fish.point", fsh_dat_aggregate$namedLocation), 'stream','lake'),
                                                      fsh_dat_aggregate$aquaticSiteType)

  # sampler type is also missing in a few cases, reaplace from eventID, with a wildcard
  fsh_dat_aggregate$samplerType <- dplyr::if_else(is.na(fsh_dat_aggregate$samplerType),
                                                  dplyr::if_else(grepl("e-fisher", fsh_dat_aggregate$eventID), 'electrofisher',
                                                                 dplyr::if_else(grepl("gill", fsh_dat_aggregate$eventID), 'gill net', 'mini-fyke net')),
                                                  fsh_dat_aggregate$samplerType)


  # make sure that e-fish samples have "" or NA for netset and netend times, this will leave actual missing data as na
  # change netset/netend times to a datetime format if needed: lubridate::as_datetime(fsh_xx$netSetTime, format="%Y-%m-%d T %H:%M", tz="GMT")
  ## then calculate the netdeploymenttime (in hours) from netset and netend time
  # to calculate pass duration (in mins) and also calculate average efish time (secs); also if efishtime is zero, --> na's
  data_fish <-
    fsh_dat_aggregate %>% dplyr::mutate(netSetTime = dplyr::if_else(condition = samplerType ==  "electrofisher" | samplerType == "two electrofishers",
                                                                    true = lubridate::as_datetime(NA), false = netSetTime),
                                        netEndTime = dplyr::if_else(condition = samplerType ==  "electrofisher" | samplerType == "two electrofishers",
                                                                    true = lubridate::as_datetime(NA), false = netEndTime),
                                netDeploymentTime = dplyr::case_when(samplerType == grepl("electrofish", samplerType) ~ netDeploymentTime,
                                                    is.na(netDeploymentTime) ~ as.numeric(difftime(netEndTime, netSetTime, tz = "GMT", units = "hours")),
                                                                             TRUE ~ netDeploymentTime),
                                        mean_efishtime = base::rowMeans(dplyr::select(., c("efTime", "efTime2")), na.rm = T),
                                        mean_efishtime = dplyr::case_when(mean_efishtime == 0 ~ NA_real_,TRUE ~ mean_efishtime))

  # with the above changes, we have efish time and and net duration to calculate catch per unit effort before moving to wide format
  # CPUE with efish time, calculated by = (total number of fish/average e-fish time in secs * 3600) as fish captured per 1-hr of e-fishing
  # CPUE with gill nets and fyke nets calculated by = (total number of fish/netDeployment time in hours * 24) as fish captured per 1-day-long net deployment of e-fishing
  data_fish <-
    data_fish %>% dplyr::mutate(catch_per_effort = dplyr::if_else(condition = samplerType ==  "electrofisher" | samplerType == "two electrofishers",
                                        true = number_of_fish/mean_efishtime * 3600,
                                              false = dplyr::if_else(condition = samplerType ==  "mini-fyke net" | samplerType == "gill net",
                                                                  true = number_of_fish/netDeploymentTime * 24, false = as.numeric(NA))))

  # make wide for total observations without catch per unit efforts
  fsh_dat_wide_total.obs <- data_fish %>%
    dplyr::group_by(year, month, siteID, namedLocation, reachID, fixedRandomReach, aquaticSiteType, samplerType, targetTaxaPresent ) %>%
    tidyr::pivot_wider(names_from = scientificName, values_from = number_of_fish, names_repair = "unique",  values_fill = 0, names_sep = "_") %>%
    dplyr::select(-n_obs, -catch_per_effort) # these two cols are misleading in this wide format

  # make wide for catch per unit efforts
  fsh_dat_wide_CPUE <- data_fish %>%
    dplyr::group_by(year, month, siteID, namedLocation, reachID, fixedRandomReach, aquaticSiteType, samplerType, targetTaxaPresent) %>%
    tidyr::pivot_wider(names_from = scientificName, values_from = catch_per_effort, names_repair = "unique",  values_fill = 0, names_sep = "_") %>%
    dplyr::select(-n_obs, -number_of_fish)  # these two cols are misleading in this wide format

    setdiff(unique(data_fish$namedLocation), all_fish$fsh_fieldData$namedLocation)
  data_fish = dplyr::left_join(data_fish, unique(dplyr::select(all_fish$fsh_fieldData, namedLocation, decimalLatitude,
                                                        decimalLongitude, coordinateUncertainty, geodeticDatum,
                                                        elevation, elevationUncertainty)),
                        by = "namedLocation")
  data_fish = dplyr::filter(data_fish, !is.na(taxonID))

  setdiff(data_fish$taxonID, fsh_dat$taxonID)
  fsh_taxa = dplyr::select(fsh_dat, taxonID, scientificName, taxonRank, identificationReferences) %>%
    dplyr::distinct() %>%
    dplyr::group_by(taxonID, scientificName) %>%
    dplyr::summarise(taxonRank = unique(taxonRank)[1],
      identificationReferences = paste(unique(identificationReferences),
                                               collapse = "; "), .groups = "drop")
  # filter(fsh_taxa, taxonID == "CAMANO")
  # any(duplicated(fsh_taxa$taxonID))

  data_fish = dplyr::left_join(data_fish, fsh_taxa, by = c("taxonID", "scientificName", "taxonRank"))
  data_fish = dplyr::distinct(data_fish)
  return(data_fish)
}

map_neon_data_to_ecocomDP.MACROINVERTEBRATE <- function(
  neon.data.product.id ="DP1.20120.001",
  ...){
  # Authors:
  # get all tables for this data product for the specified sites in my_site_list, store them in a list called all_tabs
  all_tabs <- neonUtilities::loadByProduct(
    dpID = neon.data.product.id,
    ...)
  # saveRDS(all_tabs, file = "~/Documents/allTabs_macroinvertbrate.rds")
  # all_tabs = readRDS("~/Documents/allTabs_macroinvertbrate.rds")

  # extract the table with the field data from the all_tabs list of tables
  if("inv_fieldData" %in% names(all_tabs)){
    inv_fielddata <- tibble::as_tibble(all_tabs$inv_fieldData)
  }else{
    # if no data, return an empty list
    warning(paste0(
      "WARNING: No field data available for NEON data product ",
      neon.data.product.id, " for the dates and sites selected."))
    return(list())
  }

  # extract the table with the taxonomy data from all_tabls list of tables
  if("inv_taxonomyProcessed" %in% names(all_tabs)){
    inv_taxonomyProcessed <- tibble::as_tibble(all_tabs$inv_taxonomyProcessed)
  }else{
    # if no data, return an empty list
    warning(paste0(
      "WARNING: No taxon count data available for NEON data product ",
      neon.data.product.id, " for the dates and sites selected."))
    return(list())
  }

  # observation ---
  # Make the observation table.
  # start with inv_taxonomyProcessed
  # NOTE: the observation_id = uuid for record in NEON's inv_taxonomyProcessed table
  table(inv_taxonomyProcessed$targetTaxaPresent) # only 10 N
  data_macroinvertebrate <- inv_taxonomyProcessed %>%
    dplyr::filter(targetTaxaPresent == "Y") %>%
    # select a subset of columns from inv_taxonomyProcessed
    dplyr::select(siteID,
                  domainID,
                  sampleID,
                  namedLocation,
                  collectDate,
                  acceptedTaxonID,
                  scientificName,
                  family,
                  taxonRank,
                  identificationReferences,
                  subsamplePercent,
                  individualCount,
                  estimatedTotalCount) %>%
    dplyr::distinct() %>%
    left_join(dplyr::select(inv_fielddata, namedLocation, aquaticSiteType, decimalLatitude, decimalLongitude,
                            coordinateUncertainty, geodeticDatum, elevation, elevationUncertainty) %>%
                dplyr::distinct(), by = "namedLocation")

  return(data_macroinvertebrate)
}


map_neon_data_to_ecocomDP.MOSQUITO <-
  function(neon.data.product.id = "DP1.10043.001", ...){
    #title: download mosquito data and clean
    #author: Natalie Robinson
    #date: 6/08/2020

    mos_allTabs <- neonUtilities::loadByProduct(
      dpID = neon.data.product.id,
      package = "expanded", ...)

    # saveRDS(mos_allTabs, "~/Documents/allTabs_mos.rds")
    # mos_allTabs = readRDS("~/Documents/allTabs_mos.rds")

    # Identify names of desired tables and pull data into corresponding data frames
    tables <- names(mos_allTabs)[grepl('mos', names(mos_allTabs))]

    for (tabs in tables){
      assign(tabs, tibble::as_tibble(mos_allTabs[[tabs]]))
    }

    # Clean data

    # Remove rows with missing critical data
    # Note - a missing mos_trapping:eventID was usually a collection cup with no target taxa present.
    #          In 23 cases, there was no eventID and targetTaxaPresent was 'U' (unknown)

    # Define important data colums
    cols_oi_trap <- c('collectDate', 'eventID', 'namedLocation', 'sampleID')
    cols_oi_sort <- c('collectDate', 'sampleID', 'namedLocation', 'subsampleID')
    cols_oi_arch <- c('startCollectDate', 'archiveID', 'namedLocation')
    cols_oi_exp_proc <- c('collectDate', 'subsampleID', 'namedLocation')

    # Remove rows with missing important data, replacing blank with NA and factors with characters
    mos_trapping <- dplyr::mutate_at(mos_trapping, cols_oi_trap[-1],
                                     list(~dplyr::na_if(as.character(.), ""))) %>%
      tidyr::drop_na(dplyr::all_of(cols_oi_trap)) %>%
      dplyr::mutate_if(is.factor, as.character) %>%
      dplyr::distinct()
    mos_sorting <- dplyr::mutate_at(mos_sorting, cols_oi_sort[-1],
                                    list(~dplyr::na_if(., ""))) %>%
      tidyr::drop_na(dplyr::all_of(cols_oi_sort)) %>%
      dplyr::mutate_if(is.factor, as.character) %>%
      dplyr::distinct()
    mos_archivepooling <- dplyr::mutate_at(mos_archivepooling, cols_oi_arch[-1],
                                           list(~dplyr::na_if(., ""))) %>%
      tidyr::drop_na(dplyr::all_of(cols_oi_arch)) %>%
      dplyr::mutate_if(is.factor, as.character) %>%
      dplyr::distinct()
    mos_expertTaxonomistIDProcessed <-
      dplyr::mutate_at(mos_expertTaxonomistIDProcessed, cols_oi_exp_proc[-1],
                       list(~dplyr::na_if(., ""))) %>%
      tidyr::drop_na(dplyr::all_of(cols_oi_exp_proc)) %>%
      dplyr::mutate_if(is.factor, as.character) %>%
      dplyr::distinct()


    # Look for duplicate sampleIDs
    length(which(duplicated(mos_trapping$sampleID)))  # 0
    length(which(duplicated(mos_sorting$subsampleID))) # 0
    length(which(duplicated(mos_archivepooling$archiveID))) # 0

    # Make sure no "upstream" records are missing primary "downstream" reference
    length(which(!mos_sorting$sampleID %in% mos_trapping$sampleID))  # 3164
    length(which(!mos_trapping$sampleID %in% mos_sorting$sampleID))  # 1700
    length(which(!mos_expertTaxonomistIDProcessed$subsampleID %in% mos_sorting$subsampleID))  # 0

    # Clear expertTaxonomist:individualCount if it is 0 and there is no taxonID. These aren't ID'ed samples
    mos_expertTaxonomistIDProcessed$individualCount[
      mos_expertTaxonomistIDProcessed$individualCount == 0 &
        is.na(mos_expertTaxonomistIDProcessed$taxonID)] <- NA


    # Join data

    # Add trapping info to sorting table
    # Note - 59 trapping records have no associated sorting record and don't come through the left_join (even though targetTaxaPresent was set to Y or U)
    data_mosquito <- mos_sorting %>%
      dplyr::select(-c(collectDate, domainID, namedLocation, plotID, setDate, siteID)) %>%
      dplyr::left_join(dplyr::select(mos_trapping, -uid), by = 'sampleID') %>%
      dplyr::rename(sampCondition_sorting = sampleCondition.x,
                    sampCondition_trapping = sampleCondition.y,
                    remarks_sorting = remarks,
                    dataQF_trapping = dataQF)

    # Verify sample barcode consistency before removing one column
    which(data_mosquito$sampleCode.x != data_mosquito$sampleCode.y)

    # Consistency is fine with barcodes
    data_mosquito <- dplyr::rename(data_mosquito,sampleCode = sampleCode.x) %>%
      dplyr::select(-sampleCode.y)

    # Join expert ID data
    data_mosquito <- data_mosquito %>%
      dplyr::left_join(dplyr::select(mos_expertTaxonomistIDProcessed,
                                     -c(uid,collectDate, domainID, namedLocation,
                                        plotID, setDate, siteID, targetTaxaPresent)),
                       by = 'subsampleID') %>%
      dplyr::rename(remarks_expertID = remarks)

    # Verify sample barcode and labName consistency before removing one column
    which(data_mosquito$subsampleCode.x != data_mosquito$subsampleCode.y)
    which(data_mosquito$laboratoryName.x != data_mosquito$laboratoryName.y)

    # Rename columns and add estimated total individuals for each subsample/species/sex with identification, where applicable
    #  Estimated total individuals = # individuals iD'ed * (total subsample weight/ subsample weight)
    data_mosquito <- dplyr::rename(data_mosquito, subsampleCode = subsampleCode.x,
                                   laboratoryName = laboratoryName.x) %>%
      dplyr::select(-c(subsampleCode.y, laboratoryName.y)) %>%
      dplyr::mutate(estimated_totIndividuals = ifelse(!is.na(individualCount),
                                                      round(individualCount * (totalWeight/subsampleWeight)), NA))


    # Add archive data
    data_mosquito <- data_mosquito %>%
      dplyr::left_join(dplyr::select(mos_archivepooling, -c(domainID, uid, namedLocation, siteID)),
                       by = 'archiveID')

    # Verify sample barcode consistency before removing one column
    which(data_mosquito$archiveIDCode.x != data_mosquito$archiveIDCode.y)

    # Consistency is fine with barcodes
    data_mosquito <- dplyr::rename(data_mosquito,archiveIDCode = archiveIDCode.x) %>%
      dplyr::select(-archiveIDCode.y)

    # select essential columns
    str(data_mosquito)

    sum(is.na(data_mosquito$siteID)) # why 11213 record do not have siteID?
    sum(is.na(data_mosquito$sampleID)) # why 11213 record do not have siteID?
    sum(is.na(data_mosquito$individualCount)) # 1824
    sum(is.na(data_mosquito$scientificName))
    sum(is.na(data_mosquito$taxonID))
    table(data_mosquito$taxonRank)
    table(data_mosquito$sampleCondition)
    table(data_mosquito$targetTaxaPresent)

    # filter(data_mosquito, is.na(individualCount))

    data_mosquito = dplyr::filter(data_mosquito,
                                  targetTaxaPresent == "Y", # very few N or U
                                  sampleCondition == "No known compromise",
                                  taxonRank != "family")
    str_sub(data_mosquito$namedLocation, 10) %>% table() # all mosquitoPoint.mos
    data_mosquito = data_mosquito[, c("domainID", "siteID", "plotID", "namedLocation", "plotType", "nlcdClass",
                                      "decimalLatitude", "decimalLongitude", "geodeticDatum", "coordinateUncertainty",
                                      "elevation", "elevationUncertainty",
                                      "eventID", "sampleID", "taxonID", "scientificName", "taxonRank",
                                      "family", "identificationReferences", "nativeStatusCode", "sex",
                                      "collectDate", "startCollectDate",
                                      "endCollectDate", "individualCount",
                                      "estimated_totIndividuals", "trapHours",
                                      "nightOrDay", "totalWeight", "subsampleWeight")]
    return(data_mosquito)
  }

map_neon_data_to_ecocomDP.PLANT <- function(
  neon.data.product.id = "DP1.10058.001",
  ...){
  # Authors: Daijiang Li; Michael Just
  allTabs_plant <- neonUtilities::loadByProduct(
    dpID = neon.data.product.id, ...)
  # saveRDS(allTabs_plant, file = "~/Documents/allTabs_plant.rds")
  # allTabs_plant = readRDS("~/Documents/allTabs_plant.rds")
  str(allTabs_plant)

  table(allTabs_plant$div_1m2Data$divDataType)
  div_1m2_pla <- dplyr::filter(allTabs_plant$div_1m2Data, divDataType == 'plantSpecies')
  # Remove 1m2 data with targetTaxaPresent = N
  table(div_1m2_pla$targetTaxaPresent)
  div_1m2_pla <- dplyr::filter(div_1m2_pla, targetTaxaPresent != 'N')

  div_1m2_oVar <- dplyr::filter(allTabs_plant$div_1m2Data, divDataType == 'otherVariables')
  table(div_1m2_oVar$otherVariables)

  div_10_100_m2 <- allTabs_plant$div_10m2Data100m2Data

  # Remove rows without plotID, subplotID, boutNumber, endDate, and/or taxonID
  div_1m2_pla <- tidyr::drop_na(div_1m2_pla, plotID, subplotID, boutNumber, endDate, taxonID)
  div_10_100_m2 <- tidyr::drop_na(div_10_100_m2, plotID, subplotID, boutNumber, endDate, taxonID)

  # Remove duplicate taxa between nested subplots (each taxon should be represented once for the bout/plotID/year).
  # 1) If a taxon/date/bout/plot combo is present in 1m2 data, remove from 10/100
  div_1m2_pla <- dplyr::mutate(div_1m2_pla, primaryKey = paste(plotID, boutNumber, substr(endDate, 1, 4),
                                                               taxonID, subplotID, sep = '_'),
                               key2 = gsub("[.][0-9]$", "", primaryKey),
                               key3 = gsub("[.][0-9]$", "", key2))
  div_10_100_m2 <- dplyr::mutate(div_10_100_m2, primaryKey = paste(plotID, boutNumber, substr(endDate, 1, 4),
                                                                   taxonID, subplotID, sep = '_'),
                                 key2 = gsub("[.][0-9]{2}$", "", primaryKey),
                                 key3 = gsub("[.][0-9]$", "", key2))
  # additional species in 10m2 and 100m2 but not in 1m2
  div_10_100_m2_2 <- dplyr::filter(div_10_100_m2, !key2 %in% unique(div_1m2_pla$key2))
  # species in 10m2 only
  div_10_100_m2_3 <- dplyr::filter(div_10_100_m2_2, key2 != key3)
  # species in 100m2 only (remove species already in 1m2 or 10m2)
  div_10_100_m2_4 <- dplyr::filter(div_10_100_m2_2, key2 == key3,
                                   !key3 %in% unique(c(div_1m2_pla$key3, div_10_100_m2_3$key3)))
  div_10_100_m2_5 = dplyr::bind_rows(dplyr::mutate(div_10_100_m2_3, sample_area_m2 = 10),
                                     dplyr::mutate(div_10_100_m2_4, sample_area_m2 = 100))

  # stack data
  data_plant = dplyr::bind_rows(
    dplyr::select(div_1m2_pla, uid, domainID, namedLocation, siteID, decimalLatitude, decimalLongitude,
                  geodeticDatum, coordinateUncertainty, elevation, elevationUncertainty, nlcdClass,
                  plotID, subplotID, boutNumber, endDate, taxonID, scientificName, taxonRank, identificationReferences,
                  family, nativeStatusCode, percentCover, heightPlantOver300cm, heightPlantSpecies) %>%
      dplyr::mutate(sample_area_m2 = 1), # 1m2
    dplyr::select(div_10_100_m2_5, uid, domainID, namedLocation, siteID, decimalLatitude, decimalLongitude,
                  geodeticDatum, coordinateUncertainty, elevation, elevationUncertainty, nlcdClass,
                  plotID, subplotID, boutNumber, endDate, taxonID, scientificName, taxonRank,  identificationReferences,
                  family, nativeStatusCode, sample_area_m2)
  ) %>%
    dplyr::mutate(subplot_id = substr(subplotID, 1, 2),
                  subsubplot_id = substr(subplotID, 4, 4),
                  year = lubridate::year(lubridate::ymd(endDate))) %>%
    unique() %>%
    tibble::as_tibble()

  table(data_plant$siteID) # 47 sites
  n_distinct(data_plant$siteID) # 47 sites
  n_distinct(data_plant$taxonID) # 6219 species
  n_distinct(data_plant$scientificName) # 6219 species
  table(data_plant$taxonRank)
  # clean species names??

  sort(table(filter(data_plant, taxonRank == "family")$scientificName))
  sort(table(filter(data_plant, taxonRank == "genus")$scientificName))
  sort(table(filter(data_plant, taxonRank == "kingdom")$scientificName))
  sort(table(filter(data_plant, taxonRank == "speciesGroup")$scientificName))
  sort(table(filter(data_plant, taxonRank == "subspecies")$scientificName))
  sort(table(filter(data_plant, taxonRank == "superorder")$scientificName))
  sort(table(filter(data_plant, taxonRank == "variety")$scientificName))

  unique(substr(data_plant$namedLocation, 10, 21))
  # namedLocation is just the siteID_plot_ID.basePlot.div
  # plant_uid = dplyr::select(data_plant, uid)
  # usethis::use_data(plant_uid, overwrite = TRUE) # took 15.6 Mb
  data_plant = dplyr::select(data_plant, -uid)
  data_plant = dplyr::distinct(data_plant)

  # family or order level data are pretty much not useful.
  data_plant = dplyr::filter(data_plant, taxonRank %in% c("variety", "subspecies", "species", "speciesGroup", "genus"))
  # NOTE: we have not cleaned species names; users need to do it

  return(data_plant)
}

map_neon_data_to_ecocomDP.SMALL.MAMMAL <- function(
  neon.data.product.id = "DP1.10072.001",
  ...){
  # Authors: Marta Jarzyna
  ### This code downloads, unzips and restructures small mammal data (raw abundances) from NEON
  ### for each NEON site, we provide mammal raw abundance aggregated per day (across all years),
  ### per month (bout) (across all years), and per year
  ### By Marta Jarzyna
  d = neonUtilities::loadByProduct(dpID = neon.data.product.id, ...)
  # saveRDS(d, file = "~/Documents/allTabs_mammal.rds")
  # d = readRDS("~/Documents/allTabs_mammal.rds")

  dat.mam = dplyr::mutate(d$mam_pertrapnight,
                          collectDate = lubridate::ymd(collectDate),
                          year = lubridate::year(collectDate),
                          month = lubridate::month(collectDate),
                          day = lubridate::day(collectDate),
                          # Since data collection usually takes place on several consecutive
                          # days within a given month, we consider each month to be a separate bout
                          bout = paste(year, month, sep = "_")) %>%
    tibble::as_tibble()
  table(dat.mam$plotType) # all distributed

  ### Here we provide the code that summarizes raw abundances per day, month (bout), and year
  ### We keep scientificName of NA or blank (no captures) at this point
  # dat.mam <- filter(dat.mam, scientificName != "") #, !is.na(scientificName))
  dat.mam <- dplyr::mutate(dat.mam, scientificName = ifelse(scientificName == "", NA, scientificName))

  ### Remove species that are bycatch (non-target), dead, or escapted while processing
  ### remove all where the fate of the individual, unless marked and released, is
  ### 'dead' = dead, 'escaped' = escaped while handling, 'nontarget' = released, non-target species,
  ### should 'released' (= target or opportunistic species released without full processing) be also removed?
  dat.mam <- dplyr::filter(dat.mam, !fate %in% c("dead", "escaped", "nontarget"))
  #dat.mam <- filter(dat.mam, fate != "released")

  # unique(dat.mam$scientificName)

  ### Remove recaptures -- Y and U (unknown); only retain N
  # table(dat.mam$recapture)
  # sum(is.na(dat.mam$recapture))
  dat.mam <- dplyr::filter(dat.mam, recapture == "N" | is.na(recapture))

  ### Get raw abundances per day
  data_small_mammal <- dat.mam %>%
    dplyr::select(domainID, siteID, plotID, namedLocation, nlcdClass, decimalLatitude,
           decimalLongitude, geodeticDatum, coordinateUncertainty,
           elevation, elevationUncertainty, trapCoordinate, trapStatus, year, month,
           day, taxonID, scientificName, taxonRank, identificationReferences,
           nativeStatusCode, sex, lifeStage,
           pregnancyStatus, tailLength, totalLength, weight) %>%
    dplyr::distinct()

  return(data_small_mammal)
}

map_neon_data_to_ecocomDP.TICK <- function(
  neon.data.product.id = "DP1.10093.001",
  ...){
  # Download and clean tick data
  # Authors: Wynne Moss, Melissa Chen, Brendan Hobart, Matt Bitters
  # Date: 7/8/2020

  ### Script to create tidy dataset of NEON tick abundances
  # link data from lab and field
  # filter out poor quality data
  # rectify count issues
  # export in tidy format

  #  LOAD TICK DATA FROM NEON OR FILE SOURCE

  # Tick Abundance and field data data are in DP1.10093.001

  # If data weren't already downloaded, download full NEON dataset
  # As of 7/6/20 loadByProduct had bugs if using the CRAN version of the package
  # Downloading the package NeonUtilities via Github solves the issue


  Tick_all <- loadByProduct(dpID = neon.data.product.id, package = "expanded", ...)
  # saveRDS(Tick_all, "~/Documents/allTabs_tick.rds")
  # Tick_all <- readRDS("~/Documents/allTabs_tick.rds")

  # tck_taxonomyProcessed and tck_fielddata are the two datasets we want

  # NOTES ON GENERAL DATA ISSUES #

  # Issue 1: the latency between field (30 days) and lab (300 days) is different
  # In 2019, tick counts were switched over to the lab instead of the field
  # If the samples aren't processed yet, there will be an NA for all the counts (regardless of whether ticks were present)
  # Normally if ticks weren't present (targetTaxaPresent == "N") we could feel comfortable assigning all the tick counts a 0 (no ticks)
  # In this case, doing that would mean that there are 0s when ticks are absent and NAs when ticks are present
  # Yearly trends would show a bias since there are no counts for all the sites with ticks, and 0s when there aren't ticks
  # Rather, we should not use those dates until the lab data come in
  # Would be good to check with NEON whether the 0s for counts are assigned at the same time the lab data come in?

  # Issue 2: larva counts
  # larvae were not always counted or ID'd in earlier years
  # requiring larval counts to be non-NA will remove records from earlier years

  # Issue 3: discrepancies between field counts and lab counts
  # Often lab counts are less than field because they stop counting at a certain limit
  # This is not always recorded in the same way
  # Other times ticks were miscounted or lost on either end
  # Probably OK to ignore most minor issues, and make best attempt at more major issues
  # Drop remaining records that are confusing

  # CLEAN TICK FIELD DATA #

  #### NAs
  # replace empty characters with NAs instead of ""
  repl_na <- function(x) ifelse(x == "", NA, x)

  tck_fielddata = dplyr::mutate_if(Tick_all$tck_fielddata, .predicate = is.character,
                                   .funs = repl_na) %>% tibble::as_tibble()

  # check which fields have NAs
  dplyr::summarise_all(tck_fielddata, ~sum(is.na(.))) %>% as.data.frame()

  #### Quality Flags
  # remove samples that had logistical issues
  # keep only those with NA in samplingImpractical
  tck_fielddata_filtered = dplyr::filter(tck_fielddata, is.na(samplingImpractical) |
                                           samplingImpractical == "OK")

  #### Remove records with no count data
  # first confirm that lots of the records with no count data are recent years
  tck_fielddata_filtered %>% dplyr::filter(is.na(adultCount), is.na(nymphCount)) %>%
    dplyr::mutate(year = lubridate::year(collectDate)) %>%
    dplyr::pull(year) %>% table()

  # filter only records with count data
  tck_fielddata_filtered = dplyr::filter(tck_fielddata_filtered, !is.na(adultCount),
                                         !is.na(nymphCount), !is.na(larvaCount))
  # note that requiring larval counts to be non na will drop some legacy data

  #### Check correspondence between field and lab
  # Making the assumption that the user only cares about ID'd ticks and not raw abundances.
  # If so, only include field records corresponding to the dates with lab data

  # Get rid of field samples that have no taxonomic info
  tck_fielddata_filtered = dplyr::filter(tck_fielddata_filtered,
                                         sampleID %in% Tick_all$tck_taxonomyProcessed$sampleID |
                                           is.na(sampleID))

  # Get rid of the tax samples that have no field data
  # many of these are legacy samples where larvae weren't counted
  tck_tax_filtered = dplyr::filter(Tick_all$tck_taxonomyProcessed,
                                   sampleID %in% tck_fielddata_filtered$sampleID) %>%
    tibble::as_tibble()

  # double check same sample ID in both datasets
  length(unique(na.omit(tck_fielddata_filtered$sampleID)))
  length(unique(tck_tax_filtered$sampleID)) # match

  #### Check other quality control/sample remarks

  table(tck_fielddata_filtered$sampleCondition) # none of these are major issues

  table(tck_fielddata_filtered$dataQF) # legacy data only

  tck_fielddata_filtered %>% dplyr::filter(dataQF == "legacyData") %>%
    dplyr::mutate(year = lubridate::year(collectDate)) %>%
    dplyr::pull(year) %>% table()
  # from earlier years (keep for now)

  #### Sample IDs
  # check that all of the rows WITHOUT a sample ID have no ticks
  tck_fielddata_filtered %>% dplyr::filter(is.na(sampleID)) %>%
    dplyr::pull(targetTaxaPresent) %>% table() # true

  # check that all the rows WITH a sample ID have ticks
  tck_fielddata_filtered %>% dplyr::filter(!is.na(sampleID)) %>%
    dplyr::pull(targetTaxaPresent) %>% table() # true

  # sampleID only assigned when there were ticks present; all missing sample IDs are for drags with no ticks (good)
  # for now, retain sampling events without ticks

  # make sure sample IDs are unique
  tck_fielddata_filtered %>% group_by(sampleID) %>% summarise(n = n()) %>% filter(n > 1) # yes all unique
  sum(duplicated(na.omit(tck_fielddata_filtered$sampleID)))

  # check that drags with ticks present have a sample ID
  tck_fielddata_filtered %>% filter(targetTaxaPresent == "Y" & is.na(sampleID)) # none are missing S.ID

  #### Check Counts vs. NAs

  # make sure samples with ticks present have counts
  tck_fielddata_filtered %>% filter(targetTaxaPresent == "Y") %>%
    filter(is.na(adultCount) & is.na(nymphCount) & is.na(larvaCount)) %>% nrow()

  # are there any 0 counts where there should be > 0?
  tck_fielddata_filtered %>% filter(targetTaxaPresent == "Y") %>%
    mutate(totalCount = adultCount + nymphCount + larvaCount) %>%
    filter(totalCount == 0) # no

  ### Check for other missing count data
  # list of fields that shouldn't have NAs
  req_cols <- c("siteID", "plotID", "collectDate", "adultCount", "nymphCount", "larvaCount")

  # all should have no NAs
  tck_fielddata_filtered %>% select(req_cols) %>% summarise_all(~sum(is.na(.)))

  # CLEAN TICK TAXONOMY DATA

  ### replace "" with NA
  tck_tax_filtered = mutate_if(tck_tax_filtered, .predicate = is.character,
                               .funs = repl_na) %>%
    ## only retain lab records that are also in the field dataset
    filter(sampleID %in% tck_fielddata_filtered$sampleID)

  ### check sample quality flags
  table(tck_tax_filtered$sampleCondition)

  # none of these are deal breakers but just keep those deemed OK
  tck_tax_filtered = filter(tck_tax_filtered, sampleCondition == "OK")

  ### check for NAs in fields
  tck_tax_filtered %>% select(everything()) %>%
    summarise_all(~sum(is.na(.))) %>% as.data.frame()

  ### create a flag for potential lab ID/count issues
  table(Tick_all$tck_taxonomyProcessed$remarks)

  tck_fielddata_filtered$IDflag <- NA

  # mark sample IDs that have taxonomy issues
  # these come from remarks indicating that ticks in field were mis-ID'd
  # useful for correcting counts later
  tax.issues = Tick_all$tck_taxonomyProcessed %>%
    filter(str_detect(remarks, "insect|mite|not a tick|NOT A TICK|arachnid|spider")) %>%
    pull(sampleID) %>% unique()

  # add a flag for these samples in the field dataset
  tck_fielddata_filtered$IDflag[which(tck_fielddata_filtered$sampleID %in% tax.issues)] <- "ID WRONG"

  # sample IDs where lab reached limit and stopped counting
  # will help explain why lab counts < field counts
  invoice.issues = Tick_all$tck_taxonomyProcessed %>%
    filter(str_detect(remarks, "billing limit|invoice limit")) %>%
    pull(sampleID) %>% unique()

  tck_fielddata_filtered$IDflag[which(tck_fielddata_filtered$sampleID %in% invoice.issues)] <- "INVOICE LIMIT"

  ### require date and taxon ID
  tck_tax_filtered = filter(tck_tax_filtered, !is.na(identifiedDate)) %>%
    filter(!is.na(acceptedTaxonID))

  # epithet are all NAs (don't need these columns)
  table(tck_tax_filtered$infraspecificEpithet)

  # qualifier
  table(tck_tax_filtered$identificationQualifier)

  # legacy data is the only flag (OK)
  table(tck_tax_filtered$dataQF)

  # other remarks: some seem relevant for reconciling field and lab
  # however it will become onerous to go through these individually as dataset grows
  # ignore most of these for now
  unique(tck_tax_filtered$remarks)

  ### check that the IDs all make sense
  table(tck_tax_filtered$acceptedTaxonID)
  # IXOSPP1 = genus ixodes (Ixodes spp.):
  tck_tax_filtered %>% filter(acceptedTaxonID == "IXOSPP1") %>% select(scientificName, taxonRank) %>% head()
  # IXOSPP = family ixodidae (Ixodidae spp.):
  tck_tax_filtered %>% filter(acceptedTaxonID == "IXOSPP") %>% select(scientificName, taxonRank) %>% head()
  # IXOSP2 = order ixodes (Ixodida sp.):
  tck_tax_filtered %>% filter(acceptedTaxonID == "IXOSP2") %>% select(scientificName, taxonRank) %>% head()
  # IXOSP = family exodidae (Ixodidae sp.)
  tck_tax_filtered %>% filter(acceptedTaxonID == "IXOSP") %>% select(scientificName, taxonRank) %>% head()

  table(tck_tax_filtered$taxonRank)
  table(tck_tax_filtered$family)

  # if only ID'd to order, all are IXOSP2:
  tck_tax_filtered %>% filter(taxonRank == "order") %>% pull(acceptedTaxonID) %>% table()
  # if only ID'd to family, either IXOSP or IXOSPP
  # not sure how to deal with mixed species (e.g. IXOSPP)
  tck_tax_filtered %>% filter(taxonRank == "family") %>% pull(acceptedTaxonID) %>% table()
  tck_tax_filtered %>% filter(taxonRank == "species") %>% pull(acceptedTaxonID) %>% table()

  ### sex or age columns
  table(tck_tax_filtered$sexOrAge)
  tck_tax_filtered %>% filter(is.na(sexOrAge)) # all have sex or age
  tck_tax_filtered %>% filter(individualCount == 0 | is.na(individualCount)) %>% nrow() # all have counts

  # create a lifestage column so tax counts can be compared to field data
  tck_tax_filtered = tck_tax_filtered %>%
    mutate(lifeStage = case_when(sexOrAge == "Male" | sexOrAge == "Female" |
                                   sexOrAge == "Adult" ~ "Adult",
                                 sexOrAge == "Larva" ~ "Larva",
                                 sexOrAge == "Nymph" ~ "Nymph"))
  sum(is.na(tck_tax_filtered$lifeStage))
  # this assumes that any ticks that were sexed must be adults (I couldn't confirm this)

  #  MERGE FIELD AND TAXONOMY DATA #

  # there are a few options here:
  # 1) left join tick_field to tick_tax: this will keep all the 0s but requires some wide/long manipulation
  # 2) left join tick_tax to tick_field: this will only keep the records where ticks were ID'd. could add in 0s afterwards depending on preference

  # We will left join tick_field to tick_tax, so that 0s are preserved.
  # Merging will require us to resolve count discrepancies (this may be overkill for those interested in P/A)
  # For simplicity we will also collapse M/F into all adults (also optional)

  # first check for dup colnames
  intersect(colnames(tck_fielddata_filtered), colnames(tck_tax_filtered))

  # rename columns containing data unique to each dataset
  colnames(tck_fielddata_filtered)[colnames(tck_fielddata_filtered)=="uid"] <- "uid_field"
  colnames(tck_fielddata_filtered)[colnames(tck_fielddata_filtered)=="sampleCondition"] <- "sampleCondition_field"
  colnames(tck_fielddata_filtered)[colnames(tck_fielddata_filtered)=="remarks"] <- "remarks_field"
  colnames(tck_fielddata_filtered)[colnames(tck_fielddata_filtered)=="dataQF"] <- "dataQF_field"
  colnames(tck_fielddata_filtered)[colnames(tck_fielddata_filtered)=="publicationDate"] <- "publicationDate_field"

  colnames(tck_tax_filtered)[colnames(tck_tax_filtered)=="uid"] <- "uid_tax"
  colnames(tck_tax_filtered)[colnames(tck_tax_filtered)=="sampleCondition"] <- "sampleCondition_tax"
  colnames(tck_tax_filtered)[colnames(tck_tax_filtered)=="remarks"] <- "remarks_tax"
  colnames(tck_tax_filtered)[colnames(tck_tax_filtered)=="dataQF"] <- "dataQF_tax"
  colnames(tck_tax_filtered)[colnames(tck_tax_filtered)=="publicationDate"] <- "publicationDate_tax"

  # in order to merge counts with field data we will first combine counts from male/female in the tax data into one adult class
  # if male/female were really of interest you could skip this (but the table will just be much wider since all will have a M-F option)

  tck_tax_wide = tck_tax_filtered %>% group_by(sampleID, acceptedTaxonID, lifeStage) %>%
    summarise(individualCount = sum(individualCount, na.rm = TRUE)) %>%
    # now make it wide;  only one row per sample id
    pivot_wider(id_cols = sampleID,  names_from = c(acceptedTaxonID, lifeStage), values_from = individualCount, values_fill = 0)

  # each row is now a unique sample id (e.g. a site x species matrix)

  sum(duplicated(tck_tax_wide$sampleID)) # none are duplicated
  sum(duplicated(na.omit(tck_fielddata_filtered$sampleID)))
  length(unique(tck_tax_wide$sampleID))

  tck_merged = left_join(tck_fielddata_filtered, tck_tax_wide, by = "sampleID")

  #FIX COUNT DISCREPANCIES BETWEEN FIELD AND LAB #

  ### clean up 0s
  # if ticks were not found in the field, counts should be 0
  tck_merged %>% select(contains(c("_Nymph", "_Adult" , "_Larva"))) %>% colnames() -> taxon.cols # columns containing counts per taxon

  for(i in 1:length(taxon.cols)){
    tck_merged[which(tck_merged$targetTaxaPresent =="N"), which(colnames(tck_merged) == taxon.cols[i])] = 0
  }

  ### check for NA
  # check for NAs in the count columns
  tck_merged %>% select_if(is_numeric)%>% summarise_all(~sum(is.na(.)))

  # NAs indicate the lab determined no ticks in sample or the associated record was pulled

  # if there are NAs for counts and an ID flag, most likely the lab did not find ticks and field data should be corrected
  uid_change = tck_merged %>% select(uid_field, all_of(taxon.cols), IDflag) %>%
    filter_at(vars(taxon.cols), all_vars(is.na(.))) %>%
    filter(!is.na(IDflag)) %>% pull(uid_field)

  # correct the field data to reflect no ticks
  tck_merged[which(tck_merged$uid_field == uid_change), "targetTaxaPresent"] = "N"
  tck_merged[which(tck_merged$uid_field == uid_change), "adultCount"] = 0
  tck_merged[which(tck_merged$uid_field == uid_change), "nymphCount"] = 0
  tck_merged[which(tck_merged$uid_field == uid_change), "larvaCount"] = 0
  for(i in 1:length(taxon.cols)){
    tck_merged[which(tck_merged$uid_field==uid_change), which(colnames(tck_merged) == taxon.cols[i])] = 0
  }

  #### FIX COUNT 1.1 FLAG DISCREPANCIES ###

  # first get list of columns for easy summing
  tck_merged %>% select(contains("_Adult")) %>% colnames() -> adult_cols
  tck_merged %>% select(contains("_Nymph")) %>% colnames() -> nymph_cols
  tck_merged %>% select(contains("_Larva")) %>% colnames() -> larva_cols

  # sum up lab and field totals
  tck_merged %>% mutate(
    totalAdult_tax = rowSums(.[adult_cols]),
    totalNymph_tax = rowSums(.[nymph_cols]),
    totalLarva_tax = rowSums(.[larva_cols]),
    totalCount_tax = rowSums(.[c(adult_cols, nymph_cols, larva_cols)]),
    totalCount_field = rowSums(.[c("adultCount", "nymphCount", "larvaCount")])
  ) -> tck_merged

  # get a list of columns with counts for easily viewing dataset (optional)
  tck_merged %>%
    select(contains(c("adult", "nymph","larva", "total", "Adult",  "Nymph",  "Larva", "Count"), ignore.case = FALSE)) %>%
    select(-totalSampledArea) %>% colnames() -> countCols

  # create flag column to mark issues with count discrepancies
  tck_merged %>% mutate(CountFlag = NA) -> tck_merged

  # flag 1: the total count matches, but the life stage columns don't (error 1)
  tck_merged$CountFlag[tck_merged$totalCount_field == tck_merged$totalCount_tax] <- 1

  # no flag:  all the counts match (no flag) -- some of the 1s will now be  0s
  tck_merged$CountFlag[tck_merged$nymphCount == tck_merged$totalNymph_tax &
                         tck_merged$adultCount == tck_merged$totalAdult_tax &
                         tck_merged$larvaCount == tck_merged$totalLarva_tax] <- 0

  # no flag: no ticks
  tck_merged$CountFlag[tck_merged$targetTaxaPresent=="N"] <- 0

  # flag 2: the field total is > than tax total
  tck_merged$CountFlag[tck_merged$totalCount_field > tck_merged$totalCount_tax] <- 2

  # flag 3: the field total is < than the tax total
  tck_merged$CountFlag[tck_merged$totalCount_field < tck_merged$totalCount_tax] <- 3

  ### reconcile count discrepancies
  table(tck_merged$CountFlag)
  # the vast majority of counts match.


  #### FIX COUNT 2.1 RECONCILE DISCREPANCIES WHERE TOTALS MATCH ###

  ### Flag Type 1: the total count from field and lab matches but not individual lifestages
  tck_merged %>% filter(CountFlag == 1) %>% select(all_of(countCols))
  # many of these are adults misidentified as nymphs or vice versa
  # trust the lab counts here (ignore nymphCount, adultCount, larvaCount from field data)
  # don't correct any counts and change the flag from a 1 to 0
  tck_merged %>%  mutate(CountFlag = ifelse(CountFlag == 1, 0, CountFlag)) -> tck_merged
  table(tck_merged$CountFlag)


  #### FIX COUNT 2.2 RECONCILE DISCREPANCIES WHERE FIELD COUNT > TAX COUNT ###


  ### Flag Type 2:more ticks found in the field than in the lab

  # in some cases, there were too many larvae and not all were ID'd
  # in other cases, there may be issues with the counts and some ended up not being ticks
  # if we can't rectify, lump the excess field ticks into IXOSP2
  # IXOSP2 is the least informative ID, essentially the same as marking them as "unidentified tick"

  ### some of these have notes in the ID flag column indicating a non-tick
  # trust the lab count and don't correct the counts
  # remove flag (2->0)
  tck_merged %>% mutate(CountFlag = case_when(CountFlag == 2 & IDflag == "ID WRONG" ~ 0,
                                              TRUE ~ CountFlag)) -> tck_merged

  ### some have more larvae in the field than in the lab
  # larvae weren't always identified/counted in the lab, or if they were, only counted up to a limit
  # if there were more larvae in the field than in lab, the extra larvae should be added to the order level (IXOSP2)
  # "extra larvae" = larvae not counted - those moved to another lifestage

  tck_merged %>% mutate(IXOSP2_Larva = case_when(
    CountFlag == 2 & larvaCount>totalLarva_tax & is.na(IDflag) ~ IXOSP2_Larva + (larvaCount - totalLarva_tax) + (nymphCount - totalNymph_tax) + (larvaCount - totalLarva_tax),
    TRUE ~ IXOSP2_Larva)) -> tck_merged

  # remove flag
  tck_merged %>% mutate(CountFlag = case_when(
    CountFlag == 2 & larvaCount>totalLarva_tax & is.na(IDflag)~0,
    TRUE ~ CountFlag)) -> tck_merged


  ### some counts are off by only a few individuals (negligible)
  # could be miscounted in the field or lost in transit
  # if counts are off by < 10% this difference is not too meaningful
  # trust the lab count data, don't change any counts
  # remove flag
  tck_merged %>% mutate(CountFlag = case_when(
    CountFlag == 2 & (totalCount_field - totalCount_tax)/totalCount_field < 0.1 ~0, # if discrepancy < 10% of total
    TRUE ~ CountFlag)) -> tck_merged

  ### some counts are off by more than 10% but explanation is obvious
  # cases where 1-2 field ticks are "missing" but discrepancy is more than 10% of total count
  # if there are field remarks, assume they are about ticks being lost (see field_remarks output)
  # assign missing field ticks to order level IXOSP2
  # missing (unidentified) ticks = missing counts that were not assigned to other lifestages

  # if IXOSP2 doesn't exist for other lifestages, add it
  if(sum(colnames(tck_merged) == "IXOSP2_Adult")==0) {
    # if column doesn't exist,
    # add it with a default of 0
    tck_merged <- tck_merged %>% mutate(IXOSP2_Adult = 0)
  }
  if (sum(colnames(tck_merged) == "IXOSP2_Nymph") == 0) {
    tck_merged <- tck_merged %>% mutate(IXOSP2_Nymph = 0)
  }
  if (sum(colnames(tck_merged) == "IXOSP2_Larva") == 0) {
    tck_merged <- tck_merged %>% mutate(IXOSP2_Larva = 0)
  }

  # if there are missing adults and remarks in the field, add the missing adults to IXOSP2_Adult
  tck_merged %>% mutate(IXOSP2_Adult = case_when(
    CountFlag == 2 & adultCount>totalAdult_tax & (adultCount-totalAdult_tax) <= 2 & !is.na(remarks_field) ~
      IXOSP2_Adult+ (adultCount - totalAdult_tax) + (nymphCount-totalNymph_tax) + (larvaCount-totalLarva_tax), # count discrepancy add to order IXOSP2
    TRUE ~ IXOSP2_Adult)) %>%
    # if there are missing nymphs and remarks in the field, add the missing adults to IXOSP2_Nymph
    mutate(IXOSP2_Nymph = case_when(
      CountFlag == 2 & nymphCount>totalNymph_tax & (nymphCount-totalNymph_tax) <= 2 & !is.na(remarks_field) ~
        IXOSP2_Nymph+ (adultCount - totalAdult_tax) + (nymphCount-totalNymph_tax) + (larvaCount-totalLarva_tax), # count discrepancy add to order IXOSP2
      TRUE ~ IXOSP2_Nymph)) %>%
    # if there are missing larvae and remarks in the field, add the missing adults to IXOSP2_Larva
    mutate(IXOSP2_Larva = case_when(
      CountFlag == 2 & larvaCount>totalLarva_tax & (larvaCount-totalLarva_tax) <= 2 & !is.na(remarks_field) ~
        IXOSP2_Larva+ (adultCount - totalAdult_tax) + (nymphCount-totalNymph_tax) + (larvaCount-totalLarva_tax),
      TRUE ~ IXOSP2_Larva)) -> tck_merged


  # remove flag
  tck_merged %>% mutate(CountFlag = case_when(
    CountFlag == 2 & adultCount>totalAdult_tax & (adultCount-totalAdult_tax) <= 2 & !is.na(remarks_field)~0,
    CountFlag == 2 & nymphCount>totalNymph_tax & (nymphCount-totalNymph_tax) <=2 & !is.na(remarks_field)~0,
    CountFlag == 2 & larvaCount>totalLarva_tax & (larvaCount-totalLarva_tax) <=2 & !is.na(remarks_field)~0,
    TRUE~ CountFlag)) -> tck_merged


  ### some counts are off because over invoice limit
  # in this case trust the field counts, and extra are assigned to order level
  tck_merged %>% mutate(IXOSP2_Nymph = case_when(
    CountFlag == 2 & nymphCount>totalNymph_tax & IDflag == "INVOICE LIMIT" ~
      IXOSP2_Nymph+ (adultCount - totalAdult_tax) + (nymphCount-totalNymph_tax) + (larvaCount-totalLarva_tax), # add count discrepancy to order
    TRUE ~ IXOSP2_Nymph)) %>%
    mutate(IXOSP2_Larva = case_when(
      CountFlag == 2 & larvaCount>totalLarva_tax & IDflag == "INVOICE LIMIT" ~
        IXOSP2_Larva+ (adultCount - totalAdult_tax) + (nymphCount-totalNymph_tax) + (larvaCount-totalLarva_tax), # add count discrepancy to order
      TRUE ~ IXOSP2_Larva)) %>%
    mutate(IXOSP2_Adult = case_when(
      CountFlag == 2 & adultCount>totalAdult_tax & IDflag == "INVOICE LIMIT" ~
        IXOSP2_Adult+ (adultCount - totalAdult_tax) + (nymphCount-totalNymph_tax) + (larvaCount-totalLarva_tax), # add count discrepancy to order
      TRUE ~ IXOSP2_Adult))-> tck_merged

  # remove flag
  tck_merged %>% mutate(CountFlag = case_when(
    CountFlag == 2 & adultCount>totalAdult_tax &IDflag == "INVOICE LIMIT" ~ 0,
    CountFlag == 2 & nymphCount>totalNymph_tax &IDflag == "INVOICE LIMIT" ~ 0,
    CountFlag == 2 & larvaCount>totalLarva_tax &IDflag == "INVOICE LIMIT" ~ 0,
    TRUE ~ CountFlag)) -> tck_merged

  table(tck_merged$CountFlag)

  #### FIX COUNT 2.3 RECONCILE DISCREPANCIES WHERE FIELD COUNT < TAX COUNT

  ### cases where counts are off by minor numbers
  # this could be miscounts in the field
  # if the discrepancy is less than 30% of the total count or 5 or less individuals
  # trust the lab count here and don't correct counts

  # remove flag
  tck_merged %>% mutate(CountFlag = case_when(
    CountFlag == 3 & (abs(totalCount_tax-totalCount_field))/totalCount_tax < 0.3 ~ 0,
    (totalCount_tax - totalCount_field)<=5 ~ 0,
    TRUE ~ CountFlag)) -> tck_merged

  #### FIX COUNT 2.4 REMOVE THE UNSOLVED MYSTERY SAMPLES
  # cases with larger discrepancies that aren't obvious are removed from final dataset
  # make sure this is less than 1% of total cases
  # more work could be done here if there are many cases in this category
  if((tck_merged %>% filter(CountFlag!=0) %>% nrow())/nrow(tck_merged)< 0.01){
    tck_merged <- tck_merged %>% filter(CountFlag==0)
  }

  #### Final notes on count data
  # note that some of these could have a "most likely" ID assigned based on what the majority of IDs are
  # for now don't attempt to assign.
  # the user can decide what to do with the IXOSP2 later (e.g. assign to lower taxonomy)
  # from this point on, trust lab rather than field counts because lab were corrected if discrepancy exists

  # RESHAPE FINAL DATASET

  # will depend on the end user but creating two options
  # note that for calculation of things like richness, might want to be aware of the level of taxonomic resolution

  tck_merged %>% select(contains(c("_Larva", "_Nymph", "_Adult"))) %>% colnames() -> taxon.cols # columns containing counts per taxon


  ### option 1) long form data including 0s

  # get rid of excess columns (user discretion)
  tck_merged_final <- tck_merged %>% select(-CountFlag, -IDflag, -totalAdult_tax, -totalNymph_tax, -totalLarva_tax, -totalCount_tax, -totalCount_field,
                                            -nymphCount, -larvaCount, -adultCount,
                                            -samplingImpractical, -measuredBy, -dataQF_field, -publicationDate_field)


  # long form data
  tck_merged_final %>% pivot_longer(cols = all_of(taxon.cols), names_to = "Species_LifeStage", values_to = "IndividualCount") %>%
    separate(Species_LifeStage, into = c("acceptedTaxonID", "LifeStage"), sep = "_", remove = FALSE) -> tck_merged_final


  # add in taxonomic resolution
  table(Tick_all$tck_taxonomyProcessed$acceptedTaxonID, Tick_all$tck_taxonomyProcessed$taxonRank)# accepted TaxonID is either at family, order, or species level
  table(Tick_all$tck_taxonomyProcessed$acceptedTaxonID, Tick_all$tck_taxonomyProcessed$scientificName)
  Tick_all$tck_taxonomyProcessed %>% group_by(acceptedTaxonID) %>% summarise(taxonRank =  first(taxonRank), scientificName= first(scientificName)) -> tax_rank

  tck_merged_final %>% left_join(tax_rank, by = "acceptedTaxonID") -> tck_merged_final

  setdiff(tck_merged_final$acceptedTaxonID, tck_tax_filtered$acceptedTaxonID)

  data_tick = filter(tck_merged_final, sampleCondition_field == "No known compromise") %>%
    select(-uid_field, -sampleCondition_field, -samplingProtocolVersion, -Species_LifeStage) %>%
    unique() %>%
    dplyr::left_join(dplyr::select(tck_tax_filtered, acceptedTaxonID, family, identificationReferences) %>%
                       dplyr::distinct() %>%
                       group_by(acceptedTaxonID) %>%
                       summarise(family = unique(family)[1],
                         identificationReferences = paste(unique(identificationReferences),
                                                                  collapse = "; "), .groups = "drop") %>%
                       dplyr::distinct(),
                     by = "acceptedTaxonID") %>%
    dplyr::distinct()

  table(data_tick$plotType) # all distributed
  table(str_sub(data_tick$namedLocation, 10)) # all tickPlot.tck
  data_tick = dplyr::select(data_tick, -plotType) %>% dplyr::distinct()

  # NOTES FOR END USERS  #
  # be aware of higher order taxa ID -- they are individuals ASSIGNED at a higher taxonomic class, rather than the sum of lower tax. class
  # higher order taxonomic assignments could be semi-identified by looking at most likely ID (e.g. if 200 of 700 larvae are IXOSPAC, very likely that the Unidentified larvae are IXOSPAC)
  # unidentified could be changed to IXOSPP across the board
  # All combos of species-lifestage aren't in the long form (e.g. if there were never IXOAFF_Adult, it will be missing instead of 0)

  return(data_tick)
}

# may not want this one
map_neon_data_to_ecocomDP.TICK.PATHOGEN <- function(
  neon.data.product.id = "DP1.10092.001",
  ...){
  # Download and clean tick pathogen data
  # Authors:  Melissa Chen, Wynne Moss, Brendan Hobart, Matt Bitters
  # Date: 7/1/20  (Happy Canada Day!)

  ## Note: I do NOT cross-reference subsampleIDs or testing numbers with the tick field data. ##

  #### Load files ###
  tickpathdat <- loadByProduct(dpID = neon.data.product.id, package = "expanded", ...)
  # saveRDS(tickpathdat, file = "~/Documents/allTabs_tickpathogen.rds")
  # tickpathdat = readRDS("~/Documents/allTabs_tickpathogen.rds")

  names(tickpathdat)
  tick_path <- tibble::as_tibble(tickpathdat$tck_pathogen)
  names(tick_path)
  table(tick_path$laboratoryName)
  tick_pathqa <- tibble::as_tibble(tickpathdat$tck_pathogenqa)

  #### Raw dataset inspection ###
  ## Record original number of tests
  nrow(tick_path)

  ## Record original number of test results that are not NA
  nrow(filter(tick_path, !is.na(testResult)))

  #### Quality check file ###
  ## Remove any samples that have flagged quality checks
  table(tick_pathqa$criteriaMet)
  remove_qa_uid_batchID <- tick_pathqa[tick_pathqa$criteriaMet != "Y", c("uid","batchID")]

  ## Record which batchIDs in tick_path are not in quality file
  print(paste0("## Batches NOT found in quality file: "))
  setdiff(tick_path$batchID, tick_pathqa$batchID)
  setdiff(tick_pathqa$batchID, tick_path$batchID)
  # Note: in the qa file it says NEON_2017831, but in the tick_path file it's NEON_20170831. I think these are the same thing.

  #### Tick Pathogen Quality assessment ###
  ## Checking uid is unique
  Is_all_ID_uniqud <- any(duplicated(tick_path$uid))
  if (Is_all_ID_uniqud)
    warning("uid is not unique. Check file manually.")

  ## Check there isn't any important missing data
  # List of important variables
  checkVar <- c("domainID","siteID","plotID", "decimalLatitude", "decimalLongitude",
                "plotType", "nlcdClass", "elevation", "collectDate",
                "subsampleID", "batchID", "testingID", "testPathogenName")
  # Check which variables are missing
  which_missing_var <- sapply(checkVar, function(v) {any(is.na(tick_path[, v]))})


  # Identify samples with missing values
  removeSamples_missingvalue <- tick_path[as.vector(is.na(tick_path[, checkVar[which_missing_var]])),
                                          c("uid","namedLocation","collectDate","sampleCondition","remarks")]
  # Will need to filter these out.
  removeSamples_missingvalue

  ## Look at sample conditions; filter out all non-OKAY
  table(tick_path$sampleCondition) # We'll get rid of all "non-okay" samples
  removeSamples_sampleCondition <- tick_path[tick_path$sampleCondition != "OK",
                                             c("uid","namedLocation","collectDate","sampleCondition","remarks")]
  removeSamples_sampleCondition

  ## How many test results are NA?
  sum(is.na(tick_path$testResult)) # a lot. I think some are 2019 data, and others are just unknown/untested
  removeSamples_testResult <- tick_path[is.na(tick_path$testResult),]

  ## Check DNA quality of each testing batch
  tick_path %>% filter(testPathogenName == "HardTick DNA Quality") %>%
    select(testResult, testPathogenName) %>%
    table(useNA = "ifany")

  # Only positive DNA test results-- filter out others
  removeSamples_DNAQual <- tick_path %>%
    filter(testPathogenName == "HardTick DNA Quality", testResult != "Positive") %>%
    select(uid, namedLocation, collectDate, sampleCondition, remarks)
  removeSamples_DNAQual

  ## Check number of ticks tested per site per year
  ## Site x year for all tested ticks:
  tick_path %>% filter(!is.na(testResult),
                       !(testPathogenName %in% c("HardTick DNA Quality","Ixodes pacificus"))) %>%
    mutate(year = year(collectDate)) %>%
    pivot_wider(id_cols=c(siteID, year, testingID), names_from=testPathogenName, values_from=testResult)%>%
    select(siteID, year) %>% table()
  # It is NOT true that only a subset of 130 ticks were tested from each site and year... do they mean PLOT?
  # or maybe they mean "by species"?
  # By species-- try the two main ones
  ## Site x year for Ambame only:
  tick_path %>%
    filter(!is.na(testResult), !(testPathogenName %in% c("HardTick DNA Quality","Ixodes pacificus"))) %>%
    separate(subsampleID, into=c("plotID","date","species","lifestage"), sep="[.]", remove=FALSE) %>%
    mutate(year = year(collectDate)) %>%
    pivot_wider(id_cols=c(siteID, year, species, testingID), names_from=testPathogenName, values_from=testResult)%>%
    filter(species=="AMBAME")  %>% select(siteID, year) %>% table()

  ## Site x year for Ixosca only:
  tick_path %>%
    filter(!is.na(testResult), !(testPathogenName %in% c("HardTick DNA Quality","Ixodes pacificus"))) %>%
    separate(subsampleID, into=c("plotID","date","species","lifestage"), sep="[.]", remove=FALSE) %>%
    mutate(year = year(collectDate)) %>%
    pivot_wider(id_cols=c(siteID, year, species, testingID), names_from=testPathogenName, values_from=testResult)%>%
    filter(species=="IXOSCA")  %>% select(siteID, year) %>% table()

  # By plot
  ## Plot x year:
  tick_path %>%
    filter(!is.na(testResult), !(testPathogenName %in% c("HardTick DNA Quality","Ixodes pacificus"))) %>%
    separate(subsampleID, into=c("plotID","date","species","lifestage"), sep="[.]", remove=FALSE) %>%
    mutate(year = year(collectDate)) %>%
    pivot_wider(id_cols=c(plotID, year, species, testingID), names_from=testPathogenName, values_from=testResult)%>%
    select(plotID, year) %>% table()

  ### Which species were tested for what pathogens?
  # Create table
  ## Which species was tested for which pathogens:
  tick_path %>%
    filter(!is.na(testResult)) %>%
    separate(subsampleID, into=c("plotID","date","species","lifestage"), sep="[.]", remove=FALSE) %>%
    select(testPathogenName, species) %>% table()

  ## Get rid of hardtick DNA and Ixodes pacificus tests
  remove_testPathogenName <- tick_path %>%
    filter(testPathogenName %in% c("HardTick DNA Quality","Ixodes pacificus"))

  # Note that this does NOT follow their description from online, which says certain
  # species were tested for certain pathogens. In reality, it seems almost all
  # individuals were tested for all pathogens (with a few exceptions)

  #### Minor edits to data file ###

  ## First, we need to merge B. burgdeferi and B. burgdeferi sensu lato-- these are supposed to be one row.
  # They should be exclusive from each other, so let's check that first.

  tick_path %>% filter(testPathogenName %in% c("Borrelia burgdorferi", "Borrelia burgdorferi sensu lato")) %>%
    select(testingID, testPathogenName) %>% nrow()
  tick_path %>% filter(testPathogenName %in% c("Borrelia burgdorferi", "Borrelia burgdorferi sensu lato")) %>%
    select(testingID) %>% distinct() %>% nrow()
  # Verified that testingIDs are not duplicated over B burgdorferi or B burgdorferi sensu lato. We can merge them without problem.

  #### Filtering ###
  tick_path_filt <- tick_path %>%
    filter(!(uid %in% c(remove_qa_uid_batchID$uid, removeSamples_missingvalue$uid,
                        removeSamples_sampleCondition$uid, removeSamples_testResult$uid,
                        removeSamples_DNAQual$uid, remove_testPathogenName$uid))) %>%
    mutate(testPathogenName = ifelse(testPathogenName == "Borrelia burgdorferi",
                                     "Borrelia burgdorferi sensu lato",
                                     testPathogenName)) %>%
    # Changing B burgdorferi to sensu lato
    separate(subsampleID, into = c("plotID2","date2","hostSpecies","lifeStage"),
             sep = "[.]", remove=FALSE) %>% # Adding a host species column
    select(-c("plotID2","date2")) # remove extra columns

  data_tick_pathogen = select(tick_path_filt,
                              -uid, -subsampleID, -individualCount, -sampleCondition,
                              -testProtocolVersion, -remarks, -testedBy,
                              -laboratoryName, -dataQF, -publicationDate)

  table(data_tick_pathogen$testResult)
  table(data_tick_pathogen$plotType)
  str_sub(data_tick_pathogen$namedLocation, 10) %>% table()

  return(data_tick_pathogen)
}

map_neon_data_to_ecocomDP.BIRD <- function(
  neon.data.product.id = "DP1.10003.001",
  ...){
  # Authors: Daijiang Li
  allTabs_bird = neonUtilities::loadByProduct(dpID = neon.data.product.id, package = "expanded", ...)
  # saveRDS(allTabs_bird, file = "~/Documents/allTabs_bird.rds")
  # allTabs_bird = readRDS("~/Documents/allTabs_bird.rds")
  allTabs_bird$brd_countdata = tibble::as_tibble(allTabs_bird$brd_countdata)
  allTabs_bird$brd_perpoint = tibble::as_tibble(allTabs_bird$brd_perpoint)
  data_bird = dplyr::left_join(allTabs_bird$brd_countdata,
                               dplyr::select(allTabs_bird$brd_perpoint, -uid,
                                             -startDate, -publicationDate))
  table(data_bird$samplingImpractical) # all NA
  table(data_bird$samplingImpracticalRemarks)
  data_bird = dplyr::select(data_bird, -uid, -identifiedBy, -publicationDate,
                            -eventID, # it is just plotID, pointID, startDate
                            -laboratoryName, -measuredBy,
                            -samplingImpractical, -samplingImpracticalRemarks)

  table(data_bird$clusterCode)
  # the Cluster Code is only used to link clusters that take up multiple lines on the data sheet.
  table(data_bird$targetTaxaPresent)
  table(data_bird$remarks)
  table(data_bird$taxonRank)
  table(data_bird$samplingProtocolVersion)
  return(data_bird)
}

