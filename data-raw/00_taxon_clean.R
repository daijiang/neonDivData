#' Resolve NEON duplicates by summing counts or coverage
#' @noRd
resolve_neon_duplicates <- function(df, group_cols, sum_col) {
    dup_counts <- df |>
        dplyr::group_by(dplyr::across(dplyr::all_of(group_cols))) |>
        dplyr::summarize(
            n_recs = dplyr::n(),
            corrected_val = sum(.data[[sum_col]], na.rm = TRUE),
            .groups = "drop"
        )

    df_no_dups <- df |>
        dplyr::inner_join(dplyr::filter(dup_counts, n_recs == 1), by = group_cols) |>
        dplyr::select(-n_recs, -corrected_val) |>
        dplyr::distinct()

    df_corrected <- dup_counts |>
        dplyr::filter(n_recs > 1) |>
        dplyr::left_join(dplyr::select(df, -dplyr::all_of(sum_col)), by = group_cols, multiple = "first") |>
        dplyr::mutate(!!sum_col := corrected_val) |>
        dplyr::select(-n_recs, -corrected_val) |>
        dplyr::distinct()

    dplyr::bind_rows(df_no_dups, df_corrected)
}


#' Clean NEON Plant Data
#' @param neon_data_list DP1.10058.001 raw data
#' @importFrom dplyr select mutate filter bind_rows rename distinct any_of as_tibble
#' @importFrom tidyr drop_na
#' @importFrom stringr str_extract str_remove str_detect
#'
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


## birds ====
#' Clean NEON Bird Data
#' Retrieves and cleans Bird point count data (DP1.10003.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join mutate filter rename any_of as_tibble distinct
#'
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
#'
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
#'
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

