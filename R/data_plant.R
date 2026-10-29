#' Plant survey data collected by NEON
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10058.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10058.001>
#'
#' The detailed design of NEON plant survey can be found in [Barnett et al. 2019](https://esajournals.onlinelibrary.wiley.com/doi/10.1002/ecs2.2603).
#' Here, we:
#'
#' 1. Kept surveyed subplots only (`targetTaxaPresent` of `Y` or `N`; records flagged `samplingImpractical` have no taxa) and removed rows missing plotID, subplotID, eventID, or endDate.
#' 2. Applied morphospecies resolutions from `div_morphospecies` (joined by `siteID` and `morphospeciesID`, NEON user guide sections 3.7 and 3.9), so field morphospecies later identified to genus or species carry the resolved `taxon_id`, `taxon_name`, and `taxon_rank`. Only unambiguous (one-to-one) resolutions were applied. Unresolved morphospecies that share a coarse code (e.g. `2PLANT`) are kept as distinct taxa and can be told apart by `morphospeciesID`.
#' 3. Where a subplot was surveyed on two dates within one sampling event (repeat surveys), kept the first survey. Where the same taxon was recorded twice in one subplot survey, kept the record with the highest percent cover.
#' 4. Removed duplicate taxa between nested subplots (each taxon should be represented once per subplot per event). If a taxon is present in a 1 m² subplot, it is removed from the 10 m² subplot containing it; if present in any nested 1 or 10 m² subplot, it is removed from the 100 m² subplot.
#' 5. Kept taxa identified to genus, speciesGroup, species, subspecies, or variety.
#' 6. Standardized taxon names against the World Checklist of Vascular Plants (WCVP) by joining species-, subspecies-, and variety-level NEON names against a shared plant name base built with the `rWCVP` package (WCVP version recorded in `data-raw/plant_name_lookup.csv`). Specifically:
#'     + The join uses the full NEON name including authorship, because the same name can refer to different taxa depending on its author (homonyms).
#'     + In the name base, raw names are split into canonical name and authorship, matched exactly first and fuzzily only when needed, and synonyms are followed to the WCVP-accepted name. Fuzzy matches whose author contradicts the matched WCVP record, and names whose candidate matches disagree on the accepted taxon, are left unresolved rather than guessed.
#'     + The accepted names are stored in `accepted_wcvp_name` and `accepted_wcvp_name_binomial`; the original NEON name is retained in `taxon_name`.
#'     + Subspecies and varieties are matched as their own taxa, not as their species, even though NEON writes the species author before the rank (e.g. "Circaea lutetiana L. ssp. canadensis (L.) Asch. & Magnus" resolves to *Circaea canadensis*).
#'     + Names with no accepted WCVP name (not in the name base, no match, or unresolved) and genus-level taxa retain their original NEON name, with one exception: autonyms (e.g. "Polygonum scandens L. var. scandens") are the species itself and take the accepted name of their NEON species.
#'     + Subspecies and varieties with no accepted WCVP name take the accepted binomial of their NEON species, so a species is not split between its accepted name and its old NEON name (e.g. *Fallopia scandens* vs *Polygonum scandens*).
#'     + WCVP treats *Taraxacum officinale* as the aggregate "Taraxacum sect. Taraxacum". As in the shared plant name base, these records carry that name in both `accepted_wcvp_name` and `accepted_wcvp_name_binomial`; the original NEON name is kept in `taxon_name`.
#'     + speciesGroup taxa (groups of species that observers could not tell apart, e.g. "Fraxinus americana/pennsylvanica") were assigned to one member species in `accepted_wcvp_name` and `accepted_wcvp_name_binomial`: the first-listed member by default or, if it is not recorded as a species at the same site, the first later-listed member that is. Parts that name only a genus (e.g. "Andropogon L.") are never assigned. These records are flagged with `species_group_assigned = TRUE`; the original NEON name is kept in `taxon_name`.
#' 7. Stacked species occurrence from different scales into a long data frame. A sampling event is identified by `plotID`, `boutNumber`, and the year of `observation_datetime` (or `unique_sample_id`, which combines them with the 100 m² subplot). Always include the event when building sample units, otherwise all years are pooled. Therefore,
#'     + to get the species list at 1 m² scale, we need all the data with `sample_area_m2 == 1` (e.g. `dplyr::filter(plants, sample_area_m2 == 1)`); the sample unit is `unique_sample_id` plus `subsubplot_id` (or `unique_sample_id` plus `subplotID`).
#'     + to get the species list at 10 m² scale, we need all the data with `sample_area_m2 <= 10`; the sample unit is `unique_sample_id` plus `subsubplot_id`.
#'     + to get the species list at 100 m² scale, we need use the whole data set since the maximum value of `sample_area_m2` is 100 (i.e. a 10 m by 10 m subplot); the sample unit is `unique_sample_id`.
#'     + to get the species list at 400 m² scale (i.e. one plot with four subplots), aggregate the data by `plotID`, `boutNumber`, and year.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' **Zero rows.** A 1 m² subplot that was surveyed but contained no plant species is kept as one row with `taxon_id = NA`, `value = 0`, and `presence_absence = 0`. This zero-row convention is shared by all neonDivData observation datasets.
#'
#' **Sampling effort.** Since 2019, the 10 m² and 100 m² scales are surveyed only every other year (and in half of the plots in 2018), while 1 m² subplots are surveyed every year. Use `sampled_scales_m2` to restrict analyses to subplots where all scales were surveyed (`sampled_scales_m2 == "1,10,100"`) before comparing 100 m² or 400 m² species lists among plots or years.
#'
#' **speciesGroup records.** About 0.7% of records are NEON speciesGroup taxa that were assigned to one member species in the WCVP name columns (`species_group_assigned = TRUE`). For most of these, the assigned species is the only member recorded at that site, or both members occur there, so the assignment does not add a spurious species. Use the assigned binomial for community-level analyses (e.g. richness, composition); drop flagged records for species-specific analyses of either member; or collapse them to genus for a conservative richness estimate.
#'
#' **Flags.** `redundant_genus` marks genus-level records that co-occur with a finer identification of the same genus in the same `unique_sample_id`; drop them (`!redundant_genus`) to avoid inflating species richness. `identificationQualifier` (e.g. "cf. species") marks uncertain identifications.
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `unique_sample_id`: Identity of the 100 m² subplot in one sampling event, in the format `location_id_subplot_id_year-boutNumber`.
#' - `subplotID`: This is the NEON provided subplot ID in the format of `subplot_id`, then 1 or 10 (m²), then `subsubplot_id` (e.g. `31_1_1`, `31_10_1`); if the sampling unit is 100 m², the format is `subplot_id_100` (e.g. `31_100`).
#' - `subplot_id`: Subplot ID; each plot normally has four 100 m² subplots (31, 32, 40, 41).
#' - `subsubplot_id`: Subsubplot ID (1, 2, 3, 4) for sampling units at 1 m² or 10 m²; `NA` for 100 m² records.
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources. `NA` for zero rows.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen. Values are 'genus', 'species', 'speciesGroup', 'subspecies', or 'variety'. Species accounts for the majority of the entries. _Higher ranks have already been filtered out_ because we think they are too vague for biodiversity research.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Percent cover for 1 m² records (`0` for zero rows). For 10 m² and 100 m² records the value is `NA` (i.e., _presence only_); a small number of 1 m² records (mostly 2014-2018) also lack a cover estimate.
#' - `unit`: Unit of the values in the `value` column.
#' - `presence_absence`: 1 for records of a taxon; 0 for zero rows.
#' - `boutNumber`: Number of sampling bout, most sites sample only 1 bout.
#' - `nativeStatusCode`: Whether the species is a native or non-native species. 'A': Presumed absent, due to lack of data indicating a taxon's presence in a given location; 'N': Native; 'N?': Probably Native; 'I': Introduced; 'I?': Probably Introduced; 'NI': Native and Introduced, some infrataxa are native and others are introduced; 'NI?': Probably Native and Introduced, some infrataxa are native and others are introduced; 'UNK': Status unknown.
#' - `identificationQualifier`: NEON identification qualifier (e.g. "cf. species", "aff. species"), indicating uncertain identifications.
#' - `morphospeciesID`: Field morphospecies identifier, if the record was first identified as a morphospecies.
#' - `redundant_genus`: `TRUE` for genus-level records that co-occur with a finer identification of the same genus in the same `unique_sample_id`.
#' - `heightPlantOver300cm`: Indicator of whether individuals of the species in the sample are taller than 300 cm.
#' - `heightPlantSpecies`: Ocular estimate of the height (centimeter) of the plant species (if height is < 300 cm).
#' - `sample_area_m2`: The area of the sampling unit that the observed plant was located in. Potential values are 1, 10, or 100.
#' - `sampled_scales_m2`: Nested scales (m²) that were actually surveyed in this 100 m² subplot during this sampling event; the same value is repeated on every row of the subplot-event. Each 100 m² subplot contains two 1 m² quadrats and two 10 m² subplots. Since 2019, NEON surveys the 1 m² quadrats every year but the 10 m² and 100 m² scales only every other year (and in half of the plots in 2018). Values:
#'     + `"1,10,100"`: full survey; the records give the complete species list of the 100 m² subplot.
#'     + `"1"`: only the 1 m² quadrats were surveyed; the records cover about 2 m² of the subplot, so its species list is far from complete (e.g. subplot 31 of HARV_001 has 21-26 species in fully surveyed years but 4-10 in 1 m²-only years).
#'     + Other combinations (e.g. `"1,10"`, `"10,100"`): partial surveys with one scale missing; rare (<1% of subplot-events).
#'
#'   For species lists at 10 m², 100 m², or 400 m² (plot) scale, keep only full surveys, e.g. `dplyr::filter(data_plant, sampled_scales_m2 == "1,10,100")`; otherwise richness appears to drop every other year as a sampling artifact. Analyses at the 1 m² scale (percent cover, quadrat richness) need no filter.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#' - `plotType`: NEON plot type in which sampling occurred: tower, distributed or gradient.
#' - `nlcdClass`: National Land Cover Database Vegetation Type Name.
#' - `release`: Version of data release by NEON.
#' - `accepted_wcvp_name`: WCVP-accepted scientific name (binomial or trinomial, without authors) for species-, subspecies-, and variety-level taxa. For names matched to WCVP synonyms, this is the accepted name; for names with no accepted WCVP name, this falls back to the original NEON `taxon_name` (with authors). Genus-level taxa retain their original NEON names; speciesGroup taxa are assigned to one member species (see `species_group_assigned`).
#' - `accepted_wcvp_name_binomial`: Binomial (genus + specific epithet, without authors) of `accepted_wcvp_name`, or the section name for the *Taraxacum* aggregate (see step 6 above). When `accepted_wcvp_name` has no accepted WCVP name, this falls back to the binomial of the NEON species. Useful for joining with other datasets that use binomial names only.
#' - `species_group_assigned`: `TRUE` for NEON speciesGroup records whose WCVP name columns give one assigned member species rather than a confirmed identification.
#'
#'
#' @source <https://data.neonscience.org>
#' @references Barnett, D.T., Adler, P.B., Chemel, B.R., Duffy, P.A., Enquist, B.J., Grace, J.B., Harrison, S., Peet, R.K., Schimel, D.S., Stohlgren, T.J. and Vellend, M., 2019. The plant diversity sampling design for the national ecological observatory network. Ecosphere, 10(2), p.e02603.
#' @author Daijiang Li, Michael Just
#'
"data_plant"

#' @importFrom tibble tibble
NULL
