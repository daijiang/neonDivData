source("data-raw/00_pkg_functions.R")

#title: download mosquito data and clean
#author: Natalie Robinson
#date: 6/08/2020

#get mosquito data -------------
# mos dpid
mos_code <-'DP1.10043.001'

#only two sites -
# site_ids = c("NIWO","DSNY")-EX
mos_allTabs <- loadByProduct(dpID = mos_code,
                             #site = site_ids,
                             # startdate = "2016-1", enddate = "2018-11",
                             package = "expanded", check.size = FALSE,
                             nCores = 3)


# Identify names of desired tables and pull data into corresponding data frames
tables <- names(mos_allTabs)[grepl('mos', names(mos_allTabs))]

for (tabs in tables){
  assign(tabs, as_tibble(mos_allTabs[[tabs]]))
}

#################################################################################
# Clean data

# Remove rows with missing critical data ########################################
# Note - a missing mos_trapping:eventID was usually a collection cup with no target taxa present.
#          In 23 cases, there was no eventID and targetTaxaPresent was 'U' (unknown)

# Define important data colums
cols_oi_trap <- c('collectDate', 'eventID', 'namedLocation', 'sampleID')
cols_oi_sort <- c('collectDate', 'sampleID', 'namedLocation', 'subsampleID')
cols_oi_arch <- c('startCollectDate', 'archiveID', 'namedLocation')
cols_oi_exp_proc <- c('collectDate', 'subsampleID', 'namedLocation')

# Remove rows with missing important data, replacing blank with NA and factors with characters
mos_trapping <- mutate_at(mos_trapping, cols_oi_trap[-1], list(~na_if(as.character(.), ""))) %>%
  drop_na(all_of(cols_oi_trap)) %>%
  mutate_if(is.factor, as.character)
mos_sorting <- mutate_at(mos_sorting, cols_oi_sort[-1], list(~na_if(., ""))) %>%
  drop_na(all_of(cols_oi_sort)) %>%
  mutate_if(is.factor, as.character)
mos_archivepooling <- mutate_at(mos_archivepooling, cols_oi_arch[-1], list(~na_if(., ""))) %>%
  drop_na(all_of(cols_oi_arch)) %>%
  mutate_if(is.factor, as.character)
mos_expertTaxonomistIDProcessed <-
  mutate_at(mos_expertTaxonomistIDProcessed, cols_oi_exp_proc[-1], list(~na_if(., ""))) %>%
  drop_na(all_of(cols_oi_exp_proc)) %>%
  mutate_if(is.factor, as.character)


# Look for duplicate sampleIDs #################################################
length(which(duplicated(mos_trapping$sampleID)))  # 0
length(which(duplicated(mos_sorting$subsampleID))) # 0
length(which(duplicated(mos_archivepooling$archiveID))) # 0

# Make sure no "upstream" records are missing primary "downstream" reference
length(which(!mos_sorting$sampleID %in% mos_trapping$sampleID))  # 3164
length(which(!mos_trapping$sampleID %in% mos_sorting$sampleID))  # 1700
length(which(!mos_expertTaxonomistIDProcessed$subsampleID %in% mos_sorting$subsampleID))  # 0

# Clear expertTaxonomist:individualCount if it is 0 and there is no taxonID. These aren't ID'ed samples
mos_expertTaxonomistIDProcessed$individualCount[mos_expertTaxonomistIDProcessed$individualCount == 0 &
                                                  is.na(mos_expertTaxonomistIDProcessed$taxonID)] <- NA


#################################################################################
# Join data

# Add trapping info to sorting table --------------------------------------------
# Note - 59 trapping records have no associated sorting record and don't come through the left_join (even though targetTaxaPresent was set to Y or U)
data_mosquito <- mos_sorting %>%
  select(-c(collectDate, domainID, namedLocation, plotID, setDate, siteID)) %>%
  left_join(select(mos_trapping,-uid),by = 'sampleID') %>%
  rename(sampCondition_sorting = sampleCondition.x,
         sampCondition_trapping = sampleCondition.y,
         remarks_sorting = remarks,
         dataQF_trapping = dataQF)

# Verify sample barcode consistency before removing one column
which(data_mosquito$sampleCode.x != data_mosquito$sampleCode.y)

# Consistency is fine with barcodes
data_mosquito <- rename(data_mosquito,sampleCode = sampleCode.x) %>%
  select(-sampleCode.y)


# Join expert ID data ------------------------------------------------------------
data_mosquito <- data_mosquito %>%
  left_join(select(mos_expertTaxonomistIDProcessed,
                   -c(uid,collectDate,domainID,namedLocation,plotID,setDate,siteID,targetTaxaPresent)),
            by = 'subsampleID') %>%
  rename(remarks_expertID = remarks)

# Verify sample barcode and labName consistency before removing one column
which(data_mosquito$subsampleCode.x != data_mosquito$subsampleCode.y)
which(data_mosquito$laboratoryName.x != data_mosquito$laboratoryName.y)

# Rename columns and add estimated total individuals for each subsample/species/sex with identification, where applicable
#  Estimated total individuals = # individuals iD'ed * (total subsample weight/ subsample weight)
data_mosquito <- rename(data_mosquito, subsampleCode = subsampleCode.x, laboratoryName = laboratoryName.x) %>%
  select(-c(subsampleCode.y, laboratoryName.y)) %>%
  mutate(estimated_totIndividuals = ifelse(!is.na(individualCount), round(individualCount * (totalWeight/subsampleWeight)), NA))


# Add archive data ----------------------------------------------------------------
data_mosquito <- data_mosquito %>%
  left_join(select(mos_archivepooling,-c(domainID,uid,namedLocation,siteID)),by = 'archiveID')

# Verify sample barcode consistency before removing one column
which(data_mosquito$archiveIDCode.x != data_mosquito$archiveIDCode.y)

# Consistency is fine with barcodes
data_mosquito <- rename(data_mosquito,archiveIDCode = archiveIDCode.x) %>%
  select(-archiveIDCode.y)

# select essential columns
str(data_mosquito)

sum(is.na(data_mosquito$siteID)) # why 11213 record do not have siteID?
sum(is.na(data_mosquito$sampleID)) # why 11213 record do not have siteID?
sum(is.na(data_mosquito$individualCount)) # 1824
table(data_mosquito$taxonRank)

filter(data_mosquito, is.na(individualCount))

data_mosquito = dplyr::select(data_mosquito, domainID, siteID, plotID, decimalLatitude,
                              decimalLongitude, sampleID, )
data_mosquito = data_mosquito[, c(essential_cols, "sampleID", "startCollectDate", "endCollectDate",
                  "individualCount", "trapHours", "nightOrDay", "sex", "targetTaxaPresent")]

usethis::use_data(data_mosquito, overwrite = TRUE)
