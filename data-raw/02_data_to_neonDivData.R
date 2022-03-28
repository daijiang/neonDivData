# Create data package for tidyNEON data using ecocomDP
# Eric R. Sokol
# 3/7/2021

# devtools::install_github("EDIorg/EMLassemblyline")
# devtools::install_github("EDIorg/ecocomDP@master")
# devtools::install_github("sokole/ecocomDP@working")

library(ecocomDP)
library(tidyverse)

# user provide input directory
my_in_dir <- "data-raw/neon_div_data"


# # read dp catalog
# data_catalog <- readr::read_delim(file = paste0(my_in_dir, "/dataset_log.txt"),
#                                   delim = '\t')
# # view data products
# print(data_catalog)


# fxn to read in data packages, option to make flat
read_data_package <- function(
  taxon_groups = NULL,
  data_package_ids = NULL,
  in_dir = "neon_div_data",
  return_flat_tables = TRUE){

  data_catalog <- readr::read_delim(file = paste0(in_dir, "/dataset_log.txt"),
                                    delim = '\t')

  data_catalog_taxon_groups <- data.frame()
  data_catalog_data_package_ids <- data.frame()

  if(!is.null(taxon_groups)) 
    data_catalog_taxon_groups <- dplyr::filter(data_catalog, taxon_group %in% taxon_groups)

  if(!is.null(data_package_ids)) 
    data_catalog_data_package_ids <- dplyr::filter(data_catalog, data_package_id %in% data_package_ids)

  data_catalog_filtered <- dplyr::bind_rows(data_catalog_taxon_groups,
                                            data_catalog_data_package_ids) %>%
    dplyr::distinct()

  if(nrow(data_catalog_filtered) > 0) data_catalog <- data_catalog_filtered


  # clean in_dir
  in_dir <- gsub("\\/$", "", in_dir)

  # if returning a list, rename list elements with taxon groups and datapackage ids
  if(!return_flat_tables) data_out <- sapply(
    1:nrow(data_catalog),
    function(i){
      dat <- list()
      try({
        dat <- readRDS(file = paste0(in_dir, "/", data_catalog$data_package_id[i],".RDS"))
        names(dat) <- paste0(
          data_catalog$taxon_group[i], "_",
          data_catalog$data_package_id[i])
      })
      if(length(dat)==0) warning(
        paste0(data_catalog$data_package_id[i], " not found in ",in_dir))
      if(length(dat) >0 ) message(paste0("Successfully loaded ",names(dat)))
      return(dat)
    }, simplify = TRUE)

  # if returning flat tables, add taxon group names to flat table
  if(return_flat_tables) data_out <- sapply(
    1:nrow(data_catalog),
    function(i){
      dat <- list()
      try({
        dat_list <- readRDS(file = paste0(in_dir, "/", data_catalog$data_package_id[i], ".RDS"))
        dat_flat <- tibble::tibble(taxon_group = data_catalog$taxon_group[i],
                                   ecocomDP::flatten_data(dat_list$tables))
        dat <- list(dat_flat)
        names(dat) <- paste0(data_catalog$taxon_group[i], "_", data_catalog$data_package_id[i])
      })
      if(length(dat)==0) warning(
        paste0(data_catalog$data_package_id[i], " not found in ",in_dir))
      if(length(dat) >0 ) message(paste0("Successfully loaded ",names(dat)))
      return(dat)
    }, simplify = TRUE)

  # return list
  return(data_out)
}

# # examples using filtering -- i.e., not reading in all data
# data <- read_data_package(
#   taxon_groups = "ALGAE", in_dir = my_in_dir,
#   return_flat_tables = TRUE)
#
# data <- read_data_package(
#   data_package_ids = "neon.ecocomdp.20166.001.001.20210306172623",
#   return_flat_tables = TRUE)
#
# data <- read_data_package(
#   taxon_groups = c("ALGAE","SMALL_MAMMALS"),
#   return_flat_tables = TRUE)

# read in all data in data_catalog, make a list of flat tables
data_all <- read_data_package(in_dir = my_in_dir)
names(data_all)

