#' Clean NEON Data (Dispatcher)
#'
#' @param neon_data_list List of raw NEON tables
#' @param taxon Character string of the taxon group
#' @export
clean_neon_data <- function(neon_data_list, taxon) {
    clean_functions <- list(
        algae = clean_neon_algae,
        beetle = clean_neon_beetle,
        bird = clean_neon_bird,
        fish = clean_neon_fish,
        herp_bycatch = clean_neon_herp_bycatch,
        macroinvertebrate = clean_neon_macroinvertebrate,
        mosquito = clean_neon_mosquito,
        plant = clean_neon_plant,
        small_mammal = clean_neon_small_mammal,
        tick = clean_neon_tick,
        tick_pathogen = clean_neon_tick_pathogen,
        zooplankton = clean_neon_zooplankton
    )

    if (!taxon %in% names(clean_functions)) {
        stop(paste("Taxon", taxon, "is not yet supported."))
    }

    # Dispatch to the specific cleaning function
    res <- clean_functions[[taxon]](neon_data_list)
    return(res)
}

# --- Helper Functions (used internally by the taxon scripts) ---

#' Standardize NEON tables
#' @noRd
standardize_neon_table <- function(df, required_cols) {
    df |>
        tidyr::drop_na(dplyr::all_of(required_cols)) |>
        dplyr::mutate(dplyr::across(dplyr::where(is.factor), as.character)) |>
        dplyr::mutate(dplyr::across(dplyr::contains("Date"), as.character)) |>
        dplyr::distinct() |>
        dplyr::as_tibble()
}

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
