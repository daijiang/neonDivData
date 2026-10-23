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

#' Flag genus-level records that co-occur with a finer ID of the same genus
#'
#' Adds a logical column `redundant_genus`: TRUE when a record is identified only
#' to genus and the same sample also contains a record of that genus identified
#' to subgenus, species group, species, or below. Such genus-level records may
#' represent the same organisms and inflate naive richness counts.
#' @noRd
flag_redundant_genus <- function(df, sample_cols = "unique_sample_id") {
    finer_ranks <- c("subgenus", "speciesgroup", "species", "subspecies", "variety", "form")
    genus <- stringr::word(df$taxon_name, 1)
    sample_key <- do.call(paste, c(unname(as.list(df[sample_cols])), sep = "|"))
    is_finer <- tolower(df$taxon_rank) %in% finer_ranks
    finer_keys <- unique(paste(sample_key, genus)[is_finer])
    df$redundant_genus <- tolower(df$taxon_rank) %in% "genus" &
        paste(sample_key, genus) %in% finer_keys
    df
}

#' Prefix a status value unless it is missing or one of the OK values
#' @noRd
flag_value <- function(x, prefix, ok = character()) {
    dplyr::if_else(is.na(x) | tolower(x) %in% tolower(ok), NA_character_, paste0(prefix, x))
}

#' Combine several flag vectors into one "; "-separated string (NA if none set)
#' @noRd
collapse_flags <- function(...) {
    m <- cbind(...)
    out <- apply(m, 1, function(r) paste(r[!is.na(r)], collapse = "; "))
    out[out == ""] <- NA_character_
    out
}

