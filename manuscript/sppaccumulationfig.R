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

# Get number of individuals across entire sampling time ranked by family
f <- ORNLbeetle %>%
  filter(taxonRank == "family")

# Get number of individuals across entire sampling time ranked by genus
g <- ORNLbeetle %>%
  filter(taxonRank == "genus")

# Get number of individuals across entire sampling time ranked by species   
sp <- ORNLbeetle %>%
  filter(taxonRank == "species")