# small mammals ====
#' Clean NEON Small Mammal Data
#' Retrieves and cleans Small Mammal trapping data (DP1.10072.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join inner_join mutate filter rename any_of as_tibble distinct
#'   group_by summarise ungroup n_distinct slice if_else case_when
#' @importFrom tidyr drop_na replace_na
#' @importFrom lubridate year month
#'
clean_neon_small_mammal <- function(neon_data_list) {
    # --------------------------------------------------------------------------
    # 1. PER-PLOT-NIGHT: effort base + quality filter
    # One record per plotID per collectDate (= one nightUID).
    # samplingImpractical != "OK" means the plot could not be sampled that night
    # (field added 2020; pre-2020 records have NA -> treat as OK).
    # --------------------------------------------------------------------------
    plot_dat <- neon_data_list$mam_perplotnight |>
        dplyr::filter(is.na(samplingImpractical) | samplingImpractical == "OK") |>
        dplyr::mutate(
            collectDate = as.Date(collectDate),
            year = as.character(lubridate::year(collectDate)),
            month = as.character(lubridate::month(collectDate)),
            # eventID is the authoritative bout identifier in perplotnight;
            # fall back to year_month when missing (pre-2020 or data gap)
            bout = dplyr::if_else(
                is.na(eventID) | eventID == "",
                paste(year, month, sep = "_"),
                eventID
            )
        ) |>
        dplyr::select(
            nightuid, siteID, plotID, namedLocation, collectDate,
            bout, year, month, release
        ) |>
        dplyr::distinct()

    # --------------------------------------------------------------------------
    # 2. PER-TRAP-NIGHT: trap deployment records
    # --------------------------------------------------------------------------
    trap_dat <- neon_data_list$mam_pertrapnight |>
        tidyr::drop_na(nightuid, plotID, collectDate) |>
        dplyr::distinct()

    # --------------------------------------------------------------------------
    # 3. EFFORT CALCULATION
    # n_trap_nights_per_night_uid = unique trap positions (trapCoordinate) set
    # per nightUID.  Sum across nights in a bout = n_trap_nights_per_bout_per_plot.
    # Use inner_join so only pertrapnight records with a valid perplotnight entry
    # (i.e., sampling was not impractical) contribute to effort.
    # --------------------------------------------------------------------------
    trap_effort <- trap_dat |>
        dplyr::group_by(nightuid) |>
        dplyr::summarise(
            n_trap_nights_per_night_uid = dplyr::n_distinct(trapCoordinate),
            .groups = "drop"
        )

    effort_dat <- plot_dat |>
        dplyr::left_join(trap_effort, by = "nightuid") |>
        dplyr::mutate(
            n_trap_nights_per_night_uid = tidyr::replace_na(n_trap_nights_per_night_uid, 0L)
        ) |>
        dplyr::group_by(location_id = namedLocation, siteID, plotID, bout, year, month) |>
        dplyr::summarise(
            n_trap_nights_per_bout_per_plot = sum(n_trap_nights_per_night_uid, na.rm = TRUE),
            n_nights_per_bout = dplyr::n_distinct(nightuid),
            observation_datetime = as.Date(max(collectDate)),
            release = paste(unique(release), collapse = "|"),
            .groups = "drop"
        ) |>
        dplyr::filter(n_trap_nights_per_bout_per_plot > 0) |>
        dplyr::mutate(unique_sample_id = paste(location_id, year, month, sep = "_"))

    # --------------------------------------------------------------------------
    # 4. CAPTURES: restrict to valid (non-impractical) nights via inner_join,
    # then filter to real captures at target taxonomic ranks
    # --------------------------------------------------------------------------
    cap_dat <- trap_dat |>
        dplyr::inner_join(
            dplyr::select(plot_dat, nightuid, bout),
            by = "nightuid"
        ) |>
        dplyr::filter(
            trapStatus %in% c("5 - capture", "4 - more than 1 capture in one trap"),
            taxonRank %in% c("genus", "species", "subspecies", "speciesGroup"),
            !is.na(taxonID)
        )

    # --------------------------------------------------------------------------
    # 5. RECAPTURE RESOLUTION
    # Within each bout, a tagged individual (tagID) should be counted only once.
    # Untagged individuals (NA / blank tagID) cannot be tracked across nights;
    # use the pertrapnight uid (unique per row) as a proxy so every untagged
    # capture is treated as a distinct individual — avoids the ecocomDP bug
    # where !duplicated(tagID) drops all but the first NA in a group.
    # --------------------------------------------------------------------------
    cap_dat <- cap_dat |>
        dplyr::mutate(
            tag_key = dplyr::case_when(
                !is.na(tagID) & tagID != "" ~ tagID,
                TRUE ~ paste("untagged", uid, sep = "_")
            )
        ) |>
        dplyr::group_by(bout) |>
        dplyr::filter(!duplicated(tag_key)) |>
        dplyr::ungroup()

    # --------------------------------------------------------------------------
    # 6. AGGREGATE CAPTURES per location x bout x taxon
    # nativeStatusCode: collapse if multiple values exist (edge case)
    # --------------------------------------------------------------------------
    cap_agg <- cap_dat |>
        dplyr::group_by(
            location_id      = namedLocation,
            bout,
            taxon_id         = taxonID,
            taxon_name       = scientificName,
            taxon_rank       = taxonRank,
            nativeStatusCode
        ) |>
        dplyr::summarise(raw_count = dplyr::n(), .groups = "drop")

    # --------------------------------------------------------------------------
    # 7. JOIN EFFORT WITH CAPTURES (left join preserves zero-catch bouts)
    # --------------------------------------------------------------------------
    mam_dat <- effort_dat |>
        dplyr::left_join(cap_agg,
            by = c("location_id", "bout"),
            relationship = "many-to-many"
        ) |>
        dplyr::mutate(
            variable_name = "count",
            unit = "unique individuals per 100 trap nights per plot per month",
            value = dplyr::if_else(
                !is.na(raw_count) & n_trap_nights_per_bout_per_plot > 0,
                100 * raw_count / n_trap_nights_per_bout_per_plot,
                NA_real_
            )
        )

    # --------------------------------------------------------------------------
    # 8. SPATIAL METADATA (one record per namedLocation)
    # --------------------------------------------------------------------------
    loc_info <- trap_dat |>
        dplyr::select(
            location_id = namedLocation,
            latitude = decimalLatitude,
            longitude = decimalLongitude,
            elevation, plotType, nlcdClass
        ) |>
        dplyr::distinct() |>
        dplyr::group_by(location_id) |>
        dplyr::slice(1) |>
        dplyr::ungroup()

    final_dat <- mam_dat |>
        dplyr::left_join(loc_info, by = "location_id")

    # --------------------------------------------------------------------------
    # 9. FINAL COLUMN LAYOUT
    # Zero-catch effort rows (taxon_id = NA, value = NA) are retained so that
    # downstream users can use full sampling effort for occupancy modelling.
    # --------------------------------------------------------------------------
    target_cols <- c(
        "location_id", "siteID", "plotID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank", "variable_name", "value", "unit",
        "year", "month", "n_trap_nights_per_bout_per_plot", "n_nights_per_bout",
        "nativeStatusCode", "release", "latitude", "longitude", "elevation",
        "plotType", "nlcdClass"
    )

    final_tibble <- final_dat |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}