# d_fish = read_data_package(taxon_groups = "FISH", return_flat_tables = T)
# data_all$FISH_neon.ecocomdp.20107.001.001.20210306180225.RDS <- d_fish$FISH_neon.ecocomdp.20107.001.001.20210306180225

sapply(data_all, function(x) format(object.size(x), units = "Mb"))

map(data_all, names)

map(data_all, function(x) table(x$taxon_rank))

data_loc = lapply(data_all, function(x) {
  select(x, location_id, latitude, longitude, elevation) %>% 
    distinct()
})
# confirm that each location_id has only one lat/long/elev combination
all(!map_lgl(data_loc, function(x) any(duplicated(x$location_id))))
map_lgl(data_loc, function(x) any(duplicated(x$location_id)))
# remove any duplications by taking the means (and remove NAs)
data_loc = lapply(data_loc, function(x) {
  if(any(duplicated(x$location_id))){
    out = group_by(x, location_id) %>% 
      summarise_all(.funs = mean, na.rm = TRUE) %>% 
      ungroup()
  } else {
    out = x
  }
  out
})
data_loc_df = bind_rows(data_loc) %>% distinct()
n_distinct(data_loc_df$location_id)


# taxa info ----
# to save space, extract taxon names and save separately to avoid duplications
# in the long format
tax_var = c("taxon_id", "taxon_name", "taxon_rank", "taxon_group")
neon_taxa = lapply(data_all, function(x) dplyr::distinct(dplyr::select(x, all_of(tax_var))))
neon_taxa = bind_rows(neon_taxa) %>% distinct()
usethis::use_data(neon_taxa, overwrite = TRUE)

# Location info ----
# to save space, extract location information and save separately to avoid duplications
# in the long format
loc_var = c("location_id", "location_name", # "domainID",
            "siteID", "plotID",
            # "plotType", "samplerType", "habitatType", "observedHabitat",
            # "aquaticSiteType", "taxon_group"
             "latitude", "longitude", "elevation")
neon_location = lapply(data_all, function(x) dplyr::distinct(dplyr::select(x, any_of(loc_var))))
# tick pathogen's loc are the same as ticks
# neon_location = neon_location[-grep("TICK_PATHOGENS_neon.ecocomdp", names(neon_location))]
neon_location = bind_rows(neon_location) %>% distinct()
all(neon_location$location_id == neon_location$location_name)
n_distinct(neon_location$location_id)
neon_location[which(duplicated(neon_location$location_id)),]
# remove any duplications by taking the means (and remove NAs)
neon_location = dplyr::select(neon_location, location_id, location_name, siteID, plotID) %>% distinct() %>% 
  left_join(group_by(neon_location, location_id) %>% 
              summarise_at(.vars = c("latitude", "longitude", "elevation"), .funs = mean, na.rm = TRUE) %>% 
              ungroup(), by = "location_id")

des_file = tempfile(fileext = ".rda")
# previous version of neon_location
download.file("https://raw.githubusercontent.com/daijiang/neonDivData/long_format/data/neon_locations.rda", des_file)
load(des_file)
unlink(des_file)
names(neon_locations)
setdiff(neon_location$location_id, neon_locations$namedLocation) # new locations
setdiff(neon_locations$namedLocation, neon_location$location_id) # locations from old version but not here
# 13 not here, fine, not going to merge them
filter(neon_locations, namedLocation %in% setdiff(neon_locations$namedLocation, neon_location$location_id))
land_type = filter(neon_locations, namedLocation %in% intersect(neon_location$location_id, neon_locations$namedLocation)) %>%
  select(location_id = namedLocation, nlcdClass, aquaticSiteType) %>%
  # remove location_id without information
  filter(!(is.na(nlcdClass) & is.na(aquaticSiteType))) %>%
  distinct()
