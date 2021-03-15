#' Ticks sampled using drag cloths
#'
#' This dataset was derived from [NEON data portal](https://data.neonscience.org) with data product ID 'DP1.10093.001'. Details about this data product can be found at <https://data.neonscience.org/data-products/DP1.10093.001>.
#'
#' Here, we:
#' 1. Removed field samples that had logistical issues (`samplingImpractical`!="OK")
#' 2. Removed field samples that had  were not counted yet (e.g. 2019 data) e.g. require non NA values in `adultCount`, `nymphCount`, and `larvaCount`
#' 3. Removed samples that had field counts but no associated taxonomy record, e.g. ticks were present in the field but there was no associated `sampleID` in the taxonomy (mostly 2019 records that haven't been ID'd yet). Also remove records in the taxonomy table that have no associated field data (`sampleID` present in taxonomy table but not field table). Records removed are mostly legacy.
#' 4. Removed any sample in the taxonomy dataset that did not have a `sampleCondition` of "OK", or has an NA in `identifiedDate` or `acceptedTaxonID`
#' 5. Removed samples in the taxonomy dataset that had `remarks` indicating a mis-identification. This included the following remarks: ("insect", "mite", "not a tick", "NOT A TICK", "arachnid", "spider").
#' 6. Created a `lifeStage` column: this was either Nymph, Larvae, or Adult. Any tick that was sexed (e.g. `sexOrAge` was Male or Female) was assigned to the Adult lifestage. The Nymph or Larvae assignments were taken from the `sexOrAge` column.
#' 7. Widened the taxonomy data so that each column is a unique taxonomicID_lifestage and each row is a sample. In doing so, we dropped the Sex information and summed M and F counts into a total adult count (i.e. we grouped by `sampleID`, `acceptedTaxonID`, and `lifeStage` and summed counts).
#' 8. Left-joined the tick field data to tick taxonomy data using the `sampleID`. This retains 0 counts from the field data which will not have a record in the taxonomy table.
#' 9. For any record where no ticks were found in the field (`targetTaxaPresent`=="N"), assigned 0s to all taxonomicID_lifestage columns.
#' 10. For records where ticks were mis-id'd (see step 5) and there are no tick counts, adjusted the field count to 0.
#' 11. Fixed count discrepancies between field and lab (note that as of 2019 counts may ONLY come from lab so this may not be necessary in future). Note that the lab count was used as the source of final counts per species-lifestage. When discrepancies were minor we trusted the lab counts. When discrepancies were larger, we used the following decisions:
#' 11a. In cases where the field count total was greater than the taxonomic count total AND the discrepancy was in the larval stages, we assumed the lab stopped ID'ing after a certain count. We added the additional, un-ID'd "field" larvae to `IXOSP2_Larva` (the highest taxonomic ID)
#' 11b. In other cases where field count was greater than the taxonomic count and there were `remarks_field` we assumed the remarks were about lost ticks (a common remark). We assigned any un-identified ticks to IXOSP2.
#' 11c. Some counts did not match because there were too many samples sent to the lab and the invoice limit was reached. If the taxonomy table contained remarks about "invoice limit" or "billing limit" for a given sample ID, we trusted the field counts and added any difference between field and lab counts to the IXOSP2 column. *Note this was a conservative decision but one could reasonably assume that counts assigned to IXOSP2 would really belong to whatever lower order taxonomy was commonly ID'd for the remaining samples.*.
#' 11d. Removed any remaining samples where field and lab counts were off by >30% and there was no obvious explanation.
#'
#' @note Details of locations (e.g. latitude/longitude coordinates can be found in [neon_location]).
#'
#' @format A data frame (also a tibble) with the following columns:
#'
#' - `location_id`: Location id.
#' - `siteID`: NEON site code.
#' - `plotID`: Plot identifier (NEON site code_XXX).
#' - `observation_datetime`: Observation date and time.
#' - `taxon_id`: Accepted species code, based on one or more sources.
#' - `taxon_name`:	Scientific name, associated with the taxonID. This is the name
#'  of the lowest level taxonomic rank that can be determined.
#' - `taxon_rank`: The lowest level taxonomic rank that can be determined for the individual or specimen.
#' - `variable_name`: The variable name(s) represented by the `value` column.
#' - `value`: Value of the variable(s) specified by `variable_name`.
#' - `unit`: Unit of the values in the `value` column.
#' - `neon_event_id`: NEON event ID.
#' - `samplingMethod`: Name or code for the method used to collect or test a sample.
#' - `totalSampledArea`: Total area sampled (square Meter).
#' - `targetTaxaPresent`: Indicator of whether the sample contained individuals of the target taxa ('Y' or 'N').
#' - `release`: Version of data release by NEON.
#' - `LifeStage`: Life stage of the sample ('Adult', 'Larva', or 'Nymph').
#' - `remarks_field`: Technician notes; free text comments accompanying the record.
#' - `latitude`: The geographic latitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `longitude`: The geographic longitude (in decimal degrees, WGS84) of the geographic center of the reference area.
#' - `elevation`: Elevation (in meters) above sea level.
#'
#' @author Wynne Moss, Melissa Chen, Brendan Hobart, Matt Bitters
#'
"data_tick"