# algae ====
#' Clean NEON Algae Data
#' Retrieves and cleans Algae taxonomy data (DP1.20166.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join mutate filter rename any_of as_tibble distinct case_when
#'   group_by summarise ungroup slice
#' @importFrom tidyr drop_na
#'
clean_neon_algae <- function(neon_data_list) {
    # 1. EXTRACT TABLES
    alg_field <- neon_data_list$alg_fieldData |> dplyr::distinct()
    alg_tax <- neon_data_list$alg_taxonomyProcessed |> dplyr::distinct()
    alg_biomass <- neon_data_list$alg_biomass |> dplyr::distinct()

    # 2. BIOMASS: filter to taxonomy analysis; compute estimated bottle volume
    alg_biomass_sub <- alg_biomass |>
        dplyr::filter(analysisType == "taxonomy") |>
        dplyr::mutate(
            estPerBottleSampleVolume = as.numeric(preservativeVolume) + as.numeric(labSampleVolume)
        ) |>
        dplyr::select(parentSampleID, sampleID, fieldSampleVolume, estPerBottleSampleVolume) |>
        dplyr::distinct()

    # 3. JOIN TAXONOMY + BIOMASS; resolve perBottleSampleVolume
    alg_tax_bio <- alg_tax |>
        dplyr::left_join(alg_biomass_sub, by = "sampleID", relationship = "many-to-many") |>
        dplyr::mutate(
            perBottleSampleVolume = as.numeric(perBottleSampleVolume),
            perBottleSampleVolume = dplyr::case_when(
                is.na(perBottleSampleVolume) ~ estPerBottleSampleVolume,
                perBottleSampleVolume == 0 ~ estPerBottleSampleVolume,
                TRUE ~ perBottleSampleVolume
            )
        )

    # 4. JOIN WITH FIELD DATA (drop columns already in alg_tax_bio except join key)
    join_cols <- intersect(names(alg_tax_bio), names(alg_field))
    join_cols <- setdiff(join_cols, "parentSampleID")

    alg_dat <- alg_tax_bio |>
        dplyr::left_join(
            dplyr::select(alg_field, -dplyr::any_of(join_cols)),
            by = "parentSampleID",
            relationship = "many-to-many"
        )

    # 5. COMPUTE DENSITY; filter to valid records
    alg_dat <- alg_dat |>
        dplyr::filter(algalParameterUnit == "cellsPerBottle") |>
        dplyr::mutate(
            algalParameterValue = as.numeric(algalParameterValue),
            fieldSampleVolume = as.numeric(fieldSampleVolume),
            benthicArea = as.numeric(benthicArea),
            density = dplyr::case_when(
                algalSampleType %in% c("seston", "phytoplankton") ~
                    algalParameterValue / perBottleSampleVolume,
                TRUE ~
                    (algalParameterValue / perBottleSampleVolume) *
                        (fieldSampleVolume / (benthicArea * 10000))
            ),
            cell_density_standardized_unit = dplyr::case_when(
                algalSampleType %in% c("phytoplankton", "seston") ~ "cells/mL",
                TRUE ~ "cells/cm2"
            )
        ) |>
        dplyr::filter(
            sampleCondition == "Condition OK",
            !is.na(density),
            density >= 0,
            is.finite(density)
        )

    # 6. RESOLVE DUPLICATES: same sampleID + acceptedTaxonID → sum densities
    dup_agg <- alg_dat |>
        dplyr::group_by(sampleID, acceptedTaxonID) |>
        dplyr::summarise(density_sum = sum(density, na.rm = TRUE), .groups = "drop")

    alg_dat <- alg_dat |>
        dplyr::group_by(sampleID, acceptedTaxonID) |>
        dplyr::slice(1) |>
        dplyr::ungroup() |>
        dplyr::left_join(dup_agg, by = c("sampleID", "acceptedTaxonID")) |>
        dplyr::mutate(density = density_sum) |>
        dplyr::select(-density_sum)

    # 7. FINAL COLUMN LAYOUT (match existing data_algae column order)
    target_cols <- c(
        "location_id", "siteID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank",
        "variable_name", "value", "unit",
        "sampleCondition", "perBottleSampleVolume", "release",
        "habitatType", "algalSampleType", "samplerType",
        "benthicArea", "samplingProtocolVersion", "substratumSizeClass",
        "phytoDepth1", "phytoDepth2", "phytoDepth3",
        "latitude", "longitude", "elevation"
    )

    final_tibble <- alg_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(collectDate, tz = "UTC"),
            variable_name        = "cell density",
            unique_sample_id     = sampleID
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id    = acceptedTaxonID,
            taxon_name  = scientificName,
            taxon_rank  = taxonRank,
            value       = density,
            unit        = cell_density_standardized_unit,
            latitude    = decimalLatitude,
            longitude   = decimalLongitude
        ) |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}