# plant =====
#' Clean NEON Plant Data
#' @param neon_data_list DP1.10058.001 raw data
#' @importFrom dplyr select mutate filter bind_rows rename distinct any_of as_tibble
#' @importFrom tidyr drop_na
#' @importFrom stringr str_extract str_remove str_detect
#'
clean_neon_plant <- function(neon_data_list) {
    # 0. HELPERS
    # Morphospecies resolutions (user guide 3.7, 3.9): field morphospecies are later
    # resolved in div_morphospecies; update records by joining on siteID +
    # morphospeciesID. Only unambiguous (1:1) resolutions are applied.
    morpho <- neon_data_list$div_morphospecies |>
        dplyr::filter(!is.na(morphospeciesID), !is.na(taxonID)) |>
        dplyr::distinct(
            siteID, morphospeciesID, taxonID, scientificName, taxonRank,
            nativeStatusCode, identificationQualifier
        ) |>
        dplyr::add_count(siteID, morphospeciesID) |>
        dplyr::filter(n == 1) |>
        dplyr::select(
            siteID, morphospeciesID,
            ms_taxonID = taxonID, ms_scientificName = scientificName,
            ms_taxonRank = taxonRank, ms_nativeStatusCode = nativeStatusCode,
            ms_identificationQualifier = identificationQualifier
        )

    resolve_morpho <- function(df) {
        df |>
            dplyr::left_join(morpho, by = c("siteID", "morphospeciesID"), na_matches = "never") |>
            dplyr::mutate(
                morphospecies_resolved = !is.na(ms_taxonID),
                taxonID = dplyr::coalesce(ms_taxonID, taxonID),
                scientificName = dplyr::coalesce(ms_scientificName, scientificName),
                taxonRank = dplyr::coalesce(ms_taxonRank, taxonRank),
                nativeStatusCode = dplyr::coalesce(ms_nativeStatusCode, nativeStatusCode),
                identificationQualifier = dplyr::if_else(
                    morphospecies_resolved, ms_identificationQualifier, identificationQualifier
                ),
                # Unresolved morphospecies sharing a coarse code (e.g. 2PLANT) are distinct taxa
                taxon_key = dplyr::if_else(
                    !morphospecies_resolved & !is.na(morphospeciesID),
                    paste(taxonID, morphospeciesID, sep = "|"),
                    taxonID
                )
            ) |>
            dplyr::select(-dplyr::starts_with("ms_"))
    }

    # Some subplots were surveyed on two dates within one eventID (repeat surveys,
    # often by different observers). Keep the first survey of each subplot-event.
    keep_first_survey <- function(df) {
        df |>
            dplyr::group_by(plotID, eventID, subplotID) |>
            dplyr::filter(endDate == min(endDate)) |>
            dplyr::ungroup()
    }

    # Parse subplotID ("31_1_1" = 1m2, "31_10_1" = 10m2, "31_100" = 100m2)
    add_subplot_parts <- function(df) {
        df |>
            dplyr::mutate(
                sample_area_m2 = dplyr::case_when(
                    grepl("^\\d+_100$", subplotID) ~ 100,
                    grepl("^\\d+_10_\\d+$", subplotID) ~ 10,
                    grepl("^\\d+_1_\\d+$", subplotID) ~ 1
                ),
                subplot_id = stringr::str_extract(subplotID, "^[0-9]+"),
                subsubplot_id = dplyr::if_else(
                    sample_area_m2 < 100, stringr::str_extract(subplotID, "[0-9]+$"), NA_character_
                )
            )
    }

    # 1. 1m2 DATA (percent cover); surveyed subplots only
    div_1m2 <- neon_data_list$div_1m2Data |>
        dplyr::filter(divDataType == "plantSpecies", targetTaxaPresent %in% c("Y", "N")) |>
        tidyr::drop_na(plotID, subplotID, eventID, endDate) |>
        keep_first_survey() |>
        resolve_morpho() |>
        add_subplot_parts() |>
        dplyr::filter(!is.na(sample_area_m2))

    # Same-date duplicate records of one taxon in one subplot: keep the highest cover
    div_1m2_pla <- div_1m2 |>
        dplyr::filter(targetTaxaPresent == "Y", !is.na(taxonID)) |>
        dplyr::arrange(dplyr::desc(percentCover)) |>
        dplyr::distinct(plotID, eventID, subplotID, taxon_key, .keep_all = TRUE) |>
        dplyr::mutate(
            variable_name = "percent cover",
            value = percentCover,
            unit = "percent of plot area covered by taxon"
        )

    # 2. 10m2 AND 100m2 DATA (presence only)
    div_10_100 <- neon_data_list$div_10m2Data100m2Data |>
        dplyr::filter(targetTaxaPresent %in% c("Y", "N")) |>
        tidyr::drop_na(plotID, subplotID, eventID, endDate) |>
        keep_first_survey() |>
        resolve_morpho() |>
        add_subplot_parts() |>
        dplyr::filter(!is.na(sample_area_m2))

    div_10_100_pla <- div_10_100 |>
        dplyr::filter(targetTaxaPresent == "Y", !is.na(taxonID)) |>
        dplyr::distinct(plotID, eventID, subplotID, taxon_key, .keep_all = TRUE)

    # 3. NESTING (user guide 3.9): 10m2 records should exclude taxa already found in
    # the nested 1m2 subplot, and 100m2 records taxa found in any nested 1m2/10m2
    # subplot. Enforce this defensively.
    div_10m2 <- div_10_100_pla |>
        dplyr::filter(sample_area_m2 == 10) |>
        dplyr::anti_join(div_1m2_pla,
            by = c("plotID", "eventID", "subplot_id", "subsubplot_id", "taxon_key")
        )

    div_100m2 <- div_10_100_pla |>
        dplyr::filter(sample_area_m2 == 100) |>
        dplyr::anti_join(
            dplyr::bind_rows(div_1m2_pla, div_10m2),
            by = c("plotID", "eventID", "subplot_id", "taxon_key")
        )

    div_10_100_final <- dplyr::bind_rows(div_10m2, div_100m2) |>
        dplyr::mutate(
            variable_name = "presence absence",
            value = NA_real_,
            unit = NA_character_
        )

    # 4. ZERO ROWS: 1m2 subplots surveyed with no plant species present
    div_1m2_zero <- div_1m2 |>
        dplyr::group_by(plotID, eventID, subplotID) |>
        dplyr::filter(all(targetTaxaPresent == "N")) |>
        dplyr::slice(1) |>
        dplyr::ungroup() |>
        dplyr::mutate(
            dplyr::across(c(taxonID, scientificName, taxonRank, nativeStatusCode), ~NA_character_),
            variable_name = "percent cover",
            value = 0,
            unit = "percent of plot area covered by taxon"
        )

    # 5. SAMPLING EFFORT: which scales were surveyed in each 100m2 subplot x event.
    # Since 2019 the 10m2 and 100m2 scales are surveyed only every other year.
    sampled_scales <- dplyr::bind_rows(div_1m2, div_10_100) |>
        dplyr::distinct(plotID, eventID, subplot_id, sample_area_m2) |>
        dplyr::group_by(plotID, eventID, subplot_id) |>
        dplyr::summarise(
            sampled_scales_m2 = paste(sort(unique(sample_area_m2)), collapse = ","),
            .groups = "drop"
        )

    # 6. Stack Data and format variables
    data_plant <- dplyr::bind_rows(div_1m2_pla, div_10_100_final, div_1m2_zero) |>
        dplyr::filter(
            taxonRank %in% c("variety", "subspecies", "species", "speciesGroup", "genus") |
                is.na(taxonID)
        ) |>
        dplyr::left_join(sampled_scales, by = c("plotID", "eventID", "subplot_id")) |>
        dplyr::mutate(
            year = substr(as.character(endDate), 1, 4),
            observation_datetime = as.POSIXct(endDate, tz = "UTC"),
            unique_sample_id = paste0(namedLocation, "_", subplot_id, "_", year, "-", boutNumber),
            presence_absence = dplyr::if_else(is.na(taxonID), 0, 1)
        )

    # 7. Select and map to neonDivData flat format
    final_tibble <- data_plant |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id = taxonID,
            taxon_name = scientificName,
            taxon_rank = taxonRank,
            latitude = decimalLatitude,
            longitude = decimalLongitude
        ) |>
        flag_redundant_genus() |>
        dplyr::select(dplyr::any_of(c(
            "location_id", "siteID", "plotID", "unique_sample_id", "subplotID", "subplot_id", "subsubplot_id",
            "observation_datetime", "taxon_id", "taxon_name", "taxon_rank",
            "variable_name", "value", "unit", "presence_absence", "boutNumber",
            "nativeStatusCode", "identificationQualifier", "morphospeciesID", "redundant_genus",
            "heightPlantOver300cm", "heightPlantSpecies", "sample_area_m2", "sampled_scales_m2",
            "latitude", "longitude", "elevation", "plotType", "nlcdClass", "release"
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
        dplyr::filter(samplingImpractical == "OK")

    # Keep only count-level columns (plus join keys) so point-level fields are not
    # duplicated. Do not distinct(): count rows identical except for uid are
    # separate detections (user guide 3.8).
    join_cols <- c("eventID", "plotID", "pointID")
    brd_count <- neon_data_list$brd_countdata |>
        dplyr::select(dplyr::all_of(c(join_cols, setdiff(names(neon_data_list$brd_countdata), names(brd_point)))))

    # 2. Join DOWNWARD from Point to Count to preserve zero-bird surveys (QSG keys)
    brd_dat <- brd_point |>
        dplyr::left_join(brd_count, by = join_cols, relationship = "one-to-many") |>
        # Points with no count records at all cannot be interpreted; drop them
        dplyr::filter(!is.na(targetTaxaPresent))

    # 3. Zero-bird points: NEON records one targetTaxaPresent == "N" row per minute.
    # Collapse each zero-bird point count to a single row with value 0.
    brd_zero <- brd_dat |>
        dplyr::group_by(eventID, plotID, pointID) |>
        dplyr::filter(all(targetTaxaPresent == "N")) |>
        dplyr::slice(1) |>
        dplyr::ungroup() |>
        dplyr::mutate(pointCountMinute = NA_real_, clusterSize = 0)

    brd_dat <- brd_dat |>
        dplyr::filter(targetTaxaPresent == "Y") |>
        dplyr::bind_rows(brd_zero)

    # 4. Clean and map variables
    brd_dat <- brd_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(startDate, tz = "UTC"),
            variable_name = "cluster size",
            unit = "count of individuals",
            value = clusterSize,
            unique_sample_id = eventID,
            # pointCountMinute 88 = observed outside the timed count (user guide 3.5)
            incidental_observation = pointCountMinute %in% 88
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id = taxonID,
            taxon_name = scientificName,
            taxon_rank = taxonRank,
            latitude = decimalLatitude,
            longitude = decimalLongitude
        )

    # 5. Format exactly to the neonDivData target tibble
    # No distinct() here: identical-looking rows are separate detections.
    final_tibble <- brd_dat |>
        flag_redundant_genus(sample_cols = c("unique_sample_id", "plotID", "pointID")) |>
        dplyr::select(dplyr::any_of(c(
            "location_id", "siteID", "plotID", "pointID", "unique_sample_id",
            "observation_datetime", "taxon_id", "taxon_name", "taxon_rank",
            "variable_name", "value", "unit", "boutNumber", "pointCountMinute",
            "incidental_observation", "targetTaxaPresent", "redundant_genus",
            "nativeStatusCode", "observerDistance", "detectionMethod", "visualConfirmation",
            "sexOrAge", "release", "startCloudCoverPercentage", "endCloudCoverPercentage",
            "startRH", "endRH", "observedHabitat", "observedAirTemp",
            "kmPerHourObservedWindSpeed", "samplingProtocolVersion", "remarks",
            "clusterCode", "latitude", "longitude", "elevation", "nlcdClass", "plotType"
        ))) |>
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
    # 1. Base table is TRAPPING to preserve zero-catch effort.
    # Zero-catch traps (targetTaxaPresent == "N") have no sampleID, so sampleID is
    # NOT required here. samplingImpractical is NA in older records (treat as OK).
    mos_trapping <- neon_data_list$mos_trapping |>
        dplyr::filter(
            is.na(samplingImpractical) | samplingImpractical == "OK",
            targetTaxaPresent %in% c("Y", "N", "U"),
            as.numeric(trapHours) > 0 # Trap must have actually been deployed
        ) |>
        tidyr::drop_na(collectDate, namedLocation) |>
        dplyr::select(
            namedLocation, siteID, plotID, plotType, nlcdClass,
            decimalLatitude, decimalLongitude, elevation,
            collectDate, trapHours, nightOrDay, eventID, sampleID,
            samplingProtocolVersion, fanStatus, catchCupStatus, CO2Status,
            sampleCondition_trapping = sampleCondition,
            targetTaxaPresent_trapping = targetTaxaPresent,
            release_trapping = release
        ) |>
        dplyr::distinct() |>
        dplyr::mutate(
            # Zero-catch traps lack a sampleID; build one from plot and collection
            # time (UTC). NEON sampleIDs use local time, so the made-up ids get a
            # distinct format ("plotID.YYYYMMDDTHHMMZ.empty") that cannot collide.
            unique_sample_id = dplyr::coalesce(
                sampleID,
                paste(plotID, format(collectDate, "%Y%m%dT%H%MZ", tz = "UTC"), "empty", sep = ".")
            )
        )

    # 2. Extract Sorting and Expert ID tables
    mos_sorting <- neon_data_list$mos_sorting |>
        tidyr::drop_na(sampleID, subsampleID) |>
        dplyr::select(
            sampleID, subsampleID, sortDate, proportionIdentified,
            sampleCondition_sorting = sampleCondition,
            remarks_sorting = remarks
        ) |>
        dplyr::distinct()

    mos_expert <- neon_data_list$mos_expertTaxonomistIDProcessed |>
        tidyr::drop_na(subsampleID) |>
        dplyr::select(
            subsampleID, individualCount, taxonID, scientificName, taxonRank,
            nativeStatusCode, sex,
            targetTaxaPresent_expert = targetTaxaPresent,
            sampleCondition_expert = sampleCondition,
            release_expert = release
        ) |>
        dplyr::distinct()

    # 3. Join DOWNWARD from Trapping to preserve all deployed traps
    mos_dat <- mos_trapping |>
        dplyr::left_join(mos_sorting,
            by = "sampleID", na_matches = "never", relationship = "many-to-many"
        ) |>
        dplyr::left_join(mos_expert,
            by = "subsampleID", na_matches = "never", relationship = "many-to-many"
        )

    # 4. Handle duplicate expert records (keeping sex distinct)
    mos_dat <- resolve_neon_duplicates(
        mos_dat,
        group_cols = c("unique_sample_id", "taxonID", "sex"),
        sum_col = "individualCount"
    )

    # 5. Classify rows: counted taxa vs true zeros; drop the rest
    # (e.g. family-level IDs, uncertain traps without expert IDs)
    mos_dat <- mos_dat |>
        dplyr::mutate(
            is_count = !is.na(taxonID) & !(taxonRank %in% "family") &
                !is.na(individualCount) & individualCount > 0,
            is_zero = is.na(taxonID) &
                (targetTaxaPresent_trapping == "N" | targetTaxaPresent_expert %in% "N")
        ) |>
        dplyr::filter(is_count | is_zero) |>
        # a sample is a zero only if no taxon was counted in it; keep one zero row
        dplyr::group_by(unique_sample_id) |>
        dplyr::filter(!(is_zero & any(is_count))) |>
        dplyr::ungroup() |>
        dplyr::distinct(unique_sample_id, taxonID, sex, .keep_all = TRUE) |>
        dplyr::mutate(
            proportionIdentified = as.numeric(proportionIdentified),
            # Estimated total = ID'd count / proportion of the sample identified
            estimated_totIndividuals = dplyr::if_else(
                is_zero, 0, round(individualCount / proportionIdentified)
            )
        ) |>
        dplyr::filter(is.finite(estimated_totIndividuals), estimated_totIndividuals >= 0)

    # 6. Target column layout (Strict order)
    target_cols <- c(
        "location_id", "siteID", "unique_sample_id", "subsampleID", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank", "variable_name", "value", "unit",
        "nativeStatusCode", "redundant_genus", "proportionIdentified", "release", "remarks_sorting",
        "samplingProtocolVersion", "sex", "sortDate", "trapHours", "nightOrDay",
        "sampleCondition", "trapConditionFlag", "latitude",
        "longitude", "elevation", "nlcdClass", "plotType"
    )

    # 7. Format exactly to the neonDivData target tibble
    final_tibble <- mos_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(collectDate, tz = "UTC"),
            variable_name = "abundance",
            value = estimated_totIndividuals / as.numeric(trapHours),
            unit = "count per trap hour",
            release = dplyr::coalesce(release_expert, release_trapping),
            # Sample quality from all three processing steps (NA = no known compromise)
            sampleCondition = collapse_flags(
                flag_value(sampleCondition_trapping, "trapping: ", "No known compromise"),
                flag_value(sampleCondition_sorting, "sorting: ", "No known compromise"),
                flag_value(sampleCondition_expert, "expert ID: ", "No known compromise")
            ),
            # Trap operation problems (QSG data quality section)
            trapConditionFlag = collapse_flags(
                flag_value(fanStatus, "fan: ", "On"),
                flag_value(catchCupStatus, "catch cup: ", "OK"),
                flag_value(CO2Status, "CO2: ", "Present")
            )
        ) |>
        dplyr::rename(
            location_id = namedLocation,
            taxon_id = taxonID,
            taxon_name = scientificName,
            taxon_rank = taxonRank,
            latitude = decimalLatitude,
            longitude = decimalLongitude
        ) |>
        flag_redundant_genus() |>
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
            # A few 2014-2015 records carry placeholder eventIDs shared across sites
            # and years (e.g. "bet_fielddata_in"); rebuild those as SITE.YEAR.WEEK.
            eventID = dplyr::if_else(
                grepl("^[A-Z]{4}\\.\\d{4}\\.\\d{1,2}$", eventID),
                eventID,
                paste(siteID, lubridate::isoyear(collectDate), lubridate::isoweek(collectDate), sep = ".")
            ),

            # Consolidate trap condition flags per user guide section 5.4.
            # cupStatus, lidStatus, fluidLevel can each indicate sample quality issues;
            # all non-OK values are kept (raw OK values are "Ok" / "Ok, washer used").
            trapConditionFlag = collapse_flags(
                flag_value(cupStatus, "cup: ", "Ok"),
                flag_value(lidStatus, "lid: ", c("Ok", "Ok, washer used")),
                flag_value(fluidLevel, "fluid: ", "Ok")
            )
        ) |>
        # Trapping days: traps collected more than once from the same setDate count
        # days since the previous collection, not since setDate
        dplyr::group_by(namedLocation, trapID, setDate) |>
        dplyr::arrange(collectDate, .by_group = TRUE) |>
        dplyr::mutate(
            trappingDays = as.numeric(collectDate - dplyr::coalesce(dplyr::lag(collectDate), setDate))
        ) |>
        dplyr::ungroup() |>
        # Bout date = most common collectDate within the site x eventID (collection can
        # span 2 dates per user guide 3.2). The actual collectDate is kept for
        # observation_datetime.
        dplyr::group_by(siteID, eventID) |>
        dplyr::mutate(boutDate = Mode(collectDate)) |>
        dplyr::ungroup() |>
        dplyr::mutate(boutID = paste(siteID, as.character(boutDate), sep = "_")) |>
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
        # Rare individuals with >1 expert record: keep the most recent ID
        dplyr::group_by(individualID) |>
        dplyr::slice_max(identifiedDate, n = 1, with_ties = FALSE) |>
        dplyr::ungroup() |>
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
    # Samples with no bet_sorting record at all were never processed (nearly every
    # pitfall sample contains some bycatch), so they are dropped rather than
    # treated as zeros. Sorted samples with no carabids are true zeros (value 0).
    # --------------------------------------------------------------------------
    sorted_samples <- unique(neon_data_list$bet_sorting$sampleID)
    carabid_samples <- unique(sort_dat$sampleID)

    bet_dat <- field_dat |>
        dplyr::filter(sampleID %in% sorted_samples) |>
        dplyr::left_join(final_tax, by = "sampleID", relationship = "one-to-many") |>
        dplyr::mutate(
            count = dplyr::if_else(is.na(taxonID) & !sampleID %in% carabid_samples, 0, count),
            # Guard against trappingDays == 0 producing Inf
            abundance = dplyr::if_else(
                !is.na(count) & !is.na(trappingDays) & trappingDays > 0,
                count / trappingDays,
                NA_real_
            ),
            variable_name = "abundance",
            unit = "count per trap day",
            unique_sample_id = sampleID,
            observation_datetime = as.POSIXct(collectDate, tz = "UTC")
        ) |>
        dplyr::filter(is.finite(abundance), abundance >= 0)

    # --------------------------------------------------------------------------
    # 9. FORMAT AND RETURN
    # samplingImpractical, sampleCondition and trapConditionFlag included for
    # downstream filtering
    # --------------------------------------------------------------------------
    target_cols <- c(
        "location_id", "siteID", "plotID", "unique_sample_id", "trapID",
        "observation_datetime", "taxon_id", "taxon_name", "taxon_rank",
        "variable_name", "value", "unit",
        "boutID", "nativeStatusCode", "redundant_genus", "release", "remarks",
        "samplingProtocolVersion", "samplingImpractical", "sampleCondition",
        "trapConditionFlag", "trappingDays", "latitude", "longitude", "elevation", "nlcdClass"
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
        dplyr::mutate(
            sampleCondition = dplyr::na_if(sampleCondition, "OK"),
            samplingImpractical = dplyr::na_if(samplingImpractical, "OK")
        ) |>
        flag_redundant_genus() |>
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
            # eventID (SITE.YEAR.WEEK) is the authoritative bout identifier;
            # fall back to site_year_month if it is ever missing
            bout = dplyr::if_else(
                is.na(eventID) | eventID == "",
                paste(siteID, year, month, sep = "_"),
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
    # n_trap_nights_per_night_uid = unique trap positions (trapCoordinate) that
    # were actually set per nightUID. Traps with status "1 - trap not set" and
    # placeholder coordinates (e.g. "XX", "AX"; captures with an uncertain trap
    # location) do not add trap nights. Sum across nights in a bout =
    # n_trap_nights_per_bout_per_plot. Effort and captures are both aggregated by
    # plot x bout (bouts can cross a month boundary).
    # --------------------------------------------------------------------------
    trap_effort <- trap_dat |>
        dplyr::filter(
            trapStatus != "1 - trap not set",
            grepl("^[A-J]([1-9]|10)$", trapCoordinate)
        ) |>
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
        dplyr::group_by(location_id = namedLocation, siteID, plotID, bout) |>
        dplyr::summarise(
            n_trap_nights_per_bout_per_plot = sum(n_trap_nights_per_night_uid, na.rm = TRUE),
            n_nights_per_bout = dplyr::n_distinct(nightuid),
            year = dplyr::first(year[collectDate == min(collectDate)]),
            month = dplyr::first(month[collectDate == min(collectDate)]),
            observation_datetime = as.POSIXct(max(collectDate), tz = "UTC"),
            release = paste(unique(release), collapse = "|"),
            .groups = "drop"
        ) |>
        dplyr::filter(n_trap_nights_per_bout_per_plot > 0) |>
        dplyr::mutate(unique_sample_id = paste(location_id, bout, sep = "_"))

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
    # Within each plot x bout, a tagged individual (tagID) is counted only once
    # (an individual caught on two plots in one bout counts on both plots).
    # Untagged individuals (NA / blank tagID) cannot be tracked across nights;
    # use the pertrapnight uid (unique per row) as a proxy so every untagged
    # capture is treated as a distinct individual. When recaptures of one
    # individual carry different taxonIDs, the most frequent ID is used.
    # --------------------------------------------------------------------------
    cap_dat <- cap_dat |>
        dplyr::mutate(
            tag_key = dplyr::case_when(
                !is.na(tagID) & tagID != "" ~ tagID,
                TRUE ~ paste("untagged", uid, sep = "_")
            )
        ) |>
        dplyr::add_count(namedLocation, bout, tag_key, taxonID, name = "n_id") |>
        dplyr::arrange(dplyr::desc(n_id), collectDate) |>
        dplyr::distinct(namedLocation, bout, tag_key, .keep_all = TRUE)

    # --------------------------------------------------------------------------
    # 6. AGGREGATE CAPTURES per location x bout x taxon
    # Guide section 3: shrews, moles, large squirrels, rabbits, weasels, etc. are
    # not target small mammals (incidental captures); they are kept but flagged.
    # --------------------------------------------------------------------------
    non_target_genera <- c(
        "Blarina", "Sorex", "Cryptotis", "Notiosorex", # shrews
        "Condylura", "Neurotrichus", "Parascalops", "Scalopus", "Scapanus", # moles
        "Sylvilagus", "Lepus", "Ochotona", # lagomorphs
        "Mustela", "Neogale", # weasels
        "Didelphis", # opossum
        "Sciurus", "Tamiasciurus", # large tree squirrels
        "Geomys", "Thomomys" # pocket gophers (fossorial)
    )

    cap_agg <- cap_dat |>
        dplyr::group_by(
            location_id      = namedLocation,
            bout,
            taxon_id         = taxonID,
            taxon_name       = scientificName,
            taxon_rank       = taxonRank,
            nativeStatusCode
        ) |>
        dplyr::summarise(raw_count = dplyr::n(), .groups = "drop") |>
        dplyr::mutate(target_taxon = !stringr::word(taxon_name, 1) %in% non_target_genera)

    # --------------------------------------------------------------------------
    # 7. JOIN EFFORT WITH CAPTURES
    # Plot-bouts with no target small mammal captured get one zero row
    # (taxon_id = NA, value = 0); non-target captures are kept as extra rows.
    # --------------------------------------------------------------------------
    target_bouts <- dplyr::filter(cap_agg, target_taxon) |>
        dplyr::distinct(location_id, bout)

    zero_dat <- effort_dat |>
        dplyr::anti_join(target_bouts, by = c("location_id", "bout")) |>
        dplyr::mutate(raw_count = 0L)

    mam_dat <- effort_dat |>
        dplyr::inner_join(cap_agg,
            by = c("location_id", "bout"),
            relationship = "one-to-many"
        ) |>
        dplyr::bind_rows(zero_dat) |>
        dplyr::mutate(
            variable_name = "count",
            unit = "unique individuals per 100 trap nights per plot per bout",
            n_individuals = raw_count,
            value = 100 * raw_count / n_trap_nights_per_bout_per_plot
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
    # Zero-catch effort rows (taxon_id = NA, value = 0) are retained so that
    # downstream users can use full sampling effort for occupancy modelling.
    # --------------------------------------------------------------------------
    target_cols <- c(
        "location_id", "siteID", "plotID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank", "variable_name", "value", "unit",
        "n_individuals", "target_taxon", "redundant_genus",
        "year", "month", "n_trap_nights_per_bout_per_plot", "n_nights_per_bout",
        "nativeStatusCode", "release", "latitude", "longitude", "elevation",
        "plotType", "nlcdClass"
    )

    final_tibble <- final_dat |>
        flag_redundant_genus() |>
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

    # 3. RECONCILE DIATOM COUNTS (user guide 3.9)
    # Soft algae + diatom counts ("soft algae") are quantitative; diatom slide
    # counts give species-level RELATIVE abundance only. Following the guide, the
    # total diatom count from the soft-algae analysis (D) is split among slide taxa
    # by their slide proportions, and replaces the soft-algae diatom records.
    # When a sample has slide data but no soft-algae diatoms (D = 0), the slide
    # cellsPerBottle values are used as reported. Adding both analyses together
    # would double count diatoms.
    diatom_classes <- c("Bacillariophyceae", "Coscinodiscophyceae", "Mediophyceae")

    alg_cells <- alg_tax |>
        dplyr::filter(algalParameterUnit == "cellsPerBottle", !is.na(acceptedTaxonID)) |>
        dplyr::mutate(algalParameterValue = as.numeric(algalParameterValue))

    soft <- dplyr::filter(alg_cells, algalAnalysisMethod == "soft algae")

    soft_diatom_total <- soft |>
        dplyr::filter(class %in% diatom_classes) |>
        dplyr::group_by(sampleID) |>
        dplyr::summarise(D = sum(algalParameterValue, na.rm = TRUE), .groups = "drop")

    slide <- alg_cells |>
        dplyr::filter(algalAnalysisMethod == "diatom slide") |>
        dplyr::group_by(sampleID) |>
        dplyr::mutate(p = algalParameterValue / sum(algalParameterValue, na.rm = TRUE)) |>
        dplyr::ungroup() |>
        dplyr::left_join(soft_diatom_total, by = "sampleID") |>
        dplyr::mutate(
            use_prop = !is.na(D) & D > 0,
            algalParameterValue = dplyr::if_else(use_prop, p * D, algalParameterValue),
            count_method = dplyr::if_else(
                use_prop,
                "diatom slide proportion x soft algae diatom count",
                "diatom slide count"
            )
        ) |>
        dplyr::select(-p, -D, -use_prop)

    alg_tax <- soft |>
        dplyr::filter(!(class %in% diatom_classes & sampleID %in% slide$sampleID)) |>
        dplyr::mutate(count_method = "soft algae count") |>
        dplyr::bind_rows(slide)

    # 4. JOIN TAXONOMY + BIOMASS; resolve perBottleSampleVolume
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

    # 5. JOIN WITH FIELD DATA (drop columns already in alg_tax_bio except join key)
    join_cols <- intersect(names(alg_tax_bio), names(alg_field))
    join_cols <- setdiff(join_cols, "parentSampleID")

    alg_dat <- alg_tax_bio |>
        dplyr::left_join(
            dplyr::select(alg_field, -dplyr::any_of(join_cols)),
            by = "parentSampleID",
            na_matches = "never",
            relationship = "many-to-many"
        )

    # 6. COMPUTE DENSITY; filter to valid records
    # sampleCondition is kept as a column for users to filter (not filtered here)
    alg_dat <- alg_dat |>
        dplyr::mutate(
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
            !is.na(density),
            density >= 0,
            is.finite(density)
        )

    # 7. RESOLVE DUPLICATES: same sampleID + acceptedTaxonID → sum densities
    # (distinct morphotypes / size records of one taxon within an analysis)
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

    # 8. FINAL COLUMN LAYOUT (match existing data_algae column order)
    target_cols <- c(
        "location_id", "siteID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank",
        "variable_name", "value", "unit", "count_method", "redundant_genus",
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
            unique_sample_id     = sampleID,
            sampleCondition      = dplyr::na_if(sampleCondition, "Condition OK")
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
        flag_redundant_genus() |>
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
    # Records with NA estimatedTotalCount (mostly damaged samples) are dropped
    # before summing so that a taxon with only NA counts does not become 0.
    inv_tax_raw <- neon_data_list$inv_taxonomyProcessed

    inv_tax <- inv_tax_raw |>
        dplyr::filter(targetTaxaPresent == "Y", !is.na(estimatedTotalCount)) |>
        dplyr::group_by(sampleID, acceptedTaxonID, scientificName, taxonRank) |>
        dplyr::summarise(
            estimatedTotalCount = sum(estimatedTotalCount),
            individualCount = sum(individualCount, na.rm = TRUE),
            subsamplePercent = paste(unique(subsamplePercent), collapse = "|"),
            sampleCondition = paste(sort(setdiff(stats::na.omit(sampleCondition), "condition OK")), collapse = "|"),
            release = paste(unique(release), collapse = "|"),
            .groups = "drop"
        )

    # Zero samples: processed samples with no target taxa (targetTaxaPresent == "N")
    inv_zero <- inv_tax_raw |>
        dplyr::group_by(sampleID) |>
        dplyr::filter(all(targetTaxaPresent == "N")) |>
        dplyr::summarise(
            estimatedTotalCount = 0,
            individualCount = 0,
            sampleCondition = paste(sort(setdiff(stats::na.omit(sampleCondition), "condition OK")), collapse = "|"),
            release = paste(unique(release), collapse = "|"),
            .groups = "drop"
        )

    # 3. JOIN AND COMPUTE DENSITY
    # inner_join: records without matching field data cannot have a valid density
    inv_dat <- dplyr::bind_rows(inv_tax, inv_zero) |>
        dplyr::inner_join(
            dplyr::select(
                inv_field,
                sampleID, namedLocation, siteID, collectDate,
                benthicArea, habitatType, samplerType, substratumSizeClass,
                remarks, ponarDepth, snagLength, snagDiameter, dataQF,
                decimalLatitude, decimalLongitude, elevation
            ),
            by = "sampleID"
        ) |>
        dplyr::mutate(
            benthicArea  = as.numeric(benthicArea),
            ponarDepth   = as.numeric(ponarDepth),
            snagLength   = as.numeric(snagLength),
            snagDiameter = as.numeric(snagDiameter),
            density      = dplyr::if_else(
                is.na(acceptedTaxonID), 0, estimatedTotalCount / benthicArea
            ),
            sampleCondition = dplyr::na_if(sampleCondition, "")
        ) |>
        dplyr::filter(!is.na(density), density >= 0, is.finite(density))

    # 4. FINAL COLUMN LAYOUT (match existing data_macroinvertebrate column order)
    target_cols <- c(
        "location_id", "siteID", "unique_sample_id", "observation_datetime",
        "taxon_id", "taxon_name", "taxon_rank",
        "variable_name", "value", "unit", "redundant_genus",
        "estimatedTotalCount", "individualCount", "subsamplePercent",
        "release", "sampleCondition", "dataQF", "benthicArea", "habitatType", "samplerType",
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
        flag_redundant_genus() |>
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
            adultCount = as.numeric(adultCount),
            # A few drags coded "no ticks" do have lab-identified ticks
            targetTaxaPresent = dplyr::if_else(
                sampleID %in% neon_data_list$tck_taxonomyProcessed$sampleID,
                "Y", targetTaxaPresent
            )
        ) |>
        dplyr::rename(remarks_field = remarks, release_field = release)

    # 2. LAB TAXONOMY DATA: standardize LifeStage, aggregate across sex classes
    # Drop records with unrecognised sexOrAge to avoid NA LifeStage creating a
    # spurious "NA" column in the pivot_wider lab summary below. Lab
    # sampleCondition is not filtered: damaged ticks are still identified and counted.
    tck_tax <- neon_data_list$tck_taxonomyProcessed |>
        dplyr::filter(!is.na(acceptedTaxonID), !is.na(individualCount)) |>
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
        ) |>
        dplyr::mutate(count_source = "lab")

    # 3. RECONCILE MISSING COUNTS
    # 2014-2018 only: field staff counted ticks by life stage, and the lab did not
    # always identify every tick (invoice limits, subsampling of >500 larvae; user
    # guide 3, 3.3, 5.4). Field counts stopped in 2019. When field counts exceed
    # lab counts, the unidentified remainder is added as "Ixodidae sp." (IXOSP),
    # the code NEON itself uses for unidentified ticks. The per-stage excess is
    # capped so the sample total equals max(field total, lab total); this avoids
    # double counting ticks that field staff assigned to the wrong life stage.
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
            dplyr::across(c(Larva, Nymph, Adult), ~ tidyr::replace_na(.x, 0)),
            dplyr::across(c(larvaCount, nymphCount, adultCount), ~ tidyr::replace_na(.x, 0)),
            total_excess = pmax(0, (larvaCount + nymphCount + adultCount) - (Larva + Nymph + Adult)),
            Larva = pmax(0, larvaCount - Larva),
            Nymph = pmax(0, nymphCount - Nymph),
            Adult = pmax(0, adultCount - Adult)
        ) |>
        dplyr::select(sampleID, total_excess, Larva, Nymph, Adult) |>
        tidyr::pivot_longer(
            cols      = c(Larva, Nymph, Adult),
            names_to  = "LifeStage",
            values_to = "stage_excess"
        ) |>
        # Allocate the capped total across stages in proportion to each stage's
        # excess (largest-remainder rounding keeps whole ticks)
        dplyr::group_by(sampleID) |>
        dplyr::mutate(
            raw = if (sum(stage_excess) > 0) stage_excess * total_excess / sum(stage_excess) else 0,
            individualCount = floor(raw),
            remainder_rank = rank(-(raw - individualCount), ties.method = "first"),
            individualCount = individualCount +
                (remainder_rank <= (total_excess[1] - sum(individualCount)))
        ) |>
        dplyr::ungroup() |>
        dplyr::filter(individualCount > 0) |>
        dplyr::select(sampleID, LifeStage, individualCount) |>
        dplyr::mutate(
            acceptedTaxonID = "IXOSP",
            scientificName  = "Ixodidae sp.",
            taxonRank       = "family",
            count_source    = "field count excess"
        )

    # 4. COMBINE LAB COUNTS AND RECONCILED MISSING COUNTS
    final_tax <- dplyr::bind_rows(tck_tax, missing_ticks) |>
        dplyr::group_by(sampleID, acceptedTaxonID, scientificName, taxonRank, LifeStage) |>
        dplyr::summarise(
            individualCount = sum(individualCount, na.rm = TRUE),
            release = paste(stats::na.omit(unique(release_tax)), collapse = "|"),
            count_source = paste(sort(unique(count_source)), collapse = " + "),
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
        "LifeStage", "count_source", "redundant_genus", "release", "remarks_field",
        "sampleCondition", "samplingMethod", "targetTaxaPresent",
        "totalSampledArea", "latitude", "longitude", "elevation", "nlcdClass", "plotType"
    )

    final_tibble <- tck_dat |>
        dplyr::mutate(
            observation_datetime = as.POSIXct(collectDate, tz = "UTC"),
            variable_name = "abundance",
            unit = "count per square meter",
            unique_sample_id = paste(plotID, collectDate, sep = "_"),
            sampleCondition = dplyr::na_if(sampleCondition, "No known compromise"),
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
        flag_redundant_genus(sample_cols = c("unique_sample_id", "LifeStage")) |>
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
        # Drop non-pathogen assays: the DNA quality control and the tick species
        # confirmation PCRs (added 2021-2022), which are not pathogens
        dplyr::filter(
            !testPathogenName %in% c(
                "HardTick DNA Quality", "Ixodes pacificus", "Ixodes scapularis",
                "Amblyomma americanum", "Dermacentor variabilis", "Haemaphysalis longicornis"
            )
        )

    # 4. TAXONOMY CLEANUP AND LIFESTAGE EXTRACTION
    # Unify Borrelia burgdorferi and Borrelia burgdorferi sensu lato
    # (mutually exclusive per testingID; verified in source data).
    # subsampleID format: plotID.date.vectorTaxonID.lifeStage
    # lifeStage = 4th segment; vector_taxon_id = 3rd segment (tick taxonID).
    path_dat <- path_dat |>
        dplyr::mutate(
            testPathogenName = dplyr::if_else(
                testPathogenName == "Borrelia burgdorferi",
                "Borrelia burgdorferi sensu lato",
                testPathogenName
            ),
            lifeStage = sub(".*\\.", "", subsampleID),
            vector_taxon_id = stringr::str_split_i(subsampleID, stringr::fixed("."), 3),
            pos_result = dplyr::if_else(testResult == "Positive", 1L, 0L)
        )

    # 5. SPATIAL METADATA (one representative row per namedLocation)
    # Use the most frequent coordinates so the choice does not depend on row order
    loc_meta <- path_dat |>
        dplyr::count(
            namedLocation, siteID, plotID,
            decimalLatitude, decimalLongitude, elevation,
            nlcdClass, plotType
        ) |>
        dplyr::arrange(namedLocation, dplyr::desc(n), decimalLatitude, decimalLongitude) |>
        dplyr::distinct(namedLocation, .keep_all = TRUE) |>
        dplyr::select(-n)

    # 6. AGGREGATE POSITIVITY RATES
    # One row per location x date x vector species x pathogen x lifeStage.
    # Vector species must not be pooled: each tick genus is tested for a different
    # pathogen panel and prevalence differs strongly among species (guide 3, 3.8).
    path_agg <- path_dat |>
        dplyr::group_by(
            namedLocation, collectDate, vector_taxon_id, testPathogenName, lifeStage
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
        "variable_name", "value", "unit", "vector_taxon_id", "lifeStage",
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

    # 2. TAXONOMY DATA: aggregate by taxon
    # Sum adjCountPerBottle to safely collapse size-class / life-stage records for the
    # same taxon. User guide (Eq. 2): density = SUM(adjCountPerBottle) / towsTrapsVolume,
    # where the sum is taken over all records for a given sampleID before dividing.
    # sampleCondition is NOT filtered: most non-OK values are life-stage notes
    # ("other (specified in remarks)") or affect lengths only. Non-OK values are
    # carried in the output for users to filter.
    zoo_tax <- neon_data_list$zoo_taxonomyProcessed |>
        dplyr::filter(!is.na(adjCountPerBottle)) |>
        dplyr::group_by(sampleID, taxonID, scientificName, taxonRank) |>
        dplyr::summarise(
            adjCountPerBottle = sum(adjCountPerBottle),
            sampleCondition   = paste(sort(unique(
                sampleCondition[!is.na(sampleCondition) & tolower(sampleCondition) != "condition ok"]
            )), collapse = "|"),
            release           = paste(unique(stats::na.omit(release)), collapse = "|"),
            .groups           = "drop"
        ) |>
        dplyr::mutate(sampleCondition = dplyr::na_if(sampleCondition, ""))

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
        "unit", "redundant_genus", "release", "sampleCondition", "samplerType", "towsTrapsVolume",
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
        flag_redundant_genus() |>
        dplyr::select(dplyr::any_of(target_cols)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()

    return(final_tibble)
}
