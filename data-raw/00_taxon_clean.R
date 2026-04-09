#' Clean NEON Plant Data
#' @param neon_data_list DP1.10058.001 raw data
#' @importFrom dplyr select mutate filter bind_rows rename distinct any_of as_tibble
#' @importFrom tidyr drop_na
#' @importFrom stringr str_extract str_remove str_detect
#' @export
clean_neon_plant <- function(neon_data_list) {
    # 1. Process 1m2 Data
    div_1m2_pla <- neon_data_list$div_1m2Data |>
        dplyr::filter(divDataType == "plantSpecies") |>
        dplyr::filter(targetTaxaPresent != "N") |>
        tidyr::drop_na(plotID, subplotID, boutNumber, endDate, taxonID) |>
        dplyr::mutate(
            year = substr(as.character(endDate), 1, 4),
            primaryKey = paste(plotID, boutNumber, year, taxonID, subplotID, sep = "_"),
            # Map the base plot removal directly to key3 for the cross-table join
            # e.g., change from BART_006_1_2014_ACSA3_32_1_2 to ...32_2 (point to the 10m2 area)
            key2 = paste(plotID, boutNumber, year, taxonID, stringr::str_replace(subplotID, "_1_", "_"), sep = "_"),
            # e.g., change from BART_006_1_2014_ACSA3_32_2 to ...32 (point to the 100m2 area)
            key3 = stringr::str_remove(key2, "_[0-9]$"),
            sample_area_m2 = 1,
            variable_name = "percent cover",
            value = percentCover,
            unit = "percent of plot area covered by taxon"
        ) |>
        as_tibble()

    # select(div_1m2_pla, primaryKey, key2, key3) |> unique() |> head(20) |> as.data.frame()

    # 2. Process 10m2 and 100m2 Data
    div_10_100_m2 <- neon_data_list$div_10m2Data100m2Data |>
        tidyr::drop_na(plotID, subplotID, boutNumber, endDate, taxonID) |>
        dplyr::mutate(
            year = substr(as.character(endDate), 1, 4),
            primaryKey = paste(plotID, boutNumber, year, taxonID, subplotID, sep = "_"),
            # point to the 10m2 area, e.g., 32_2
            key2 = stringr::str_replace(primaryKey, "_10_", "_"),
            # point to the 100m2 area, e.g., 32
            key3 = stringr::str_remove(key2, "_[0-9]{1,3}$") # _1 or _2 or _100 etc.
        ) |>
        as_tibble()

    # select(div_10_100_m2, primaryKey, key2, key3) |> unique() |> head(20) |> as.data.frame()

    # 3. NEON CUMULATIVE NESTING LOGIC (Using updated underscore regex)
    # Drop species already found in 1m2
    div_10_100_m2_2 <- dplyr::filter(div_10_100_m2, !key2 %in% unique(div_1m2_pla$key2))

    # Isolate 10m2 species
    div_10_100_m2_3 <- dplyr::filter(div_10_100_m2_2, stringr::str_detect(primaryKey, "_10_"))

    # Isolate 100m2 species (removing those already in 1m2 or 10m2)
    div_10_100_m2_4 <- dplyr::filter(
        div_10_100_m2_2, stringr::str_detect(key2, "_100$"),
        !key3 %in% unique(c(div_1m2_pla$key3, div_10_100_m2_3$key3))
    )

    div_10_100_m2_final <- dplyr::bind_rows(
        dplyr::mutate(div_10_100_m2_3, sample_area_m2 = 10),
        dplyr::mutate(div_10_100_m2_4, sample_area_m2 = 100)
    ) |>
        dplyr::mutate(
            variable_name = "presence absence",
            value = NA_real_,
            unit = NA_character_
        )

    # 4. Stack Data and format variables
    data_plant <- dplyr::bind_rows(div_1m2_pla, div_10_100_m2_final) |>
        dplyr::distinct() |>
        dplyr::filter(taxonRank %in% c("variety", "subspecies", "species", "speciesGroup", "genus")) |>
        dplyr::mutate(
            # Safely extract subplot strings regardless of character length
            subplot_id = stringr::str_extract(subplotID, "^[0-9]+"),
            subsubplot_id = stringr::str_extract(subplotID, "(?<=_)[0-9]+$"),
            observation_datetime = as.POSIXct(endDate, tz = "UTC"),
            unique_sample_id = paste0(namedLocation, "_", subplot_id, "_", year, "-", boutNumber),
            presence_absence = 1
        )

    # 5. Select and map to neonDivData flat format
    final_tibble <- data_plant |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id = taxonID,
            taxon_name = scientificName,
            taxon_rank = taxonRank,
            latitude = decimalLatitude,
            longitude = decimalLongitude
        ) |>
        dplyr::select(dplyr::any_of(c(
            "location_id", "siteID", "plotID", "unique_sample_id", "subplotID", "subplot_id", "subsubplot_id",
            "observation_datetime", "taxon_id", "taxon_name", "taxon_rank",
            "variable_name", "value", "unit", "presence_absence", "boutNumber",
            "nativeStatusCode", "heightPlantOver300cm", "heightPlantSpecies", "sample_area_m2",
            "latitude", "longitude", "elevation", "plotType", "nlcdClass"
        ))) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}