# macroinvertebrate ====
#' Clean NEON Macroinvertebrate Data
#' Retrieves and cleans Aquatic Macroinvertebrate data (DP1.20120.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join inner_join mutate filter rename any_of as_tibble distinct
#'   group_by summarise ungroup slice
#' @importFrom tidyr drop_na
#'
clean_neon_macroinvertebrate <- function(neon_data_list) {
    # 1. FIELD DATA: drop NA sampleID, deduplicate by sampleID (known published duplicate issue)
    inv_field <- neon_data_list$inv_fieldData |>
        tidyr::drop_na(sampleID) |>
        dplyr::group_by(sampleID) |>
        dplyr::slice(1) |>
        dplyr::ungroup()

    # 2. TAXONOMY PROCESSED: filter to target taxa, aggregate across size classes
    inv_tax <- neon_data_list$inv_taxonomyProcessed |>
        dplyr::filter(targetTaxaPresent == "Y") |>
        dplyr::group_by(sampleID, acceptedTaxonID, scientificName, taxonRank) |>
        dplyr::summarise(
            estimatedTotalCount = sum(estimatedTotalCount, na.rm = TRUE),
            individualCount = sum(individualCount, na.rm = TRUE),
            subsamplePercent = paste(unique(subsamplePercent), collapse = "|"),
            release = paste(unique(release), collapse = "|"),
            .groups = "drop"
        )

    # 3. JOIN AND COMPUTE DENSITY
    # inner_join: records without matching field data cannot have a valid density
    inv_dat <- inv_tax |>
        dplyr::inner_join(
            dplyr::select(
                inv_field,
                sampleID, namedLocation, siteID, collectDate,
                benthicArea, habitatType, samplerType, substratumSizeClass,
                remarks, ponarDepth, snagLength, snagDiameter,
                decimalLatitude, decimalLongitude, elevation
            ),
            by = "sampleID"
        ) |>
        dplyr::mutate(
            benthicArea = as.numeric(benthicArea),
            density     = estimatedTotalCount / benthicArea
        ) |>
        dplyr::filter(!is.na(density), density >= 0, is.finite(density))

    # 4. FINAL COLUMN LAYOUT (match existing data_macroinvertebrate column order)
    target_cols <- c(
        "location_id", "siteID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank",
        "variable_name", "value", "unit",
        "estimatedTotalCount", "individualCount", "subsamplePercent",
        "release", "benthicArea", "habitatType", "samplerType",
        "substratumSizeClass", "remarks", "ponarDepth", "snagLength",
        "snagDiameter", "latitude", "longitude", "elevation"
    )

    final_tibble <- inv_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(collectDate, tz = "UTC"),
            variable_name        = "density",
            unit                 = "count per square meter",
            unique_sample_id     = sampleID
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id    = acceptedTaxonID,
            taxon_name  = scientificName,
            taxon_rank  = taxonRank,
            value       = density,
            latitude    = decimalLatitude,
            longitude   = decimalLongitude
        ) |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}