land_type[which(duplicated(land_type$location_id)),]
neon_location = left_join(neon_location, land_type, by = "location_id")
any(duplicated(neon_location$location_id))
# solve potential plotID issue
neon_location = mutate(neon_location,
                       plotID2 = gsub("^([A-Z]{4}_[0-9]{3}).*$", "\\1", location_id),
                       plotID2 = ifelse(grepl("[.]AOS[.]", plotID2), NA, plotID2))
sum(!is.na(neon_location$plotID))
sum(neon_location$plotID == neon_location$plotID2, na.rm = T) # confirm existing plotID are the same
filter(neon_location, !grepl("AOS", location_id), is.na(plotID)) # does not have plotID
neon_location = select(neon_location, -plotID, -location_name) %>%
  rename(plotID = plotID2) %>%
  relocate(plotID, .after = siteID)

# some locations do not have lat/long
problem_loc = filter(neon_location, is.na(latitude) & is.na(longitude))
setdiff(problem_loc$location_id, neon_locations$namedLocation)

neon_location = filter(neon_location, !location_id %in% problem_loc$location_id) %>%
  bind_rows( # use the information from old versions
    filter(neon_locations, namedLocation %in% problem_loc$location_id) %>%
      select(location_id = namedLocation, siteID, plotID, latitude = decimalLatitude,
             longitude = decimalLongitude, elevation, nlcdClass, aquaticSiteType)) %>%
  arrange(siteID, plotID, location_id)

neon_location$location_id[which(duplicated(neon_location$location_id))]
filter(neon_location, location_id %in% neon_location$location_id[which(duplicated(neon_location$location_id))])

neon_location[-which(neon_location$location_id == "SOAP_026.basePlot.brd" & is.na(neon_location$latitude)),] %>% 
  distinct()

neon_location = distinct(neon_location)

usethis::use_data(neon_location, overwrite = TRUE)

# decide to keep all location information in the observation data frames
# neon_location may be useful to just know where sites are from one file

# write test for nativeStatusCode
# should be in these groups: beetles, herp by catch, bird, mosquito, plant, small mammal
if (sum(map_lgl(map(data_all, names), function(x) "nativeStatusCode" %in% x )) < 6)
  message("Some taxa miss nativeStatusCode")


# simplify observation data ----
# also to save space, remove observation_id, etc. that are not essential for
# biodiversity calculation
all(map_lgl(data_all, function(x) all(x$location_id == x$location_name)))
map_lgl(data_all, function(x) all(x$observation_id == x$event_id))
data_all[map_lgl(data_all, function(x) all(x$observation_id == x$event_id))]
map(data_all, names)
map(data_all, function(x) any(duplicated(x$observation_id)))
map(data_all, function(x) any(duplicated(x$event_id)))

# creat a unique_sample_id ?
data_all = map(data_all, function(x){
  if(all(x$event_id == x$observation_id)){
    x$unique_sample_id = x$neon_event_id
  } else {
    x$unique_sample_id = x$event_id
  }
  x
})

map(data_all, names)

data_all2 = lapply(data_all, function(x)
  dplyr::select(x, -any_of(c("observation_id", "event_id",
                             "package_id", "authority_system",
                      "identificationReferences", "laboratoryName",
                      "location_name", "aquaticSiteType", "domainID", "publicationDate",
                      "neon_event_id", "geodeticDatum", 
                      "unit_trappingDays", "unit_totalWeight", "unit_subsampleWeight", "unit_trapHours",
                      "unit_totalSampledArea",
                      # "plotType", "samplerType", "habitatType",
                      # "observedHabitat", "latitude", "longitude", "elevation",
                      "original_package_id", "length_of_survey_years", "number_of_years_sampled", "sampleID", 
                      "std_dev_interval_betw_years", "max_num_taxa", "parentSampleID", "neon_sample_id",
                      "taxon_group"
                      ))) %>% dplyr::distinct() %>%
    dplyr::relocate(any_of(c("siteID", "plotID", "pointID", "unique_sample_id")), .after = location_id) %>%
    dplyr::relocate(taxon_name, taxon_rank, .after = taxon_id) %>% 
    rename(observation_datetime = datetime) %>% 
    dplyr::select(any_of(c("location_id", "siteID", "plotID", "pointID", "unique_sample_id", "subplotID",
                           "subsampleID", "trapID")),
                  observation_datetime, 
                  any_of(c("taxon_id", "taxon_name", "taxon_rank")), 
                  variable_name, value, unit, everything())
  )


