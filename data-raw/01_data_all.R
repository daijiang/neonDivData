source("data-raw/00_pkg_functions.R")

# algae data ------------------
# https://data.neonscience.org/data-products/DP1.20166.001
data_algae = map_neon_data_to_ecocomDP.ALGAE(neon.data.product.id = "DP1.20166.001")
loc_algae = dplyr::select(data_algae, domainID, siteID, namedLocation, aquaticSiteType, decimalLatitude,
                          decimalLongitude, geodeticDatum, coordinateUncertainty,
                          elevation, elevationUncertainty) %>%
  dplyr::distinct()

taxa_algae = dplyr::select(data_algae, acceptedTaxonID, scientificName, family,
                           taxonRank, identificationReferences) %>%
  dplyr::distinct()
any(duplicated(taxa_algae$acceptedTaxonID))
filter(taxa_algae, duplicated(acceptedTaxonID))
filter(taxa_algae, acceptedTaxonID == "NEONDREX37010")
# same species has multiple references; this can be problematic when join back to
# the data frame...
taxa_algae = taxa_algae %>%
  group_by(acceptedTaxonID, scientificName, family, taxonRank) %>%
  summarise(identificationReferences = paste(unique(identificationReferences),
                                             collapse = "; "), .groups = "drop")
taxa_algae$identificationReferences[1:5]

data_algae = dplyr::select(data_algae, -domainID, -aquaticSiteType, -decimalLatitude,
                           -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                           -elevation, -elevationUncertainty, -identificationReferences) %>%
  dplyr::distinct()

usethis::use_data(data_algae, overwrite = TRUE)


# beetle data ----
# https://data.neonscience.org/data-products/DP1.10022.001
data_beetle = map_neon_data_to_ecocomDP.BEETLE(neon.data.product.id = "DP1.10022.001")

loc_beetle = dplyr::select(data_beetle, domainID, siteID, plotID, namedLocation, nlcdClass, decimalLatitude,
                           decimalLongitude, geodeticDatum, coordinateUncertainty,
                           elevation, elevationUncertainty) %>%
  dplyr::distinct()
filter(loc_beetle, plotID == "ABBY_002")$decimalLatitude
filter(loc_plant, plotID == "ABBY_002")$decimalLatitude

taxa_beetle = dplyr::select(data_beetle, taxonID, scientificName, family,
                           taxonRank, identificationReferences) %>%
  dplyr::distinct()
any(duplicated(taxa_beetle$taxonID))
filter(taxa_beetle, duplicated(taxonID))
filter(taxa_beetle, taxonID == "OMUDEJ")
# same species has multiple references; this can be problematic when join back to
# the data frame...
taxa_beetle = taxa_beetle %>%
  group_by(taxonID, scientificName, taxonRank) %>%
  summarise(family = unique(family)[1],
    identificationReferences = paste(unique(identificationReferences),
                                             collapse = "; "), .groups = "drop")
taxa_beetle$identificationReferences[1:5]
any(duplicated(taxa_beetle$taxonID)) # should be FALSE


data_beetle = dplyr::select(data_beetle, -domainID, -plotType, -nlcdClass, -decimalLatitude,
                            -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                            -elevation, -elevationUncertainty, -identificationReferences) %>%
  dplyr::distinct()
data_beetle = dplyr::relocate(data_beetle, plotID, .after = siteID)

usethis::use_data(data_beetle, overwrite = TRUE)

# bird data ----
# https://data.neonscience.org/data-products/DP1.10003.001
data_bird = map_neon_data_to_ecocomDP.BIRD(neon.data.product.id = "DP1.10003.001")

loc_bird = dplyr::select(data_bird, domainID, siteID, plotID, namedLocation, nlcdClass, decimalLatitude,
                           decimalLongitude, geodeticDatum, coordinateUncertainty,
                           elevation, elevationUncertainty) %>%
  dplyr::distinct()
group_by(drop_na(data_bird, decimalLatitude), plotID) %>%
  summarise(n_long = n_distinct(decimalLongitude),
            n_lat = n_distinct(decimalLatitude)) %>%
  pull(n_long) %>% table() # all pointID have the same lat/long coord