# tick ====
#' Clean NEON Tick Data
#' Retrieves and cleans Tick dragging data (DP1.10093.001) into a flattened tibble.
#' @param neon_data_list A list of data frames returned by `neonUtilities::loadByProduct`
#' @importFrom dplyr select left_join bind_rows mutate filter rename any_of as_tibble distinct
#'   case_when group_by summarise ungroup coalesce
#' @importFrom tidyr replace_na pivot_wider pivot_longer
#' @importFrom stats na.omit
#'
clean_neon_tick <- function(neon_data_list) {
    # 1. FIELD DATA: drop compromised samples and ensure valid sampleIDs
    tck_field <- neon_data_list$tck_fielddata |>
        dplyr::filter(is.na(samplingImpractical) | samplingImpractical == "OK") |>
        dplyr::filter(!(targetTaxaPresent == "Y" & is.na(sampleID))) |>
        dplyr::mutate(
            larvaCount = as.numeric(larvaCount),
            nymphCount = as.numeric(nymphCount),
            adultCount = as.numeric(adultCount)
        ) |>
        dplyr::rename(remarks_field = remarks, release_field = release)

    # 2. LAB TAXONOMY DATA: standardize LifeStage, aggregate across sex classes
    # Drop records with unrecognised sexOrAge to avoid NA LifeStage creating a
    # spurious "NA" column in the pivot_wider lab summary below.
    tck_tax <- neon_data_list$tck_taxonomyProcessed |>
        dplyr::filter(sampleCondition == "OK", !is.na(acceptedTaxonID), !is.na(individualCount)) |>
        dplyr::mutate(
            LifeStage = dplyr::case_when(
                sexOrAge %in% c("Male", "Female", "Adult") ~ "Adult",
                sexOrAge == "Larva" ~ "Larva",
                sexOrAge == "Nymph" ~ "Nymph",
                TRUE ~ NA_character_
            )
        ) |>
        dplyr::filter(!is.na(LifeStage)) |>
        dplyr::group_by(sampleID, acceptedTaxonID, scientificName, taxonRank, LifeStage) |>
        dplyr::summarise(
            individualCount = sum(individualCount, na.rm = TRUE),
            release_tax = paste(unique(release), collapse = "|"),
            .groups = "drop"
        )

    # 3. RECONCILE MISSING COUNTS (the IXOSP2 fix)
    # When field counts exceed lab counts (subsampling, transit loss), assign the
    # difference to Order Ixodida (IXOSP2) rather than using fragile string-matching.
    lab_summary <- tck_tax |>
        dplyr::group_by(sampleID, LifeStage) |>
        dplyr::summarise(lab_sum = sum(individualCount, na.rm = TRUE), .groups = "drop") |>
        tidyr::pivot_wider(names_from = LifeStage, values_from = lab_sum, values_fill = 0)

    # ensure all life stage columns exist for arithmetic
    for (col in c("Larva", "Nymph", "Adult")) {
        if (!col %in% names(lab_summary)) lab_summary[[col]] <- 0
    }

    missing_ticks <- tck_field |>
        dplyr::filter(targetTaxaPresent == "Y") |>
        dplyr::left_join(lab_summary, by = "sampleID") |>
        dplyr::mutate(
            Larva = pmax(0, tidyr::replace_na(larvaCount, 0) - tidyr::replace_na(Larva, 0)),
            Nymph = pmax(0, tidyr::replace_na(nymphCount, 0) - tidyr::replace_na(Nymph, 0)),
            Adult = pmax(0, tidyr::replace_na(adultCount, 0) - tidyr::replace_na(Adult, 0))
        ) |>
        dplyr::select(sampleID, Larva, Nymph, Adult) |>
        tidyr::pivot_longer(
            cols      = c(Larva, Nymph, Adult),
            names_to  = "LifeStage",
            values_to = "individualCount"
        ) |>
        dplyr::filter(individualCount > 0) |>
        dplyr::mutate(
            acceptedTaxonID = "IXOSP2",
            scientificName  = "Ixodida sp.",
            taxonRank       = "order"
        )

    # 4. COMBINE LAB COUNTS AND RECONCILED MISSING COUNTS
    final_tax <- dplyr::bind_rows(tck_tax, missing_ticks) |>
        dplyr::group_by(sampleID, acceptedTaxonID, scientificName, taxonRank, LifeStage) |>
        dplyr::summarise(
            individualCount = sum(individualCount, na.rm = TRUE),
            release = paste(stats::na.omit(unique(release_tax)), collapse = "|"),
            .groups = "drop"
        )

    # 5. JOIN EFFORT AND COMPUTE ABUNDANCE
    # Empty drags (targetTaxaPresent == "N") get individualCount = 0 to preserve effort
    tck_dat <- tck_field |>
        dplyr::left_join(final_tax, by = "sampleID") |>
        dplyr::mutate(
            individualCount = dplyr::case_when(
                targetTaxaPresent == "N" ~ 0,
                TRUE ~ individualCount
            ),
            totalSampledArea = as.numeric(totalSampledArea),
            abundance = individualCount / totalSampledArea
        ) |>
        dplyr::filter(
            targetTaxaPresent == "N" |
                (!is.na(abundance) & abundance >= 0 & is.finite(abundance))
        )

    # 6. FINAL COLUMN LAYOUT (match existing data_tick column order)
    target_cols <- c(
        "location_id", "siteID", "plotID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank", "variable_name", "value", "unit",
        "LifeStage", "release", "remarks_field", "samplingMethod", "targetTaxaPresent",
        "totalSampledArea", "latitude", "longitude", "elevation", "nlcdClass", "plotType"
    )

    final_tibble <- tck_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(collectDate, tz = "UTC"),
            variable_name = "abundance",
            unit = "count per square meter",
            unique_sample_id = paste(plotID, collectDate, sep = "_"),
            release = dplyr::if_else(
                is.na(release) | release == "",
                release_field,
                release
            )
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id    = acceptedTaxonID,
            taxon_name  = scientificName,
            taxon_rank  = taxonRank,
            value       = abundance,
            latitude    = decimalLatitude,
            longitude   = decimalLongitude
        ) |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}


