neon_data_list_plant <- neonUtilities::loadByProduct(dpID = "DP1.10058.001", site = "all", check.size = F, package = "expanded", include.provisional = FALSE, token = Sys.getenv("NEON_TOKEN"))

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
        dplyr::filter(targetTaxaPresent != "N") |>
        dplyr::mutate(
            year = substr(as.character(endDate), 1, 4),
            primaryKey = paste(plotID, boutNumber, year, taxonID, subplotID, sep = "_"),
            # point to the 10m2 area, e.g., 32_2
            key2 = paste(plotID, boutNumber, year, taxonID, stringr::str_replace(subplotID, "_10_", "_"), sep = "_"),
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
#' Clean NEON Bird Data
#' Retrieves and cleans Bird point count data (DP1.10003.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join mutate filter rename any_of as_tibble distinct
#' @export
clean_neon_bird <- function(neon_data_list) {
    # 1. Extract the tables
    # Base table: Point counts. Keep only points that were actually surveyed.
    brd_point <- neon_data_list$brd_perpoint |>
        dplyr::filter(samplingImpractical == "OK") |>
        dplyr::distinct()

    brd_count <- neon_data_list$brd_countdata |>
        dplyr::distinct()

    # 2. Join DOWNWARD from Point to Count to preserve zero-bird surveys
    join_cols <- intersect(names(brd_count), names(brd_point))
    join_cols <- setdiff(join_cols, c("uid", "startDate", "identifiedBy", "measuredBy", "remarks", "publicationDate"))

    brd_dat <- brd_point |>
        dplyr::left_join(
            dplyr::select(brd_count, -dplyr::any_of(c("uid", "startDate", "identifiedBy", "measuredBy", "samplingImpractical", "samplingImpracticalRemarks"))),
            by = join_cols,
            relationship = "many-to-many" # Silences warning for multiple birds per point
        )

    # 3. Clean and map variables
    brd_dat <- brd_dat |>
        # Keep valid bird counts OR rows where clusterSize became NA (empty surveys)
        dplyr::filter(is.finite(clusterSize) | is.na(clusterSize) | targetTaxaPresent == "N") |>
        dplyr::mutate(
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


# mosquito ====
#' Clean NEON Mosquito Data
#' Retrieves and cleans Mosquito trapping and ID data (DP1.10043.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join mutate filter rename any_of as_tibble distinct coalesce
#' @importFrom tidyr drop_na
#' @export
clean_neon_mosquito <- function(neon_data_list) {
    # 1. Base table is TRAPPING to preserve zero-catch effort
    mos_trapping <- neon_data_list$mos_trapping |>
        tidyr::drop_na(collectDate, eventID, namedLocation, sampleID) |>
        dplyr::filter(as.numeric(trapHours) > 0) |> # Trap must have actually been deployed
        dplyr::distinct()

    # 2. Extract Sorting and Expert ID tables
    mos_sorting <- neon_data_list$mos_sorting |>
        tidyr::drop_na(sampleID, subsampleID) |>
        dplyr::rename(dplyr::any_of(c(remarks_sorting = "remarks"))) |> # Ensure remarks maps to remarks_sorting
        dplyr::distinct()

    mos_expert <- neon_data_list$mos_expertTaxonomistIDProcessed |>
        tidyr::drop_na(subsampleID) |>
        dplyr::distinct()

    # Clear individualCount if 0 and no taxonID (blanks/unidentified)
    mos_expert$individualCount[mos_expert$individualCount == 0 & is.na(mos_expert$taxonID)] <- NA

    # 3. Join DOWNWARD from Trapping to preserve all deployed traps
    mos_dat <- mos_trapping |>
        dplyr::left_join(
            dplyr::select(mos_sorting, -dplyr::any_of(c("uid", "collectDate", "domainID", "namedLocation", "plotID", "setDate", "siteID", "targetTaxaPresent"))),
            by = c("sampleID", "sampleCode"),
            suffix = c("_trapping", "_sorting"),
            relationship = "many-to-many"
        ) |>
        dplyr::left_join(
            dplyr::select(mos_expert, -dplyr::any_of(c("uid", "collectDate", "domainID", "namedLocation", "plotID", "setDate", "siteID", "targetTaxaPresent"))),
            by = c("subsampleID", "subsampleCode"),
            suffix = c("", "_expertID"),
            relationship = "many-to-many"
        )

    # 4. Handle duplicates securely (Keeping sex distinct)
    mos_dat <- resolve_neon_duplicates(
        mos_dat,
        group_cols = c("sampleID", "taxonID", "sex"),
        sum_col = "individualCount"
    )

    # 5. Math and Filtering
    mos_dat <- mos_dat |>
        dplyr::mutate(
            # BACKWARD COMPATIBILITY: Calculate proportionIdentified for older data
            proportionIdentified = if ("totalWeight" %in% names(mos_dat) && "subsampleWeight" %in% names(mos_dat)) {
                dplyr::coalesce(as.numeric(proportionIdentified), as.numeric(subsampleWeight) / as.numeric(totalWeight))
            } else {
                as.numeric(proportionIdentified)
            },

            # Estimated total = ID'd count / proportion of the subsample identified
            estimated_totIndividuals = ifelse(targetTaxaPresent == "N", NA_real_,
                ifelse(!is.na(individualCount), round(individualCount / proportionIdentified), NA_real_)
            )
        ) |>
        dplyr::filter(
            sampleCondition == "No known compromise",
            # Keep traps that caught nothing OR traps with valid species-level IDs
            (targetTaxaPresent == "N") | (!is.na(taxonID) & taxonRank != "family")
        ) |>
        dplyr::filter(
            is.na(estimated_totIndividuals) | (is.finite(estimated_totIndividuals) & estimated_totIndividuals >= 0)
        )

    # 6. Target column layout (Strict order)
    target_cols <- c(
        "location_id", "siteID", "unique_sample_id", "subsampleID", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank", "variable_name", "value", "unit",
        "nativeStatusCode", "proportionIdentified", "release", "remarks_sorting",
        "samplingProtocolVersion", "sex", "sortDate", "trapHours", "latitude",
        "longitude", "elevation", "nlcdClass", "plotType"
    )

    # 7. Format exactly to the neonDivData target tibble
    final_tibble <- mos_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(collectDate, tz = "UTC"),
            variable_name = "abundance",
            value = estimated_totIndividuals / as.numeric(trapHours),
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
        # Select forces the exact subset and order of target_cols
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}

# beetles ====
#' Clean NEON Ground Beetle Data
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join inner_join bind_rows mutate filter rename any_of
#'   as_tibble distinct coalesce replace_na group_by summarise ungroup n_distinct if_else
#' @importFrom tidyr drop_na replace_na
#' @importFrom stringr str_remove_all
#' @export
clean_neon_beetle <- function(neon_data_list) {
    # Helper: mode of a vector, NA-safe, returns NA for empty input
    Mode <- function(x) {
        ux <- unique(na.omit(x))
        if (length(ux) == 0) {
            return(NA)
        }
        ux[which.max(tabulate(match(x, ux)))]
    }

    # --------------------------------------------------------------------------
    # 1. FIELD DATA (Base Table for Effort)
    # --------------------------------------------------------------------------
    field_dat <- neon_data_list$bet_fielddata |>
        dplyr::filter(sampleCollected == "Y") |>
        dplyr::mutate(
            setDate = as.Date(setDate),
            collectDate = as.Date(collectDate),
            eventID = stringr::str_remove_all(eventID, "[.]"),
            trappingDays = as.numeric(difftime(collectDate, setDate, units = "days")),

            # Consolidate trap condition flags per user guide section 5.4
            # cupStatus, lidStatus, fluidLevel can each indicate sample quality issues
            trapConditionFlag = dplyr::case_when(
                !is.na(cupStatus) & cupStatus != "OK" ~ paste0("cup:", cupStatus),
                !is.na(lidStatus) & lidStatus != "OK" ~ paste0("lid:", lidStatus),
                !is.na(fluidLevel) & fluidLevel != "OK" ~ paste0("fluid:", fluidLevel),
                TRUE ~ NA_character_
            )
        ) |>
        # Adjust trappingDays for traps collected multiple times from the same setDate
        dplyr::group_by(namedLocation, trapID, setDate) |>
        dplyr::mutate(
            n_collect = dplyr::n_distinct(collectDate),
            diffTrappingDays = trappingDays - min(trappingDays, na.rm = TRUE),
            trappingDays = dplyr::if_else(
                n_collect > 1 & diffTrappingDays > 0,
                diffTrappingDays,
                trappingDays
            )
        ) |>
        dplyr::ungroup() |>
        # Harmonize collectDate within bout (collection can span 2 dates per user guide 3.2)
        dplyr::group_by(eventID) |>
        dplyr::mutate(collectDate = Mode(collectDate)) |>
        dplyr::ungroup() |>
        dplyr::mutate(boutID = paste(siteID, as.character(collectDate), sep = "_")) |>
        dplyr::distinct()

    # --------------------------------------------------------------------------
    # 2. SORTING DATA
    # Per user guide section 3.3 (2013-2016 protocol note):
    #   'carabid' / 'common carabid' -> bet_sorting taxonomy is reliable, use as fallback
    #   'other carabid'               -> sorting taxonomy is coarse ("Carabidae spp.");
    #                                    rely on bet_parataxonomistID taxonomy only
    # --------------------------------------------------------------------------
    sort_dat <- neon_data_list$bet_sorting |>
        dplyr::filter(sampleType %in% c("carabid", "other carabid", "common carabid")) |>
        dplyr::select(
            sampleID, subsampleID, sampleType, individualCount,
            sorting_taxonID = taxonID,
            sorting_sciName = scientificName,
            sorting_rank = taxonRank,
            sorting_native = nativeStatusCode
        ) |>
        dplyr::distinct()

    # --------------------------------------------------------------------------
    # 3. PARATAXONOMIST IDs
    # --------------------------------------------------------------------------
    pin_dat <- neon_data_list$bet_parataxonomistID |>
        dplyr::select(
            subsampleID, individualID,
            pin_taxonID = taxonID,
            pin_sciName = scientificName,
            pin_rank = taxonRank,
            pin_native = nativeStatusCode
        ) |>
        dplyr::distinct()

    # --------------------------------------------------------------------------
    # 4. EXPERT IDs
    # User guide 3.9: one record expected per individualID in
    # bet_expertTaxonomistIDProcessed -> relationship is many-to-one here
    # --------------------------------------------------------------------------
    exp_dat <- neon_data_list$bet_expertTaxonomistIDProcessed |>
        dplyr::select(
            individualID,
            exp_taxonID = taxonID,
            exp_sciName = scientificName,
            exp_rank    = taxonRank,
            exp_native  = nativeStatusCode
        ) |>
        dplyr::distinct()

    # --------------------------------------------------------------------------
    # 5. RESOLVE PINNED INDIVIDUALS: Expert > Parataxonomist
    # --------------------------------------------------------------------------
    id_dat <- pin_dat |>
        # many-to-one: each individualID has at most one expert record
        dplyr::left_join(exp_dat, by = "individualID") |>
        dplyr::mutate(
            final_taxonID = dplyr::coalesce(exp_taxonID, pin_taxonID),
            final_sciName = dplyr::coalesce(exp_sciName, pin_sciName),
            final_rank    = dplyr::coalesce(exp_rank, pin_rank),
            final_native  = dplyr::coalesce(exp_native, pin_native)
        ) |>
        # Drop individuals with conflicting duplicate IDs (data anomaly guard)
        dplyr::group_by(individualID) |>
        dplyr::filter(dplyr::n() == 1) |>
        dplyr::ungroup()

    # Aggregate resolved pinned counts per subsample x taxon
    id_agg <- id_dat |>
        dplyr::group_by(subsampleID, final_taxonID, final_sciName, final_rank, final_native) |>
        dplyr::summarise(pinned_count = dplyr::n(), .groups = "drop")

    # Total pinned per subsample (for computing remainder)
    pinned_totals <- id_agg |>
        dplyr::group_by(subsampleID) |>
        dplyr::summarise(total_pinned = sum(pinned_count), .groups = "drop")

    # --------------------------------------------------------------------------
    # 6. COMPUTE UNPINNED COUNTS
    # --------------------------------------------------------------------------
    sort_combined <- sort_dat |>
        dplyr::left_join(pinned_totals, by = "subsampleID") |>
        dplyr::mutate(
            total_pinned = tidyr::replace_na(total_pinned, 0),
            unpinned_count = individualCount - total_pinned,
            # Guard: clamp to zero — negative values indicate a data anomaly
            # (more individuals pinned than sorting count, warn but don't error)
            unpinned_count = pmax(unpinned_count, 0)
        )

    # Warn if anomalous pinning counts detected
    n_anomalous <- sum((sort_combined$individualCount - sort_combined$total_pinned) < 0, na.rm = TRUE)
    if (n_anomalous > 0) {
        warning(sprintf(
            "%d subsample(s) had more pinned individuals than sorting count. Unpinned count clamped to 0. Check data for anomalies.",
            n_anomalous
        ))
    }

    # --------------------------------------------------------------------------
    # 7. RECOMBINE PINNED AND UNPINNED
    #
    # For 'other carabid': sorting taxonomy is coarse by design (2013-2016
    # protocol). Remaining unpinned 'other carabid' individuals cannot be
    # reliably identified — exclude them rather than propagate coarse taxonomy.
    # --------------------------------------------------------------------------
    unpinned_df <- sort_combined |>
        dplyr::filter(
            unpinned_count > 0,
            sampleType != "other carabid" # coarse sorting taxonomy, unusable
        ) |>
        dplyr::select(
            sampleID,
            taxonID          = sorting_taxonID,
            scientificName   = sorting_sciName,
            taxonRank        = sorting_rank,
            nativeStatusCode = sorting_native,
            count            = unpinned_count
        )

    pinned_df <- sort_combined |>
        dplyr::select(sampleID, subsampleID) |>
        dplyr::distinct() |>
        dplyr::inner_join(id_agg, by = "subsampleID", relationship = "many-to-many") |>
        dplyr::select(
            sampleID,
            taxonID          = final_taxonID,
            scientificName   = final_sciName,
            taxonRank        = final_rank,
            nativeStatusCode = final_native,
            count            = pinned_count
        )

    final_tax <- dplyr::bind_rows(unpinned_df, pinned_df) |>
        dplyr::group_by(sampleID, taxonID, scientificName, taxonRank, nativeStatusCode) |>
        dplyr::summarise(count = sum(count, na.rm = TRUE), .groups = "drop") |>
        dplyr::filter(!is.na(taxonID))

    # --------------------------------------------------------------------------
    # 8. DOWNWARD JOIN (Preserves Zero-Catch Effort Rows)
    # --------------------------------------------------------------------------
    bet_dat <- field_dat |>
        dplyr::left_join(final_tax, by = "sampleID", relationship = "many-to-many") |>
        dplyr::mutate(
            # Guard against trappingDays == 0 producing Inf
            abundance = dplyr::if_else(
                !is.na(count) & !is.na(trappingDays) & trappingDays > 0,
                count / trappingDays,
                NA_real_
            ),
            variable_name = "abundance",
            unit = "count per trap day",
            unique_sample_id = sampleID,
            observation_datetime = as.Date(collectDate)
        ) |>
        # Keep zero-catch rows (NA abundance) and valid non-negative rows
        dplyr::filter(is.na(abundance) | (is.finite(abundance) & abundance >= 0))

    # --------------------------------------------------------------------------
    # 9. FORMAT AND RETURN
    # samplingImpractical and trapConditionFlag included for downstream filtering
    # --------------------------------------------------------------------------
    target_cols <- c(
        "location_id", "siteID", "plotID", "unique_sample_id", "trapID",
        "observation_datetime", "taxon_id", "taxon_name", "taxon_rank",
        "variable_name", "value", "unit",
        "boutID", "nativeStatusCode", "release", "remarks",
        "samplingProtocolVersion", "samplingImpractical", "trapConditionFlag",
        "trappingDays", "latitude", "longitude", "elevation", "nlcdClass"
    )

    final_tibble <- bet_dat |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id    = taxonID,
            taxon_name  = scientificName,
            taxon_rank  = taxonRank,
            value       = abundance,
            latitude    = decimalLatitude,
            longitude   = decimalLongitude
        ) |>
        dplyr::mutate(trappingDays = as.character(trappingDays)) |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}