taxa_bird = dplyr::select(data_bird, taxonID, scientificName, family,
                            taxonRank) %>%
  dplyr::distinct()
# no identificationReferences for species;
# it is available for each site though.

any(duplicated(taxa_bird$taxonID))


data_bird = dplyr::select(data_bird, -domainID, -plotType, -nlcdClass, -decimalLatitude,
                            -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                            -elevation, -elevationUncertainty, -remarks) %>%
  dplyr::distinct()

usethis::use_data(data_bird, overwrite = TRUE)


# fish data ----
# https://data.neonscience.org/data-products/DP1.20107.001
data_fish = map_neon_data_to_ecocomDP.FISH(neon.data.product.id = "DP1.20107.001")

loc_fish = dplyr::select(data_fish, domainID, siteID, namedLocation,
                         aquaticSiteType, decimalLatitude,
                         decimalLongitude, geodeticDatum, coordinateUncertainty,
                         elevation, elevationUncertainty) %>%
  dplyr::distinct()

taxa_fish = dplyr::select(data_fish, taxonID, scientificName, # family,
                          taxonRank, identificationReferences) %>%
  dplyr::distinct()
any(duplicated(taxa_fish$taxonID))

data_fish = dplyr::select(data_fish, -domainID, -aquaticSiteType, -decimalLatitude,
                          -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                          -elevation, -elevationUncertainty, -identificationReferences) %>% dplyr::distinct() %>%
  dplyr::select(siteID, namedLocation, reachID, eventID, samplerType, taxonID, taxonRank,
                scientificName, catch_per_effort, number_of_fish, n_obs, dplyr::everything())

usethis::use_data(data_fish, overwrite = TRUE)


# macro invertebrate data -------------------
# https://data.neonscience.org/data-products/DP1.20120.001
data_macroinvertebrate = map_neon_data_to_ecocomDP.MACROINVERTEBRATE(neon.data.product.id ="DP1.20120.001")
loc_macroinvertebrate = dplyr::select(data_macroinvertebrate, domainID, siteID, namedLocation,
                                      aquaticSiteType, decimalLatitude,
                                      decimalLongitude, geodeticDatum, coordinateUncertainty,
                                      elevation, elevationUncertainty) %>%
  dplyr::distinct()
filter(loc_macroinvertebrate, namedLocation == "LECO.AOS.reach") %>% as.data.frame()
filter(loc_algae, namedLocation == "LECO.AOS.reach") %>% as.data.frame()
bind_rows(loc_algae, loc_macroinvertebrate) %>% unique() %>% pull(namedLocation) %>% duplicated() %>% any()

taxa_macroinvertebrate = dplyr::select(data_macroinvertebrate, acceptedTaxonID, scientificName, family,
                            taxonRank, identificationReferences) %>%
  dplyr::distinct()
any(duplicated(taxa_macroinvertebrate$acceptedTaxonID))
filter(taxa_macroinvertebrate, duplicated(acceptedTaxonID))
filter(taxa_macroinvertebrate, acceptedTaxonID == "EPESP")
# same species has multiple references; this can be problematic when join back to
# the data frame...
taxa_macroinvertebrate = taxa_macroinvertebrate %>%
  group_by(acceptedTaxonID, scientificName, taxonRank) %>%
  summarise(family = unique(family)[1],
            identificationReferences = paste(unique(identificationReferences),
                                             collapse = "; "), .groups = "drop")
taxa_macroinvertebrate$identificationReferences[1:5]
any(duplicated(taxa_macroinvertebrate$acceptedTaxonID)) # should be FALSE

data_macroinvertebrate = dplyr::select(data_macroinvertebrate, -domainID, -aquaticSiteType, -decimalLatitude,
                                       -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                                       -elevation, -elevationUncertainty, -identificationReferences) %>%
  dplyr::distinct()

usethis::use_data(data_macroinvertebrate, overwrite = TRUE)

# mosquito data -------------
# https://data.neonscience.org/data-products/DP1.10043.001
data_mosquito = map_neon_data_to_ecocomDP.MOSQUITO(neon.data.product.id = "DP1.10043.001")
loc_mosquito = dplyr::select(data_mosquito, domainID, siteID, plotID, namedLocation, nlcdClass, decimalLatitude,
                          decimalLongitude, geodeticDatum, coordinateUncertainty,
                          elevation, elevationUncertainty) %>%
  dplyr::distinct()
