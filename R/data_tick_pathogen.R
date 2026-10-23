#' Tick-borne pathogen status
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10092.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10092.001>.
#'
#' To clean the data, we:
#'
#' 1. Removed tests from batches that failed quality criteria (`criteriaMet != "Y"` in `tck_pathogenqa`). QA records are linked by batch only from 2021 onward, and all batches in the current release met the criteria.
#' 2. Removed samples where `sampleCondition != "OK"` or `testResult` is `NA`.
#' 3. Applied the DNA quality fix: identified ticks (`testingID`) whose `HardTick DNA Quality` test was not `"Positive"` and dropped all test rows for those ticks (not just the DNA quality row itself), because pathogen results from ticks with degraded DNA are unreliable.
#' 4. Removed assays that are not pathogens: `HardTick DNA Quality` and the tick species confirmation tests (`Ixodes pacificus`, `Ixodes scapularis`, `Amblyomma americanum`, `Dermacentor variabilis`, `Haemaphysalis longicornis`; added 2021-2022). Unified `"Borrelia burgdorferi"` into `"Borrelia burgdorferi sensu lato"`.
#' 5. Extracted the vector tick taxon (`vector_taxon_id`) and `lifeStage` from `subsampleID` (`plotID.date.vectorTaxonID.lifeStage`).
#' 6. Aggregated to one row per location x date x vector taxon x pathogen x life stage: `value` = `n_positive_test / n_tests`.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Vector species.** Each tick genus is tested for a different pathogen panel (e.g. Borrelia burgdorferi s.l., Babesia, and Anaplasma in Ixodes; Ehrlichia and Francisella in Amblyomma), and prevalence differs strongly among tick species. Always analyze positivity rates within `vector_taxon_id`. The panel also determines which pathogen rows exist, so the absence of a pathogen row means it was not tested, not that it was absent.
#'
#' **Interpretation.** `Borrelia sp.` is a genus-level screen; ticks positive for any Borrelia species are also positive for `Borrelia sp.`, so do not sum positives across Borrelia rows. Some pathogens (e.g. Rickettsia parkeri and Rickettsia philipii) were added to the panel only in 2022. Many rows are based on few tests (`n_tests`); weight by `n_tests` rather than averaging `value`. `taxon_id` is the pathogen name, not a NEON taxon code. This dataset has no zero rows: a rate of 0 means the pathogen was tested and not detected.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id (named location).
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier.
#' - `unique_sample_id`: Identity of unique samples (`namedLocation_collectDate`).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Pathogen name (standardized).
#' - `taxon_name`: Pathogen name (same as `taxon_id`).
#' - `taxon_rank`: Taxonomic rank inferred from name (`"genus"` for sp./spp. names, otherwise `"species"`).
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Positivity rate (`n_positive_test / n_tests`).
#' - `unit`: Unit of the values in the `value` column (`"positive tests per pathogen per sampling event"`).
#' - `vector_taxon_id`: NEON taxon code of the tested tick (e.g. `IXOSCA` = Ixodes scapularis, `AMBAME` = Amblyomma americanum, `HAELON` = Haemaphysalis longicornis).
#' - `lifeStage`: Life stage of the host tick (`N` = nymph, `L` = larva; extracted from `subsampleID`).
#' - `testProtocolVersion`: The protocol version used to test the sample.
#' - `release`: Version of data release by NEON.
#' - `n_tests`: Number of tests conducted.
#' - `n_positive_test`: Number of tests that were positive.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#'
#' @author Melissa Chen, Wynne Moss, Brendan Hobart, Matt Bitters
#'
"data_tick_pathogen"
