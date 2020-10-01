# Packages used
library(tidyverse)
# library(googledrive)
# remotes::install_github("EDIorg/ecocomDP")
library(ecocomDP)
library(neonUtilities)
library(lubridate)


essential_cols = c(
  "siteID", "plotID", "decimalLatitude", "decimalLongitude",
  "taxonRank", "scientificName", "family", "nativeStatusCode"
)