filter(loc_mosquito, plotID == "BART_061")$decimalLatitude
filter(loc_plant, plotID == "BART_061")$decimalLatitude

taxa_mosquito = dplyr::select(data_mosquito, taxonID, scientificName, family,
                                       taxonRank, identificationReferences) %>%
  dplyr::distinct()
any(duplicated(taxa_mosquito$taxonID))
filter(taxa_mosquito, duplicated(taxonID))
filter(taxa_mosquito, taxonID == "CULBAH")
# same species has multiple references; this can be problematic when join back to
# the data frame...
taxa_mosquito = taxa_mosquito %>%
  group_by(taxonID, scientificName, taxonRank) %>%
  summarise(family = unique(family)[1],
            identificationReferences = paste(unique(identificationReferences),
                                             collapse = "; "), .groups = "drop")
taxa_mosquito$identificationReferences[1:5]
any(duplicated(taxa_mosquito$taxonID)) # should be FALSE

data_mosquito = dplyr::select(data_mosquito, -plotType, -domainID, -nlcdClass, -decimalLatitude,
                           -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                           -elevation, -elevationUncertainty, -identificationReferences) %>%
  dplyr::distinct()

usethis::use_data(data_mosquito, overwrite = TRUE)


# plant data ----
# https://data.neonscience.org/data-products/DP1.10058.001
data_plant = map_neon_data_to_ecocomDP.PLANT(neon.data.product.id = "DP1.10058.001")
# locations
x = dplyr::select(data_plant, domainID, siteID, plotID, subplotID, decimalLatitude, decimalLongitude) %>%
  unique() %>%
  group_by(plotID) %>%
  summarise(uniuqe_lat = n_distinct(decimalLatitude),
            unique_long = n_distinct(decimalLongitude))
table(x$uniuqe_lat)
table(x$unique_long)
# all subplots have the same plot level lat/long; plotType??? all NAs
loc_plant = dplyr::select(data_plant, domainID, siteID, plotID, namedLocation, nlcdClass, decimalLatitude,
                          decimalLongitude, geodeticDatum, coordinateUncertainty,
                          elevation, elevationUncertainty) %>%
  dplyr::distinct()

taxa_plant = dplyr::select(data_plant, taxonID, scientificName, family,
                              taxonRank, identificationReferences) %>%
  dplyr::distinct()
any(duplicated(taxa_plant$taxonID))
filter(taxa_plant, duplicated(taxonID))
filter(taxa_plant, taxonID == "ACPE")
# same species has multiple references; this can be problematic when join back to
# the data frame...
taxa_plant = taxa_plant %>%
  group_by(taxonID, scientificName, taxonRank) %>%
  summarise(family = unique(family)[1],
            identificationReferences = paste(unique(identificationReferences),
                                             collapse = "; "), .groups = "drop")
taxa_plant$identificationReferences[1:5]
any(duplicated(taxa_plant$taxonID)) # should be FALSE

data_plant = dplyr::select(data_plant, -domainID, -nlcdClass, -decimalLatitude,
                           -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                           -elevation, -elevationUncertainty, -identificationReferences)
data_plant = dplyr::relocate(data_plant, year, .after = boutNumber)

usethis::use_data(data_plant, overwrite = TRUE)


# small mammal ----
# https://data.neonscience.org/data-products/DP1.10072.001
data_small_mammal = map_neon_data_to_ecocomDP.SMALL.MAMMAL(neon.data.product.id = "DP1.10072.001")

loc_small_mammal = dplyr::select(data_small_mammal, domainID, siteID, plotID, namedLocation,
                                 nlcdClass, decimalLatitude,
                                 decimalLongitude, geodeticDatum, coordinateUncertainty,
                                 elevation, elevationUncertainty) %>%
  dplyr::distinct()

taxa_small_mammal = dplyr::select(data_small_mammal, taxonID, scientificName, # family,
                           taxonRank, identificationReferences) %>%
  dplyr::distinct() %>%
  tidyr::drop_na(taxonID)
