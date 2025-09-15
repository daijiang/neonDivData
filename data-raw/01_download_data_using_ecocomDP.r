# Create data package for tidyNEON data using ecocomDP
# Eric R. Sokol
# 3/4/2021

# devtools::install_github("EDIorg/EMLassemblyline")
# devtools::install_github("EDIorg/ecocomDP@master")
# devtools::install_github("EDIorg/ecocomDP@development")
# devtools::install_github("sokole/ecocomDP@working")

if(!require(devtools)) install.packages("devtools")
if(!require(tidyverse)) install.packages("tidyverse", dependencies = TRUE)
if(!require(ecocomDP)) install.packages("ecocomDP")
# # install.packages("remotes")
# remotes::install_github("EDIorg/ecocomDP")
# remotes::install_github("EDIorg/ecocomDP", ref = "development")

library(ecocomDP)
library(tidyverse)


my_raw_dir <- "data-raw/NEON_raw_data"
my_out_dir <- "data-raw/neon_div_data"

# create out dir if it doesn't exist

if(!dir.exists(my_out_dir)) dir.create(my_out_dir)
if(!dir.exists(my_raw_dir)) dir.create(my_raw_dir)

# get list of available NEON data products
neon_ecocomdp_data_list <- ecocomDP::search_data("NEON")

# remove by catch of herp data https://github.com/EDIorg/ecocomDP/issues/157 
# no update for fish yet https://github.com/EDIorg/ecocomDP/issues/156 

neon_ecocomdp_data_list = filter(neon_ecocomdp_data_list, !id %in% c("neon.ecocomdp.10022.001.002",
                                                                    "neon.ecocomdp.20107.001.001"))

# initialize log table
data_set_log <- data.frame()

# loop through the data products
for(i in 1 : nrow(neon_ecocomdp_data_list)){
  
  # get method id
  my_dp_id <- neon_ecocomdp_data_list$id[i]
  
  # initialize vars
  data_list_i <- list()
  data_flat_i <- data.frame()
  
  # download data
  try({
    file_downloded = any(grepl(pattern = my_dp_id, x = list.files(my_out_dir)))
    if(file_downloded){ # already downloaded, just read in
      data_list_i = readRDS(grep(pattern = my_dp_id, 
                                 x = list.files(my_out_dir, full.names = TRUE), 
                                 value = TRUE))
    } else { # download it
      # if already downloaded
      id_f = sort(grep(str_replace(str_replace(my_dp_id, "neon\\.ecocomdp", "DP1"), "\\.[0-9]{3}$", ""), 
                  list.files(my_raw_dir, full.names = T), value = T))
      if(length(id_f) > 0){
        id_f_keep = id_f[length(id_f)] # keep the latest version
        # file.remove(id_f[-length(id_f)]) # remove older versions
      }
      
      data_list_i <- read_data(
        id = my_dp_id,
        # site= c('COMO','LECO','BART','NIWO'),
        # startdate = "2017-06",
        # enddate = "2029-02",
        neon.data.save.dir = my_raw_dir,
        neon.data.read.path = if(length(id_f) > 0) id_f_keep else NULL,
        token = Sys.getenv("NEON_TOKEN"),
        check.size = FALSE)
    }
    data_flat_i <- data_list_i$tables %>% ecocomDP::flatten_data() # flatten_ecocomDP not an exported object
  })
  
  try({
    if(length(data_list_i) > 0 && nrow(data_flat_i) > 0){
      
      release_info <- data_flat_i[,grepl("(?i)release", names(data_flat_i))] %>%
        unlist() %>% unique() %>% paste(., collapse = "|")
      
      release_doi <- data_list_i$metadata$orig_NEON_data_product_info$releases$productDoi.url %>%
        unique() %>% paste(., collapse = "|")
      
      # get data set info for log
      data_set_log_i <- data.frame(
        taxon_group = neon_ecocomdp_data_list$title[i] %>%
          stringr::str_split(" ") %>% unlist() %>% dplyr::first(),
        data_package_id = data_list_i$tables$dataset_summary$package_id,
        n_taxa = data_flat_i$taxon_id %>% unique() %>% length(),
        n_sites = data_flat_i$siteID %>% unique() %>% length(),
        sites = data_flat_i$siteID %>% unique() %>% paste(.,collapse = "|"),
        start_date = data_flat_i$datetime %>% # observation_datetime no longer available??
          lubridate::as_date() %>% min(na.rm = TRUE) %>% as.character(),
        end_date = data_flat_i$datetime %>%  # observation_datetime no longer available??
          lubridate::as_date() %>% max(na.rm = TRUE) %>% as.character(),
        data_package_title = neon_ecocomdp_data_list$title[i],
        neon_ecocomdp_mapping_method = my_dp_id,
        original_neon_data_product_id = data_list_i$tables$dataset_summary$original_package_id,
        original_neon_data_version = release_info,
        original_neon_data_doi = release_doi)
      
      # write data to out dir
      if(!file_downloded){
        package_id <- data_list_i$tables$dataset_summary$package_id
        package_filename <- paste0(my_out_dir, "/", package_id, ".RDS")
        saveRDS(data_list_i, file = package_filename)
      }
    }else{
      
      # write to log table with an error message that data were not found
      data_set_log_i <- data.frame(
        taxon_group = neon_ecocomdp_data_list$title[i] %>%
          stringr::str_split(" ") %>% unlist() %>% dplyr::first(),
        data_package_id = "ERROR:DATA NOT FOUND",
        n_taxa = NA,
        n_sites = NA,
        sites = NA_character_,
        start_date = NA_character_,
        end_date = NA_character_,
        data_package_title = neon_ecocomdp_data_list$title[i],
        neon_ecocomdp_mapping_method = my_dp_id,
        original_neon_data_product_id = neon_ecocomdp_data_list$source_id[i],
        original_neon_data_version = NA_character_)
    }
    
  })
  
  
  # log data set
  try({
    data_set_log <- dplyr::bind_rows(data_set_log, data_set_log_i)
  })
  
  # indexing
  message(paste0("Finished ", my_dp_id, " | ", i, " out of ", nrow(neon_ecocomdp_data_list)))
}


# write out data set log file
my_filename <- paste0(my_out_dir, "/dataset_log.txt")

readr::write_delim(data_set_log, file = my_filename, delim = "\t")