count(final_tibble, sample_area_m2)
count(neonDivData::data_plant, sample_area_m2)
setdiff(names(neonDivData::data_plant), names(final_tibble)) # release

dd = final_tibble |>
    dplyr::filter(as.Date(observation_datetime) <= as.Date("2023-11-08"))
n_distinct(dd$taxon_name) # 7019
n_distinct(neonDivData::data_plant$taxon_name) # 6859

neon_data_list <- neonUtilities::loadByProduct(dpID = "DP1.10058.001", site = "all", check.size = F, package = "expanded", include.provisional = FALSE, token = Sys.getenv("NEON_TOKEN"))
neon_data_list <- readRDS("./data-raw/NEON_raw_data/DP1.10058.001_20260407155657.RDS")
file_n <- paste0("plant_DP1.10058.001_", format(Sys.time(), "%Y%m%d%H%M"), ".RDS")
saveRDS(neon_data_list, file = file_n)

data_plant <- clean_neon_plant(neon_data_list)
n_distinct(data_plant$taxon_name) # 7047

## birds ====
neon_data_list <- readRDS("./data-raw/NEON_raw_data/DP1.10003.001_20260408100445.RDS")
#' Clean NEON Bird Data
#' Retrieves and cleans Bird point count data (DP1.10003.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join mutate filter rename any_of as_tibble distinct
#' @export
clean_neon_bird <- function(neon_data_list) {
    # 1. Extract the two core tables
    brd_count <- neon_data_list$brd_countdata |> tidyr::as_tibble()
    brd_point <- neon_data_list$brd_perpoint |> tidyr::as_tibble()

    # 2. Join point metadata (weather, habitat) to the bird counts
    # We dynamically find the shared keys between the tables (like eventID, siteID, plotID)
    # while purposefully excluding columns that would create `.x`/`.y` duplicate conflicts.
    join_cols <- intersect(names(brd_count), names(brd_point))
    join_cols <- setdiff(join_cols, c("uid", "startDate", "identifiedBy", "measuredBy", "remarks", "release", "publicationDate"))

    brd_dat <- brd_count |>
        dplyr::left_join(
            dplyr::select(brd_point, -dplyr::any_of(c("uid", "startDate", "identifiedBy", "measuredBy", "samplingImpractical", "samplingImpracticalRemarks"))),
            by = join_cols,
            multiple = "all"
        )

    # 3. Clean and map variables
    brd_dat <- brd_dat |>
        # Keep NAs only if they represent a valid sampling effort where no birds were seen
        dplyr::filter(
            is.finite(clusterSize) | targetTaxaPresent == "N",
            clusterSize >= 0,
            !is.na(clusterSize)
        ) |>
        dplyr::mutate(
            # Bird observations require datetime (POSIXct), not just Date
            observation_datetime = as.POSIXct(startDate, tz = "UTC"),
            variable_name = "cluster size",
            unit = "count of individuals",
            value = clusterSize,
            unique_sample_id = eventID
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id = taxonID,
            taxon_name = scientificName,
            taxon_rank = taxonRank,
            latitude = decimalLatitude,
            longitude = decimalLongitude
        )

    # 4. Format exactly to the neonDivData target tibble
    final_tibble <- brd_dat |>
        dplyr::select(dplyr::any_of(c(
            "location_id", "siteID", "plotID", "pointID", "unique_sample_id",
            "observation_datetime", "taxon_id", "taxon_name", "taxon_rank",
            "variable_name", "value", "unit", "pointCountMinute", "targetTaxaPresent",
            "nativeStatusCode", "observerDistance", "detectionMethod", "visualConfirmation",
            "sexOrAge", "release", "startCloudCoverPercentage", "endCloudCoverPercentage",
            "startRH", "endRH", "observedHabitat", "observedAirTemp",
            "kmPerHourObservedWindSpeed", "samplingProtocolVersion", "remarks",
            "clusterCode", "latitude", "longitude", "elevation", "nlcdClass", "plotType"
        ))) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}

setdiff(names(neonDivData::data_bird), names(final_tibble))