any(duplicated(taxa_small_mammal$taxonID))
filter(taxa_small_mammal, duplicated(taxonID))
filter(taxa_small_mammal, taxonID == "PEMA")
# same species has multiple references; this can be problematic when join back to
# the data frame...
taxa_small_mammal = taxa_small_mammal %>%
  group_by(taxonID, scientificName, taxonRank) %>%
  summarise(identificationReferences = paste(unique(identificationReferences),
                                             collapse = "; "), .groups = "drop")
taxa_small_mammal$identificationReferences[1:5]
any(duplicated(taxa_small_mammal$taxonID)) # should be FALSE

data_small_mammal = dplyr::select(data_small_mammal, -domainID, -nlcdClass, -decimalLatitude,
                           -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                           -elevation, -elevationUncertainty, -identificationReferences) %>%
  dplyr::distinct()

usethis::use_data(data_small_mammal, overwrite = TRUE)

# tick data -----
# https://data.neonscience.org/data-products/DP1.10093.001
data_tick = map_neon_data_to_ecocomDP.TICK(neon.data.product.id = "DP1.10093.001")

loc_tick = dplyr::select(data_tick, domainID, siteID, plotID, namedLocation, nlcdClass, decimalLatitude,
                          decimalLongitude, geodeticDatum, coordinateUncertainty,
                          elevation, elevationUncertainty) %>%
  dplyr::distinct()

filter(loc_tick, plotID == "BART_002")$decimalLatitude # different
filter(loc_plant, plotID == "BART_002")$decimalLatitude

taxa_tick = dplyr::select(data_tick, acceptedTaxonID, scientificName, family,
                                       taxonRank, identificationReferences) %>%
  dplyr::distinct()
any(duplicated(taxa_tick$acceptedTaxonID)) # should be FALSE


data_tick = dplyr::select(data_tick, -domainID, -nlcdClass, -decimalLatitude,
                           -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                           -elevation, -elevationUncertainty, -identificationReferences)

dplyr::select(data_tick, targetTaxaPresent, IndividualCount) %>% distinct() %>%
  filter(targetTaxaPresent == "N")

usethis::use_data(data_tick, overwrite = TRUE)

# tick-borne pathogen data ----
# https://data.neonscience.org/data-products/DP1.10092.001
data_tick_pathogen = map_neon_data_to_ecocomDP.TICK.PATHOGEN(neon.data.product.id = "DP1.10092.001")

loc_tick_pathogen = dplyr::select(data_tick_pathogen, domainID, siteID, plotID,
                                  namedLocation, nlcdClass, decimalLatitude,
                         decimalLongitude, geodeticDatum, coordinateUncertainty,
                         elevation, elevationUncertainty) %>%
  dplyr::distinct() # subset of loc_tick

filter(loc_tick_pathogen, plotID == "HARV_001")$decimalLatitude # different
filter(loc_tick, plotID == "HARV_001")$decimalLatitude

data_tick_pathogen = dplyr::select(data_tick_pathogen, -domainID, -nlcdClass, -decimalLatitude,
                          -decimalLongitude, -geodeticDatum, -coordinateUncertainty,
                          -elevation, -elevationUncertainty, -plotType)

usethis::use_data(data_tick_pathogen, overwrite = TRUE)

# all locations together ----
# loc_plant = readRDS("~/Documents/loc_plant.rds")
# loc_algae = readRDS("~/Documents/loc_algae.rds")
# loc_beetle = readRDS("~/Documents/loc_beetle.rds")
# loc_fish = readRDS("~/Documents/loc_fish.rds")
# loc_macroinvertebrate = readRDS("~/Documents/loc_macroinvertebrate.rds")
# loc_mosquito = readRDS("~/Documents/loc_mosquito.rds")
# loc_small_mammal = readRDS("~/Documents/loc_small_mammal.rds")
# loc_tick_pathogen = readRDS("~/Documents/loc_tick_pathogen.rds")
# loc_tick = readRDS("~/Documents/loc_tick.rds")