map(data_all2, names)
map(data_all2, dim)

data_algae = data_all2[[grep(pattern = "ALGAE", x = names(data_all2))]]
data_beetle = data_all2[[grep(pattern = "BEETLE", x = names(data_all2))]]
data_bird = data_all2[[grep(pattern = "BIRD", x = names(data_all2))]]
data_fish = data_all2[[grep(pattern = "FISH", x = names(data_all2))]]
data_herp_bycatch = data_all2[[grep(pattern = "HERPTILE", x = names(data_all2))]]
data_macroinvertebrate = data_all2[[grep(pattern = "MACROINVERTEBRATE", x = names(data_all2))]]
data_mosquito = data_all2[[grep(pattern = "MOSQUITOE", x = names(data_all2))]]
data_plant = data_all2[[grep(pattern = "PLANT", x = names(data_all2))]]
data_small_mammal = data_all2[[grep(pattern = "SMALL_MAMMAL", x = names(data_all2))]]
data_tick = data_all2[[grep(pattern = "TICKS", x = names(data_all2))]]
data_tick_pathogen = data_all2[[grep(pattern = "TICK_PATHOGEN", x = names(data_all2))]]
data_zooplankton = data_all2[[grep(pattern = "ZOOPLANKTON", x = names(data_all2))]]

# remove variables that are not really important for users
table(gsub("^[A-Z]{4}|[0-9]", "", data_algae$parentSampleID))
# # neon_event_id is just site and date
# data_algae = select(data_algae, -parentSampleID, -neon_sample_id)

data_beetle = select(data_beetle, -plotType) # just plotID + trapID + date
# plotType are all "distributed"

# data_bird = select(data_bird, -endCloudCoverPercentage)

data_fish = mutate(data_fish, pointID = gsub(".*(point.*)$", "\\1", location_id)) %>%
  relocate(pointID, .after = siteID) %>%
  filter(taxon_rank %in% c("genus", "species", "subspecies"))
# to be consistent with the manuscript

# data_herp_bycatch seems fine
data_macroinvertebrate = mutate(data_macroinvertebrate,
                                ponarDepth = as.numeric(ponarDepth),
                                snagLength = as.numeric(snagLength),
                                snagDiameter = as.numeric(snagDiameter))

# data_mosquito seems fine
data_mosquito = filter(data_mosquito, !is.infinite(value)) # remove Inf values

table(data_plant$sample_area_m2)
table(data_plant$variable_name)
table(data_plant$unit)
mean(is.na(data_plant$value))
data_plant = mutate(data_plant,
                    # variable_name = ifelse(is.na(value), "presence absence", variable_name),
                    unit = ifelse(is.na(value), NA, unit),
                    subplot_id = substr(subplotID, 1, 2),
                    subsubplot_id = substr(subplotID, 4, 4),
                    presence_absence = 1) %>%
  relocate(subplot_id, subsubplot_id, .after = subplotID) %>%
  relocate(presence_absence, .after = unit)

data_small_mammal

# data_tick = select(data_tick, -neon_sample_id) # just plotID + date

# data_tick_pathogen seems fine

# data_zooplankton = select(data_zooplankton, -neon_sample_id)
# # just location id and date or siteID and date

map(data_all2, function(x) table(x$variable_name))

# remove NAs or Inf in values
data_algae = filter(data_algae, is.finite(value))
data_beetle = filter(data_beetle, is.finite(value))
data_bird = filter(data_bird, is.finite(value))
data_fish = filter(data_fish, is.finite(value))
data_herp_bycatch = filter(data_herp_bycatch, is.finite(value))
data_macroinvertebrate = filter(data_macroinvertebrate, is.finite(value))
data_mosquito = filter(data_mosquito, is.finite(value))
data_plant # plant is different, as NA represents presence/absence (instead of coverage)
data_small_mammal = filter(data_small_mammal, is.finite(value))
data_tick = filter(data_tick, is.finite(value))
data_tick_pathogen = filter(data_tick_pathogen, is.finite(value))
data_zooplankton = filter(data_zooplankton, is.finite(value))