##############################################################################################
#' Clean NEON tick-borne pathogen data (DP1.10092.001)
#'
#' @param neon_data_list A named list returned by \code{neonUtilities::loadByProduct()}
#'   for data product \code{DP1.10092.001}.
#' @return A flat \code{\link[tibble]{tibble}} with one row per
#'   location x date x pathogen x life-stage combination.
#'
#' @importFrom dplyr filter pull mutate rename select group_by summarise
#'   left_join distinct slice ungroup if_else case_when n as_tibble any_of
#' @importFrom stats na.omit
clean_neon_tick_pathogen <- function(neon_data_list) {
    # 1. QA BATCH FILTERING
    # Remove tests from any batch that failed quality criteria
    qa_failed_batches <- neon_data_list$tck_pathogenqa |>
        dplyr::filter(criteriaMet != "Y") |>
        dplyr::pull(batchID) |>
        unique()

    # 2. BASE FILTERING: sampleCondition, testResult, QA batches
    path_dat <- neon_data_list$tck_pathogen |>
        dplyr::filter(
            sampleCondition == "OK",
            !is.na(testResult),
            !(batchID %in% qa_failed_batches)
        )

    # 3. DNA QUALITY FIX
    # Identify ticks (by testingID) whose DNA quality check failed.
    # Drop ALL rows for those ticks -- not just the DNA Quality row itself --
    # because pathogen tests from ticks with degraded DNA are unreliable.
    # NOTE: Old ecocomDP code filtered only by uid, leaving the remaining
    # pathogen rows for failed-DNA ticks in the dataset. Fix: drop by testingID.
    failed_dna_ticks <- path_dat |>
        dplyr::filter(
            testPathogenName == "HardTick DNA Quality",
            testResult != "Positive"
        ) |>
        dplyr::pull(testingID) |>
        unique()

    path_dat <- path_dat |>
        dplyr::filter(!(testingID %in% failed_dna_ticks)) |>
        dplyr::filter(
            !testPathogenName %in% c("HardTick DNA Quality", "Ixodes pacificus")
        )

    # 4. TAXONOMY CLEANUP AND LIFESTAGE EXTRACTION
    # Unify Borrelia burgdorferi and Borrelia burgdorferi sensu lato
    # (mutually exclusive per testingID; verified in source data).
    # lifeStage = last dot-delimited segment of subsampleID
    # (subsampleID format: plotID.date.vectorSpecies.lifeStage)
    path_dat <- path_dat |>
        dplyr::mutate(
            testPathogenName = dplyr::if_else(
                testPathogenName == "Borrelia burgdorferi",
                "Borrelia burgdorferi sensu lato",
                testPathogenName
            ),
            lifeStage = sub(".*\\.", "", subsampleID),
            pos_result = dplyr::if_else(testResult == "Positive", 1L, 0L)
        )

    # 5. SPATIAL METADATA (one representative row per namedLocation)
    loc_meta <- path_dat |>
        dplyr::select(
            namedLocation, siteID, plotID,
            decimalLatitude, decimalLongitude, elevation,
            nlcdClass, plotType
        ) |>
        dplyr::distinct() |>
        dplyr::group_by(namedLocation) |>
        dplyr::slice(1) |>
        dplyr::ungroup()

    # 6. AGGREGATE POSITIVITY RATES
    # One row per location x date x pathogen x lifeStage
    path_agg <- path_dat |>
        dplyr::group_by(
            namedLocation, collectDate, testPathogenName, lifeStage
        ) |>
        dplyr::summarise(
            n_tests = dplyr::n(),
            n_positive_test = sum(pos_result, na.rm = TRUE),
            release = paste(unique(stats::na.omit(release)), collapse = "|"),
            testProtocolVersion = paste(unique(stats::na.omit(testProtocolVersion)), collapse = "|"),
            .groups = "drop"
        ) |>
        dplyr::mutate(
            value = n_positive_test / n_tests,
            variable_name = "positivity rate",
            unit = "positive tests per pathogen per sampling event",
            taxon_rank = dplyr::case_when(
                grepl(" sp\\.| spp\\.", testPathogenName) ~ "genus",
                TRUE ~ "species"
            ),
            taxon_name = testPathogenName,
            unique_sample_id = paste(namedLocation, collectDate, sep = "_"),
            observation_datetime = as.POSIXct(collectDate, tz = "UTC")
        ) |>
        dplyr::left_join(loc_meta, by = "namedLocation")

    # 7. FINAL COLUMN LAYOUT (match data_tick_pathogen column order)
    target_cols <- c(
        "location_id", "siteID", "plotID", "unique_sample_id",
        "observation_datetime", "taxon_id", "taxon_name", "taxon_rank",
        "variable_name", "value", "unit", "lifeStage",
        "testProtocolVersion", "release", "n_tests", "n_positive_test",
        "latitude", "longitude", "elevation", "nlcdClass", "plotType"
    )

    final_tibble <- path_agg |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id    = testPathogenName,
            latitude    = decimalLatitude,
            longitude   = decimalLongitude
        ) |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}