loc_plant = dplyr::mutate(loc_plant, taxa = "plant", neonDPI = "DP1.10058.001")
loc_algae = dplyr::mutate(loc_algae, taxa = "algae", neonDPI = "DP1.20166.001")
loc_beetle = dplyr::mutate(loc_beetle, taxa = "beetle", neonDPI = "DP1.10022.001")
loc_bird = dplyr::mutate(loc_bird, taxa = "bird", neonDPI = "DP1.10003.001")
loc_fish = dplyr::mutate(loc_fish, taxa = "fish", neonDPI = "DP1.20107.001")
loc_macroinvertebrate = dplyr::mutate(loc_macroinvertebrate, taxa = "macroinvertebrate", neonDPI = "DP1.20120.001")
loc_mosquito = dplyr::mutate(loc_mosquito, taxa = "mosquito", neonDPI = "DP1.10043.001")
loc_small_mammal = dplyr::mutate(loc_small_mammal, taxa = "small_mammal", neonDPI = "DP1.10072.001")
loc_tick_pathogen = dplyr::mutate(loc_tick_pathogen, taxa = "tick_pathogen", neonDPI = "DP1.10092.001")
loc_tick = dplyr::mutate(loc_tick, taxa = "tick", neonDPI = "DP1.10093.001")

neon_locations = dplyr::bind_rows(loc_plant, loc_algae, loc_beetle, loc_bird, loc_fish, loc_macroinvertebrate,
                                  loc_mosquito, loc_small_mammal, loc_tick_pathogen, loc_tick)

usethis::use_data(neon_locations, overwrite = TRUE)

# site full names etc. ----
neon_sites = readr::read_csv("https://raw.githubusercontent.com/daijiang/ecocomDP/master/NEON_dev_script/neon-field-sites.csv")
neon_sites = dplyr::rename(neon_sites, siteID = 'Site ID', domainID = 'Domain Number')
usethis::use_data(neon_sites, overwrite = TRUE)

# a table to record latest update date? ----
data_modify_time = tibble::tribble(
  ~taxa,       ~neonDPI,
  "plant", "DP1.10058.001",
  "algae", "DP1.20166.001",
  "beetle", "DP1.10022.001",
  "bird", "DP1.10003.001",
  "fish", "DP1.20107.001",
  "macroinvertebrate", "DP1.20120.001",
  "mosquito", "DP1.10043.001",
  "small_mammal", "DP1.10072.001",
  "tick_pathogen", "DP1.10092.001",
  "tick", "DP1.10093.001") %>%
  dplyr::arrange(taxa) %>%
  mutate(modify_time = file.mtime(paste0("data/data_", taxa, ".rda")))

usethis::use_data(data_modify_time, overwrite = TRUE)

# all taxa names ----
taxa_plant = dplyr::mutate(taxa_plant, taxa = "plant", neonDPI = "DP1.10058.001")
taxa_algae = dplyr::mutate(taxa_algae, taxa = "algae", neonDPI = "DP1.20166.001")
taxa_beetle = dplyr::mutate(taxa_beetle, taxa = "beetle", neonDPI = "DP1.10022.001")
taxa_bird = dplyr::mutate(taxa_bird, taxa = "bird", neonDPI = "DP1.10003.001")
taxa_fish = dplyr::mutate(taxa_fish, taxa = "fish", neonDPI = "DP1.20107.001")
taxa_macroinvertebrate = dplyr::mutate(taxa_macroinvertebrate, taxa = "macroinvertebrate", neonDPI = "DP1.20120.001")
taxa_mosquito = dplyr::mutate(taxa_mosquito, taxa = "mosquito", neonDPI = "DP1.10043.001")
taxa_small_mammal = dplyr::mutate(taxa_small_mammal, taxa = "small_mammal", neonDPI = "DP1.10072.001")
taxa_tick = dplyr::mutate(taxa_tick, taxa = "tick", neonDPI = "DP1.10093.001")
# no tick pathogen taxa

neon_taxa = dplyr::bind_rows(taxa_plant, taxa_algae, taxa_beetle, taxa_bird,
                             taxa_fish, taxa_macroinvertebrate,
                             taxa_mosquito, taxa_small_mammal, taxa_tick)
neon_taxa = dplyr::relocate(neon_taxa, acceptedTaxonID, .after = taxonID)
usethis::use_data(neon_taxa, overwrite = TRUE)

