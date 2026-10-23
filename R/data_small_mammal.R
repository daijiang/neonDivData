#' Small mammal box trap data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10072.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10072.001>.
#'
#' To process data we:
#' 1. Filter nights from `mam_perplotnight` where `samplingImpractical` is not `"OK"` (field added 2020; pre-2020 records without this field are retained).
#' 2. Identify bouts using `eventID` from `mam_perplotnight` (site x year x week).
#' 3. Compute trapping effort as the number of unique trap coordinates actually set per night (traps with status `"1 - trap not set"` and placeholder coordinates such as `"XX"` are excluded), summed across all valid nights within a bout per plot (`n_trap_nights_per_bout_per_plot`).
#' 4. Retain only capture records with `trapStatus` `"5 - capture"` or `"4 - more than 1 capture in one trap"`, restricting to taxa identified to genus or finer rank.
#' 5. Resolve within-bout recaptures: tagged individuals (non-missing `tagID`) are counted once per plot per bout; untagged individuals (missing `tagID`) are each treated as unique using their row identifier. When recaptures of one individual were assigned different taxa, the most frequent identification is used.
#' 6. Compute `value` as `100 * n_individuals / n_trap_nights_per_bout_per_plot` (unique individuals per 100 trap nights per plot per bout). Effort and captures are both aggregated by plot and bout, including bouts that span two months.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Zero rows.** A plot-bout in which no target small mammal was captured is kept as one row with `taxon_id = NA`, `value = 0`, and `n_individuals = 0`. This zero-row convention is shared by all neonDivData observation datasets.
#'
#' **Non-target taxa.** NEON targets cricetid, heteromyid, and murid rodents and small sciurids; shrews, moles, rabbits and pikas, weasels, opossums, large tree squirrels, and pocket gophers are captured only incidentally (user guide section 3). These captures are kept with `target_taxon = FALSE`. To analyze target taxa only, use `dplyr::filter(data_small_mammal, target_taxon | is.na(taxon_id))`; plot-bouts with only non-target captures already have a zero row.
#'
#' **Comparability.** Diversity grids are trapped one night per bout and pathogen grids three nights per bout (`n_nights_per_bout`), so unique individuals per 100 trap nights is lower on three-night grids as recaptures accumulate. Use `n_individuals` with `n_nights_per_bout` (or mark-recapture models on the NEON data) when comparing grid types. `redundant_genus` marks genus-level records that co-occur with a finer identification of the same genus in the same plot-bout.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of unique samples (`location_id_eventID`, one plot-bout).
#' - `observation_datetime`: Date of the last trapping night of the bout.
#' - `taxon_id`: Accepted species code, based on one or more sources. `NA` for zero rows.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Unique individuals per 100 trap nights per plot per bout; `0` for zero rows.
#' - `unit`: Unit of the values in the `value` column.
#' - `n_individuals`: Number of unique individuals captured in the plot-bout.
#' - `target_taxon`: `FALSE` for taxa that are not NEON small mammal targets; `NA` for zero rows.
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same plot-bout.
#' - `year`: Year of the first trapping night of the bout.
#' - `month`: Month of the first trapping night of the bout.
#' - `n_trap_nights_per_bout_per_plot`: Number of trap nights per bout per plot.
#' - `n_nights_per_bout`: Number of nights per bout.
#' - `nativeStatusCode`: Whether the species is a native or non-native species.
#' 'A': Presumed absent, due to lack of data indicating a taxon's presence in a
#' given location; 'N': Native; 'I': Introduced; 'UNK': Status unknown.
#' - `release`: Version of data release by NEON.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#'
#' @author Marta Jarzyna
#' @source <https://data.neonscience.org>
#'
"data_small_mammal"
