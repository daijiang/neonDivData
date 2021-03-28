# Create data package for tidyNEON data using ecocomDP
# Eric R. Sokol
# 3/4/2021

# devtools::install_github("EDIorg/EMLassemblyline")
# devtools::install_github("EDIorg/ecocomDP@master")
# devtools::install_github("sokole/ecocomDP@working")

library(ecocomDP)
library(tidyverse)


my_out_dir <- "data-raw/neon_div_data"
my_raw_dir <- "data-raw/NEON_raw_data"

# create out dir if it doesn't exist
if(!my_out_dir %in% list.files()) dir.create(my_out_dir)
if(!my_raw_dir %in% list.files()) dir.create(my_raw_dir)

# get list of available NEON data products
neon_ecocomdp_data_list <- ecocomDP::search_data("NEON")

# initialize log table
data_set_log <- data.frame()

# loop through the data products
for(i in 1:nrow(neon_ecocomdp_data_list)){

  # get method id
  my_dp_id <- neon_ecocomdp_data_list$id[i]

  # initialize vars
  data_list_i <- list()
  data_flat_i <- data.frame()

  # download data
  try({
    data_list_i <- read_data(
      id = my_dp_id,
      # site= c('COMO','LECO','BART','NIWO'),
      # startdate = "2017-06",
      # enddate = "2029-02",
      neon.data.save.dir = my_raw_dir,
      token = Sys.getenv("NEON_TOKEN"),
      check.size = FALSE)

    data_flat_i <- data_list_i[[1]]$tables %>% ecocomDP::flatten_ecocomDP()

  })

  try({
    if(length(data_list_i) > 0 && nrow(data_flat_i) > 0){

      release_info <- data_flat_i[,grepl("(?i)release", names(data_flat_i))] %>%
        unlist() %>% unique() %>% paste(.,collapse = "|")

      release_doi <- data_list_i[[1]]$metadata$orig_NEON_data_product_info$releases$productDoi.url %>%
        unique() %>% paste(.,collapse = "|")

      # get data set info for log
      data_set_log_i <- data.frame(
        taxon_group = neon_ecocomdp_data_list$title[i] %>%
          stringr::str_split(" ") %>% unlist() %>% dplyr::first(),
        data_package_id = data_list_i[[1]]$tables$dataset_summary$package_id,
        n_taxa = data_flat_i$taxon_id %>% unique() %>% length(),
        n_sites = data_flat_i$siteID %>% unique() %>% length(),
        sites = data_flat_i$siteID %>% unique() %>% paste(.,collapse = "|"),
        start_date = data_flat_i$observation_datetime %>%
          lubridate::as_date() %>% min(na.rm = TRUE) %>% as.character(),
        end_date = data_flat_i$observation_datetime %>%
          lubridate::as_date() %>% max(na.rm = TRUE) %>% as.character(),
        data_package_title = neon_ecocomdp_data_list$title[i],
        neon_ecocomdp_mapping_method = my_dp_id,
        original_neon_data_product_id = data_list_i[[1]]$tables$dataset_summary$original_package_id,
        original_neon_data_version = release_info,
        original_neon_data_doi = release_doi)

      # write data to out dir
      package_id <- data_list_i[[1]]$tables$dataset_summary$package_id
      package_filename <- paste0(my_out_dir, "/", package_id, ".RDS")
      saveRDS(data_list_i, file = package_filename)

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
  message(paste0("Finished ",my_dp_id, " | ", i, " out of ", nrow(neon_ecocomdp_data_list)))

}


# write out data set log file
my_filename <- paste0(my_out_dir, "/dataset_log.txt")

readr::write_delim(
  data_set_log,
  file = my_filename,
  delim = "\t")
