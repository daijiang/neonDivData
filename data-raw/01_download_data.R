neon_data_list_mosquito <- neonUtilities::loadByProduct(dpID = "DP1.10043.001", site = "all", check.size = F, package = "expanded", include.provisional = FALSE, token = Sys.getenv("NEON_TOKEN"))
file_n <- paste0("./data-raw/NEON_raw_data/mosquito_DP1.10043.001_", format(Sys.time(), "%Y%m%d%H%M"), ".RDS")
saveRDS(neon_data_list_mosquito, file = file_n)

#' Clean NEON Mosquito Data
#'
#' @param neon_data_list NEON data list for DP1.10043.001
#' @return Flattened tibble of mosquito abundances
#' @importFrom dplyr select left_join mutate filter rename as_tibble
#' @export
clean_neon_mosquito <- function(neon_data_list) {
    # 1. Clean core tables using the helper function
    mos_trapping <- standardize_neon_table(
        neon_data_list$mos_trapping,
        required_cols = c("sampleID", "collectDate", "eventID", "namedLocation")
    )

    mos_sorting <- standardize_neon_table(
        neon_data_list$mos_sorting,
        required_cols = c("sampleID", "subsampleID", "collectDate", "namedLocation")
    )

    mos_expertID <- standardize_neon_table(
        neon_data_list$mos_expertTaxonomistIDProcessed,
        required_cols = c("subsampleID", "collectDate", "namedLocation")
    )

    # Clear counts for unidentified taxa
    mos_expertID$individualCount[mos_expertID$individualCount == 0 & is.na(mos_expertID$taxonID)] <- NA

    # 2. Relational Joins
    mos_dat <- mos_sorting |>
        dplyr::select(-c(uid, collectDate, domainID, namedLocation, plotID, setDate, siteID)) |>
        dplyr::left_join(
            dplyr::select(mos_trapping, -uid),
            by = c("sampleID", "sampleCode"),
            suffix = c("_sorting", "_trapping")
        ) |>
        dplyr::left_join(
            dplyr::select(mos_expertID, -c(collectDate, domainID, namedLocation, plotID, setDate, siteID, targetTaxaPresent)),
            by = c("subsampleID", "subsampleCode"),
            suffix = c("", "_expertID"),
            multiple = "all"
        )

    # 3. Handle duplicates using the helper function
    mos_dat <- resolve_neon_duplicates(mos_dat, count_col = "individualCount")

    # 4. Filter data quality & calculate abundance metrics
    mos_dat <- mos_dat |>
        dplyr::filter(
            !is.na(taxonID),
            targetTaxaPresent == "Y",
            sampleCondition == "No known compromise",
            taxonRank != "family"
        ) |>
        dplyr::mutate(
            estimated_totIndividuals = ifelse(!is.na(individualCount), individualCount / proportionIdentified, NA),
            value = estimated_totIndividuals / trapHours
        ) |>
        dplyr::filter(
            is.finite(value), value >= 0,
            is.finite(proportionIdentified), proportionIdentified >= 0,
            is.finite(trapHours), trapHours >= 0
        ) |>
        dplyr::distinct()

    # 5. Build final flat neonDivData tibble
    final_tibble <- mos_dat |>
        dplyr::mutate(
            observation_datetime = as.Date(collectDate),
            variable_name = "abundance",
            unit = "count per trap hour",
            unique_sample_id = sampleID
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id = taxonID,
            taxon_name = scientificName,
            taxon_rank = taxonRank,
            latitude = decimalLatitude,
            longitude = decimalLongitude
        ) |>
        dplyr::select(
            location_id,
            siteID,
            unique_sample_id,
            subsampleID,
            observation_datetime,
            taxon_id,
            taxon_name,
            taxon_rank,
            variable_name,
            value,
            unit,
            nativeStatusCode,
            proportionIdentified,
            release,
            remarks_sorting = remarks,
            samplingProtocolVersion,
            sex,
            sortDate,
            trapHours,
            latitude,
            longitude,
            elevation,
            nlcdClass,
            plotType
        ) |>
        dplyr::as_tibble()

    return(final_tibble)
}