##############################################################################################
#' Clean NEON Zooplankton Data (DP1.20219.001)
#'
#' @param neon_data_list A named list returned by \code{neonUtilities::loadByProduct()}
#'   for data product \code{DP1.20219.001}.
#' @return A flat \code{\link[tibble]{tibble}} with one row per sample x taxon combination.
#'   Density = sum(adjCountPerBottle) / towsTrapsVolume (count per liter), where
#'   adjCountPerBottle values are summed across size-class measurements before dividing.
#'
#' @importFrom dplyr select left_join inner_join mutate filter rename any_of as_tibble
#'   distinct group_by summarise ungroup slice
#' @importFrom tidyr drop_na
#' @importFrom stats na.omit
clean_neon_zooplankton <- function(neon_data_list) {
    # 1. FIELD DATA: Deduplicate by sampleID
    # Secure against NEON's known aquatic duplicate metadata bug
    zoo_field <- neon_data_list$zoo_fieldData |>
        tidyr::drop_na(sampleID) |>
        dplyr::group_by(sampleID) |>
        dplyr::slice(1) |>
        dplyr::ungroup()

    # 2. TAXONOMY DATA: Filter and aggregate by taxon
    # Sum adjCountPerBottle to safely collapse size-class measurements for the same taxon.
    # User guide (Eq. 2): density = SUM(adjCountPerBottle) / towsTrapsVolume, where the
    # sum is taken over all records for a given sampleID before dividing by volume.
    # tolower() guards against NEON's occasional casing changes ("condition OK" vs "Condition OK").
    zoo_tax <- neon_data_list$zoo_taxonomyProcessed |>
        dplyr::filter(tolower(sampleCondition) == "condition ok") |>
        dplyr::group_by(sampleID, taxonID, scientificName, taxonRank) |>
        dplyr::summarise(
            adjCountPerBottle = sum(adjCountPerBottle, na.rm = TRUE),
            release           = paste(unique(stats::na.omit(release)), collapse = "|"),
            .groups           = "drop"
        )

    # 3. JOIN FIELD DATA AND CALCULATE DENSITY
    # inner_join: towsTrapsVolume is required to compute density; drop records without it.
    # as.numeric() on towsTrapsVolume is needed for arithmetic, not output type coercion.
    zoo_dat <- zoo_tax |>
        dplyr::inner_join(
            dplyr::select(
                zoo_field,
                sampleID, namedLocation, siteID, collectDate,
                samplerType, towsTrapsVolume,
                decimalLatitude, decimalLongitude, elevation
            ),
            by = "sampleID"
        ) |>
        dplyr::mutate(
            towsTrapsVolume = as.numeric(towsTrapsVolume),
            density         = adjCountPerBottle / towsTrapsVolume
        ) |>
        dplyr::filter(
            !is.na(density),
            density >= 0,
            is.finite(density)
        )

    # 4. FINAL COLUMN LAYOUT (match data_zooplankton column order)
    target_cols <- c(
        "location_id", "siteID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank", "variable_name", "value",
        "unit", "release", "samplerType", "towsTrapsVolume",
        "latitude", "longitude", "elevation"
    )

    final_tibble <- zoo_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(collectDate, tz = "UTC"),
            variable_name        = "density",
            unit                 = "count per liter",
            unique_sample_id     = sampleID
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id    = taxonID,
            taxon_name  = scientificName,
            taxon_rank  = taxonRank,
            value       = density,
            latitude    = decimalLatitude,
            longitude   = decimalLongitude
        ) |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}
