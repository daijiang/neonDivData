library(tidyverse)

summary(final_tibble)
summary(neonDivData::data_small_mammal)
summary(neonDivData::data_algae)
summary(neonDivData::data_macroinvertebrate)
summary(neonDivData::data_tick)
summary(neonDivData::data_tick_pathogen)
summary(neonDivData::data_zooplankton)
count(neon_data_list$mam_perplotnight, samplingImpractical)



# birds:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.10003.001_20250915210119.RDS")
# mosquito:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.10043.001_20250915205427.RDS")
# beetle:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.10022.001_20250915173625.RDS")
# small mammal:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.10072.001_20250915162316.RDS")
# algae:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.20166.001_20250915154912.RDS")
# macroinvertebrate:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.20120.001_20250915175555.RDS")
# ticks:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.10093.001_20250915214147.RDS")
# tick pathogen:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.10092.001_20250915215031.RDS")
# zooplankton:
neon_data_list <- readRDS("./data-raw/NEON_raw_data_2025/DP1.20219.001_20250915214447.RDS")

x <- clean_neon_beetle(neon_data_list)
