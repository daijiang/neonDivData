# Species accumulation figure for Beetles

library(tidyverse)
library(iNEXT)
library(lubridate)

# Load beetle data product
load("~/GitHub/neonDivData/data/data_beetle.rda")

# Generate a separate year column from collectDate
data_beetle <- mutate(data_beetle, Year = year(collectDate))

# Subset data for ORNL 
ORNLbeetle <- data_beetle %>%
  filter(siteID == "ORNL")

# See what date range of sampling has been (2014-2020)
range(ORNLbeetle$collectDate)

# Get number of individuals across entire sampling time ranked by genus
gtosubsp <- ORNLbeetle %>%
  filter(taxonRank == "genus" | taxonRank == "species" | taxonRank == "subspecies")

# create a vector of genus names for all records from ORNL and append to gtosubsp dataframe
genus <- rep(NA, length = dim(gtosubsp)[1])
for(i in 1:dim(gtosubsp)[1]){
  genus[i] <- strsplit(gtosubsp$scientificName[i], ' ')[[1]][1]
}
gtosubsp <- cbind(gtosubsp, genus)

# create a vector of species names for all records from ORNL and append to gtosubsp dataframe
species <- rep(NA, length = dim(gtosubsp)[1])
for(i in 1:dim(gtosubsp)[1]){
  species[i] <- strsplit(gtosubsp$scientificName[i], ' ')[[1]][2]
}
gtosubsp <- cbind(gtosubsp, species)

# Create vectors of abundances by genus, species, and subspecies
by_genus <- gtosubsp %>%
  group_by(genus) %>%
  summarise(count=n())

by_species <- gtosubsp %>%
  group_by(species) %>%
  summarise(count=n())

by_subspecies <- gtosubsp %>%
  group_by(scientificName) %>%
  summarise(count=n())

# Put taxonomic rank by abundance summaries into a list as required by iNEXT functions
by_rank <- list(genus = by_genus$count, species = by_species$count, subspecies = by_subspecies$count)

# Create iNEXT object for ORNL beetle data
out <- iNEXT(by_rank, q=c(0,1,2), datatype="abundance")

# Plot species diversity of orders q=0,1,2 for different taxnomic subsets                 
beetle_rarefac <- ggiNEXT(out, type=1, facet.var="site")

# Export pdf to GitHub
ggsave("~/GitHub/neonDivData/manuscript/figures/beetle_rarefaction.pdf", plot = beetle_rarefac, width = 10, height = 7)