usethis::use_data(data_algae, overwrite = TRUE)
usethis::use_data(data_beetle, overwrite = TRUE)
usethis::use_data(data_bird, overwrite = TRUE)
usethis::use_data(data_fish, overwrite = TRUE)
usethis::use_data(data_herp_bycatch, overwrite = TRUE)
usethis::use_data(data_macroinvertebrate, overwrite = TRUE)
usethis::use_data(data_mosquito, overwrite = TRUE)
usethis::use_data(data_plant, overwrite = TRUE)
usethis::use_data(data_small_mammal, overwrite = TRUE)
usethis::use_data(data_tick, overwrite = TRUE)
usethis::use_data(data_tick_pathogen, overwrite = TRUE)
usethis::use_data(data_zooplankton, overwrite = TRUE)

# data summary ----
data_summary <- readr::read_delim(file = paste0(my_in_dir, "/dataset_log.txt"), delim = '\t')
data_summary$r_object = NA
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.20166.001"] = "data_algae"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10022.001"] = "data_beetle"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10003.001"] = "data_bird"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.20107.001"] = "data_fish"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10022.001"] = "data_herp_bycatch"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.20120.001"] = "data_macroinvertebrate"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10043.001"] = "data_mosquito"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10058.001"] = "data_plant"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10072.001"] = "data_small_mammal"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10093.001"] = "data_tick"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.10092.001"] = "data_tick_pathogen"
data_summary$r_object[data_summary$original_neon_data_product_id == "DP1.20219.001"] = "data_zooplankton"

# data_summary$start_date[data_summary$r_object == "data_bird"] = lubridate::date(min(data_bird$observation_datetime, na.rm = T))
# data_summary$end_date[data_summary$r_object == "data_bird"] = lubridate::date(max(data_bird$observation_datetime, na.rm = T))

data_summary$variable_names = NA
data_summary$variable_names[data_summary$r_object == "data_algae"] = paste(unique(data_algae$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_beetle"] = paste(unique(data_beetle$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_bird"] = paste(unique(data_bird$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_fish"] = paste(unique(data_fish$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_herp_bycatch"] = paste(unique(data_herp_bycatch$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_macroinvertebrate"] = paste(unique(data_macroinvertebrate$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_mosquito"] = paste(unique(data_mosquito$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_plant"] = paste(unique(data_plant$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_small_mammal"] = paste(unique(data_small_mammal$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_tick"] = paste(unique(data_tick$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_tick_pathogen"] = paste(unique(data_tick_pathogen$variable_name), collapse = " OR ")
data_summary$variable_names[data_summary$r_object == "data_zooplankton"] = paste(unique(data_zooplankton$variable_name), collapse = " OR ")

data_summary$units = NA
data_summary$units[data_summary$r_object == "data_algae"] = paste(unique(data_algae$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_beetle"] = paste(unique(data_beetle$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_bird"] = paste(unique(data_bird$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_fish"] = paste(unique(data_fish$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_herp_bycatch"] = paste(unique(data_herp_bycatch$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_macroinvertebrate"] = paste(unique(data_macroinvertebrate$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_mosquito"] = paste(unique(data_mosquito$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_plant"] = paste(na.omit(unique(data_plant$unit)), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_small_mammal"] = paste(unique(data_small_mammal$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_tick"] = paste(unique(data_tick$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_tick_pathogen"] = paste(unique(data_tick_pathogen$unit), collapse = " OR ")
data_summary$units[data_summary$r_object == "data_zooplankton"] = paste(unique(data_zooplankton$unit), collapse = " OR ")
# data_summary$units = str_replace_all(data_summary$units, "NA", "Unitless")

usethis::use_data(data_summary, overwrite = TRUE)



