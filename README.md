
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonDivData

<!-- badges: start -->
<!-- badges: end -->

The goal of neonDivData is to provide cleaned NEON organismal data to
facilitate biodiversity research. The authors of this R data package
have all spend lots of effort to clean NEON data for our own research;
it makes the most sense to document such processes and provide the clean
data product so that the large community can use them readily. This will
save us time to dig into the extensive documenations of NEON data and to
clean up the data individually.

Data products for all taxonomic groups are long data frames with names
in the format of `data_xxx` (e.g. `data_plant`, `data_fish`). Location
inforamtions are in `neon_location`; taxonomic informations are in
`neon_taxa`.

Despite the aim of this R data package is to facilitate biodiversity
research, we keep `NA`s in data products so that information about
sampling effort is saved. For some taxonomic groups, we removed
observations with above genus level species identification. All codes to
clean up the NEON data are available within our [Github
repo](https://github.com/daijiang/neonDivData/tree/master/data-raw).
Users can use them to customize their own data product if needed.

Available taxonomic groups and their brief summaries:

``` r
# sites too long, don't print
knitr::kable(neonDivData::data_summary[, !names(neonDivData::data_summary) %in% c("sites", "data_package_id")])
```

| taxon_group        | n_taxa | n_sites | start_date | end_date   | data_package_title                                                                          | neon_ecocomdp_mapping_method | original_neon_data_product_id | original_neon_data_version    | original_neon_data_doi                                                       | r_object               | variable_names  | units                                                     |
|:-------------------|-------:|--------:|:-----------|:-----------|:--------------------------------------------------------------------------------------------|:-----------------------------|:------------------------------|:------------------------------|:-----------------------------------------------------------------------------|:-----------------------|:----------------|:----------------------------------------------------------|
| ALGAE              |   2279 |      34 | 2014-07-02 | 2020-07-28 | ALGAE from the NEON data product: Periphyton, seston, and phytoplankton collection          | neon.ecocomdp.20166.001.001  | DP1.20166.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/3cvp-hw55&#124;https://doi.org/10.48443/g2k4-d258> | data_algae             | cell density    | cells/cm2 OR cells/mL                                     |
| SMALL_MAMMALS      |    149 |      46 | 2013-06-19 | 2021-11-18 | SMALL_MAMMALS from the NEON data product: Small mammal box trapping                         | neon.ecocomdp.10072.001.001  | DP1.10072.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/j1g9-2j27&#124;https://doi.org/10.48443/h3dk-3a71> | data_small_mammal      | count           | unique individuals per 100 trap nights per plot per month |
| PLANTS             |   6544 |      47 | 2013-06-24 | 2021-10-13 | PLANTS from the NEON data product: Plant presence and percent cover                         | neon.ecocomdp.10058.001.001  | DP1.10058.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/abge-r811&#124;https://doi.org/10.48443/pr5e-1q60> | data_plant             | percent cover   | percent of plot area covered by taxon                     |
| FISH               |    158 |      28 | 2016-03-29 | 2021-12-14 | FISH from the NEON data product: Fish electrofishing, gill netting, and fyke netting counts | neon.ecocomdp.20107.001.001  | DP1.20107.001                 | RELEASE-2022\|PROVISIONAL\|NA | <https://doi.org/10.48443/17cz-g567&#124;https://doi.org/10.48443/7p84-6j62> | data_fish              | abundance       | catch per unit effort                                     |
| BEETLES            |    768 |      47 | 2013-07-03 | 2021-10-05 | BEETLES from the NEON data product: Ground beetles sampled from pitfall traps               | neon.ecocomdp.10022.001.001  | DP1.10022.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/tx5f-dy17&#124;https://doi.org/10.48443/xgea-hw23> | data_herp_bycatch      | abundance       | count per trap day                                        |
| MACROINVERTEBRATES |   1373 |      34 | 2014-07-01 | 2021-07-28 | MACROINVERTEBRATES from the NEON data product: Macroinvertebrate collection                 | neon.ecocomdp.20120.001.001  | DP1.20120.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/855x-0n27&#124;https://doi.org/10.48443/gn8x-k322> | data_macroinvertebrate | density         | count per square meter                                    |
| MOSQUITOES         |    131 |      47 | 2014-04-09 | 2021-06-11 | MOSQUITOES from the NEON data product: Mosquitoes sampled from CO2 traps                    | neon.ecocomdp.10043.001.001  | DP1.10043.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/9smm-v091&#124;https://doi.org/10.48443/c7h7-q918> | data_mosquito          | abundance       | count per trap hour                                       |
| BIRDS              |    577 |      47 | 2013-06-05 | 2021-07-16 | BIRDS from the NEON data product: Breeding landbird point counts                            | neon.ecocomdp.10003.001.001  | DP1.10003.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/s730-dy13&#124;https://doi.org/10.48443/88sy-ah40> | data_bird              | cluster size    | count of individuals                                      |
| TICKS              |     19 |      46 | 2014-04-02 | 2021-11-18 | TICKS from the NEON data product: Ticks sampled using drag cloths                           | neon.ecocomdp.10093.001.001  | DP1.10093.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/dx40-wr20&#124;https://doi.org/10.48443/7jh5-8s51> | data_tick              | abundance       | count per square meter                                    |
| ZOOPLANKTON        |    166 |       7 | 2014-07-02 | 2021-07-21 | ZOOPLANKTON from the NEON data product: Zooplankton collection                              | neon.ecocomdp.20219.001.001  | DP1.20219.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/qzr1-jr79&#124;https://doi.org/10.48443/150d-yf27> | data_zooplankton       | density         | count per liter                                           |
| TICK_PATHOGENS     |     12 |      16 | 2014-04-17 | 2020-10-01 | TICK_PATHOGENS from the NEON data product: Tick-borne pathogen status                       | neon.ecocomdp.10092.001.001  | DP1.10092.001                 | RELEASE-2022                  | <https://doi.org/10.48443/5fab-xv19&#124;https://doi.org/10.48443/nygx-dm71> | data_tick_pathogen     | positivity rate | positive tests per pathogen per sampling event            |
| HERPTILES          |    136 |      41 | 2014-04-02 | 2021-10-06 | HERPTILES (bycatch) from the NEON data product: Ground beetles sampled from pitfall traps   | neon.ecocomdp.10022.001.002  | DP1.10022.001                 | RELEASE-2022\|PROVISIONAL     | <https://doi.org/10.48443/tx5f-dy17&#124;https://doi.org/10.48443/xgea-hw23> | data_herp_bycatch      | abundance       | count per trap day                                        |

## Installation

You can install the development version of neonDivData from
[Github](https://github.com/daijiang/neonDivData) with:

``` r
install.packages("neonDivData", repos = 'https://daijiang.r-universe.dev')
```

## Available data products

``` r
neonDivData::neon_sites
#> # A tibble: 81 × 10
#>    Site N…¹ siteID Domai…² domai…³ State Latit…⁴ Longi…⁵ Site …⁶ Site …⁷ Site …⁸
#>    <chr>    <chr>  <chr>   <chr>   <chr>   <dbl>   <dbl> <chr>   <chr>   <chr>  
#>  1 Little … LIRO   Great … D05     WI       46.0   -89.7 Reloca… Lake    Wiscon…
#>  2 West St… WLOU   Southe… D13     CO       39.9  -106.  Reloca… Wadeab… U.S. F…
#>  3 Pu'u Ma… PUUM   Pacifi… D20     HI       19.6  -155.  Core T… <NA>    Hawaii…
#>  4 Flint R… FLNT   Southe… D03     GA       31.2   -84.4 Reloca… Non-wa… Privat…
#>  5 McDiffe… MCDI   Prairi… D06     KS       38.9   -96.4 Reloca… Wadeab… Privat…
#>  6 Lewis R… LEWI   Mid-At… D02     VA       39.1   -78.0 Reloca… Wadeab… Casey …
#>  7 Blue Ri… BLUE   Southe… D11     OK       34.4   -96.6 Reloca… Wadeab… The Na…
#>  8 Teakett… TECR   Pacifi… D17     CA       37.0  -119.  Core A… Wadeab… U.S. F…
#>  9 Lower H… HOPB   Northe… D01     MA       42.5   -72.3 Core A… Wadeab… Quabbi…
#> 10 Martha … MART   Pacifi… D16     WA       45.8  -122.  Core A… Wadeab… U.S. F…
#> # … with 71 more rows, and abbreviated variable names ¹​`Site Name`,
#> #   ²​`Domain Name`, ³​domainID, ⁴​Latitude, ⁵​Longitude, ⁶​`Site Type`,
#> #   ⁷​`Site Subtype`, ⁸​`Site Host`
neonDivData::neon_taxa
#> # A tibble: 12,312 × 4
#>    taxon_id       taxon_name                                     taxon…¹ taxon…²
#>    <chr>          <chr>                                          <chr>   <chr>  
#>  1 NEONDREX48008  Nitzschia dissipata (Kützing) Grunow           species ALGAE  
#>  2 NEONDREX33183  Eunotia minor (Kützing) Grunow                 species ALGAE  
#>  3 NEONDREX186008 Psammothidium subatomoides (Hustedt) Bukhtiya… species ALGAE  
#>  4 NEONDREX1032   Achnanthidium latecephalum Kobayashi           species ALGAE  
#>  5 NEONDREX37311  Gomphonema parvulius (Lange-Bertalot et Reich… species ALGAE  
#>  6 NEONDREX155017 Planothidium frequentissimum (Lange-Bertalot)… species ALGAE  
#>  7 NEONDREX62008  Stauroneis kriegeri Patrick                    species ALGAE  
#>  8 NEONDREX172006 Staurosira construens var. venter (Ehrenberg)… variety ALGAE  
#>  9 NEONDREX1036   Achnanthidium rivulare Potapova et Ponader     species ALGAE  
#> 10 NEONDREX48025  Nitzschia palea (Kützing) Smith                species ALGAE  
#> # … with 12,302 more rows, and abbreviated variable names ¹​taxon_rank,
#> #   ²​taxon_group
neonDivData::neon_location
#> # A tibble: 4,259 × 8
#>    location_id             siteID plotID latit…¹ longi…² eleva…³ nlcdC…⁴ aquat…⁵
#>    <chr>                   <chr>  <chr>    <dbl>   <dbl>   <dbl> <chr>   <chr>  
#>  1 ABBY_001.basePlot.brd   ABBY   ABBY_…    45.8   -122.    303. evergr… <NA>   
#>  2 ABBY_001.basePlot.div   ABBY   ABBY_…    45.8   -122.    303. evergr… <NA>   
#>  3 ABBY_001.tickPlot.tck   ABBY   ABBY_…    45.8   -122.    298. evergr… <NA>   
#>  4 ABBY_002.basePlot.bet   ABBY   ABBY_…    45.7   -122.    638. grassl… <NA>   
#>  5 ABBY_002.basePlot.brd   ABBY   ABBY_…    45.7   -122.    638. grassl… <NA>   
#>  6 ABBY_002.basePlot.div   ABBY   ABBY_…    45.7   -122.    638. grassl… <NA>   
#>  7 ABBY_002.mammalGrid.mam ABBY   ABBY_…    45.7   -122.    624. grassl… <NA>   
#>  8 ABBY_002.tickPlot.tck   ABBY   ABBY_…    45.7   -122.    651. grassl… <NA>   
#>  9 ABBY_003.basePlot.bet   ABBY   ABBY_…    45.8   -122.    602. evergr… <NA>   
#> 10 ABBY_003.basePlot.brd   ABBY   ABBY_…    45.8   -122.    602. evergr… <NA>   
#> # … with 4,249 more rows, and abbreviated variable names ¹​latitude, ²​longitude,
#> #   ³​elevation, ⁴​nlcdClass, ⁵​aquaticSiteType
neonDivData::data_algae
#> # A tibble: 114,340 × 25
#>    location…¹ siteID uniqu…² observation_datet…³ taxon…⁴ taxon…⁵ taxon…⁶ varia…⁷
#>    <chr>      <chr>  <chr>   <dttm>              <chr>   <chr>   <chr>   <chr>  
#>  1 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Nitzsc… species cell d…
#>  2 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Eunoti… species cell d…
#>  3 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Psammo… species cell d…
#>  4 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Achnan… species cell d…
#>  5 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Gompho… species cell d…
#>  6 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Planot… species cell d…
#>  7 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Stauro… species cell d…
#>  8 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Stauro… variety cell d…
#>  9 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Achnan… species cell d…
#> 10 HOPB.AOS.… HOPB   HOPB.2… 2016-10-05 10:45:00 NEONDR… Nitzsc… species cell d…
#> # … with 114,330 more rows, 17 more variables: value <dbl>, unit <chr>,
#> #   sampleCondition <chr>, perBottleSampleVolume <chr>, release <chr>,
#> #   habitatType <chr>, algalSampleType <chr>, benthicArea <chr>,
#> #   samplingProtocolVersion <chr>, substratumSizeClass <chr>,
#> #   samplerType <chr>, phytoDepth1 <chr>, phytoDepth2 <chr>, phytoDepth3 <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, and abbreviated variable
#> #   names ¹​location_id, ²​unique_sample_id, ³​observation_datetime, ⁴​taxon_id, …
neonDivData::data_beetle
#> # A tibble: 71,660 × 22
#>    location_id  siteID plotID uniqu…¹ trapID observation_datet…² taxon…³ taxon…⁴
#>    <chr>        <chr>  <chr>  <chr>   <chr>  <dttm>              <chr>   <chr>  
#>  1 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2016-09-13 00:00:00 PTELAM  Pteros…
#>  2 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2016-09-13 00:00:00 SYNAME  Syntom…
#>  3 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2016-09-27 00:00:00 AMAFAR  Amara …
#>  4 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2017-05-17 00:00:00 PTELAM  Pteros…
#>  5 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2017-05-31 00:00:00 OMUDEJ  Omus d…
#>  6 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2017-05-31 00:00:00 PTELAM  Pteros…
#>  7 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2017-06-14 00:00:00 OMUDEJ  Omus d…
#>  8 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2017-06-14 00:00:00 SYNAME  Syntom…
#>  9 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2017-06-28 00:00:00 HARINN  Harpal…
#> 10 ABBY_002.ba… ABBY   ABBY_… ABBY_0… E      2018-05-01 00:00:00 PTELAM  Pteros…
#> # … with 71,650 more rows, 14 more variables: taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, boutID <chr>,
#> #   nativeStatusCode <chr>, release <chr>, remarks <chr>,
#> #   samplingProtocolVersion <chr>, trappingDays <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>, nlcdClass <chr>, and abbreviated variable
#> #   names ¹​unique_sample_id, ²​observation_datetime, ³​taxon_id, ⁴​taxon_name
neonDivData::data_bird
#> # A tibble: 226,826 × 35
#>    location_id siteID plotID pointID uniqu…¹ observation_datet…² taxon…³ taxon…⁴
#>    <chr>       <chr>  <chr>  <chr>   <chr>   <dttm>              <chr>   <chr>  
#>  1 BART_025.b… BART   BART_… C1      BART_0… 2015-06-14 09:23:00 BCCH    Poecil…
#>  2 BART_025.b… BART   BART_… C1      BART_0… 2015-06-14 09:23:00 REVI    Vireo …
#>  3 BART_025.b… BART   BART_… C1      BART_0… 2015-06-14 09:23:00 BAWW    Mnioti…
#>  4 BART_025.b… BART   BART_… C1      BART_0… 2015-06-14 09:23:00 BTNW    Setoph…
#>  5 BART_025.b… BART   BART_… C1      BART_0… 2015-06-14 09:23:00 BTNW    Setoph…
#>  6 BART_025.b… BART   BART_… B1      BART_0… 2015-06-14 09:43:00 WIWR    Troglo…
#>  7 BART_025.b… BART   BART_… B1      BART_0… 2015-06-14 09:43:00 BAWW    Mnioti…
#>  8 BART_025.b… BART   BART_… B1      BART_0… 2015-06-14 09:43:00 WIWR    Troglo…
#>  9 BART_025.b… BART   BART_… B1      BART_0… 2015-06-14 09:43:00 BTNW    Setoph…
#> 10 BART_025.b… BART   BART_… A1      BART_0… 2015-06-14 10:31:00 REVI    Vireo …
#> # … with 226,816 more rows, 27 more variables: taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, pointCountMinute <chr>,
#> #   targetTaxaPresent <chr>, nativeStatusCode <chr>, observerDistance <chr>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   release <chr>, startCloudCoverPercentage <chr>,
#> #   endCloudCoverPercentage <chr>, startRH <chr>, endRH <chr>,
#> #   observedHabitat <chr>, observedAirTemp <chr>, …
neonDivData::data_fish
#> # A tibble: 6,639 × 29
#>    location…¹ siteID pointID uniqu…² observation_datet…³ taxon…⁴ taxon…⁵ taxon…⁶
#>    <chr>      <chr>  <chr>   <chr>   <dttm>              <chr>   <chr>   <chr>  
#>  1 HOPB.AOS.… HOPB   point.… HOPB.2… 2017-05-01 00:00:00 RHIATR  Rhinic… species
#>  2 HOPB.AOS.… HOPB   point.… HOPB.2… 2017-05-01 00:00:00 SALTRU  Salmo … species
#>  3 HOPB.AOS.… HOPB   point.… HOPB.2… 2017-05-01 00:00:00 SALFON  Salvel… species
#>  4 HOPB.AOS.… HOPB   point.… HOPB.2… 2017-10-23 00:00:00 RHIATR  Rhinic… species
#>  5 HOPB.AOS.… HOPB   point.… HOPB.2… 2017-10-23 00:00:00 SALTRU  Salmo … species
#>  6 HOPB.AOS.… HOPB   point.… HOPB.2… 2017-10-23 00:00:00 SALFON  Salvel… species
#>  7 HOPB.AOS.… HOPB   point.… HOPB.2… 2017-10-23 00:00:00 SEMATR  Semoti… species
#>  8 HOPB.AOS.… HOPB   point.… HOPB.2… 2019-05-06 00:00:00 RHIATR  Rhinic… species
#>  9 HOPB.AOS.… HOPB   point.… HOPB.2… 2019-05-06 00:00:00 SALFON  Salvel… species
#> 10 HOPB.AOS.… HOPB   point.… HOPB.2… 2019-05-06 00:00:00 SEMATR  Semoti… species
#> # … with 6,629 more rows, 21 more variables: variable_name <chr>, value <dbl>,
#> #   unit <chr>, reachID <chr>, samplerType <chr>, fixedRandomReach <chr>,
#> #   measuredReachLength <chr>, efTime <chr>, passStartTime <chr>,
#> #   passEndTime <chr>, mean_efishtime <chr>, release <chr>, netSetTime <chr>,
#> #   netEndTime <chr>, netDeploymentTime <chr>, netLength <chr>, netDepth <chr>,
#> #   efTime2 <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>, and
#> #   abbreviated variable names ¹​location_id, ²​unique_sample_id, …
neonDivData::data_herp_bycatch
#> # A tibble: 2,732 × 22
#>    location_id  siteID plotID uniqu…¹ trapID observation_datet…² taxon…³ taxon…⁴
#>    <chr>        <chr>  <chr>  <chr>   <chr>  <dttm>              <chr>   <chr>  
#>  1 BART_066.ba… BART   BART_… BART_0… E      2014-06-12 00:00:00 PLECIN  Pletho…
#>  2 BART_002.ba… BART   BART_… BART_0… W      2014-06-12 00:00:00 PLECIN  Pletho…
#>  3 BART_028.ba… BART   BART_… BART_0… W      2014-06-12 00:00:00 PLECIN  Pletho…
#>  4 BART_066.ba… BART   BART_… BART_0… N      2014-06-26 00:00:00 PLECIN  Pletho…
#>  5 BART_031.ba… BART   BART_… BART_0… E      2014-06-26 00:00:00 PLECIN  Pletho…
#>  6 BART_068.ba… BART   BART_… BART_0… W      2014-06-26 00:00:00 PLECIN  Pletho…
#>  7 BART_028.ba… BART   BART_… BART_0… N      2014-07-10 00:00:00 PLECIN  Pletho…
#>  8 BART_002.ba… BART   BART_… BART_0… N      2014-07-10 00:00:00 PLECIN  Pletho…
#>  9 BART_031.ba… BART   BART_… BART_0… S      2014-07-10 00:00:00 PLECIN  Pletho…
#> 10 BART_068.ba… BART   BART_… BART_0… E      2014-07-24 00:00:00 PLECIN  Pletho…
#> # … with 2,722 more rows, 14 more variables: taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, trappingDays <chr>,
#> #   release <chr>, nativeStatusCode <chr>, remarksSorting <chr>,
#> #   remarksFielddata <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>,
#> #   plotType <chr>, nlcdClass <chr>, and abbreviated variable names
#> #   ¹​unique_sample_id, ²​observation_datetime, ³​taxon_id, ⁴​taxon_name
neonDivData::data_macroinvertebrate
#> # A tibble: 106,641 × 25
#>    location…¹ siteID uniqu…² observation_datet…³ taxon…⁴ taxon…⁵ taxon…⁶ varia…⁷
#>    <chr>      <chr>  <chr>   <dttm>              <chr>   <chr>   <chr>   <chr>  
#>  1 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 ABLSP   Ablabe… genus   density
#>  2 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 BAESP   Baetid… family  density
#>  3 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 CAESP5  Caenis… genus   density
#>  4 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 CALFLU  Callib… species density
#>  5 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 CERSP18 Cerato… genus   density
#>  6 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 CHISP2  Chiron… family  density
#>  7 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 CHISP8  Chiron… genus   density
#>  8 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 CLISP3  Clinot… genus   density
#>  9 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 COESP   Coenag… family  density
#> 10 ARIK.AOS.… ARIK   ARIK.2… 2014-07-14 17:51:00 CORSP4  Corixi… family  density
#> # … with 106,631 more rows, 17 more variables: value <dbl>, unit <chr>,
#> #   estimatedTotalCount <chr>, individualCount <chr>, subsamplePercent <chr>,
#> #   release <chr>, benthicArea <chr>, habitatType <chr>, samplerType <chr>,
#> #   substratumSizeClass <chr>, remarks <chr>, ponarDepth <dbl>,
#> #   snagLength <dbl>, snagDiameter <dbl>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>, and abbreviated variable names ¹​location_id,
#> #   ²​unique_sample_id, ³​observation_datetime, ⁴​taxon_id, ⁵​taxon_name, …
neonDivData::data_mosquito
#> # A tibble: 109,212 × 26
#>    location_id siteID uniqu…¹ subsa…² observat…³ taxon…⁴ taxon…⁵ taxon…⁶ varia…⁷
#>    <chr>       <chr>  <chr>   <chr>   <date>     <chr>   <chr>   <chr>   <chr>  
#>  1 BART_059.m… BART   BART_0… BART_0… 2014-06-03 AEDCOM  Aedes … species abunda…
#>  2 BART_059.m… BART   BART_0… BART_0… 2014-06-03 AEDABS  Aedes … species abunda…
#>  3 BART_059.m… BART   BART_0… BART_0… 2014-06-03 AEDINT  Aedes … species abunda…
#>  4 BART_058.m… BART   BART_0… BART_0… 2014-06-03 AEDINT  Aedes … species abunda…
#>  5 BART_058.m… BART   BART_0… BART_0… 2014-06-03 AEDCOM  Aedes … species abunda…
#>  6 BART_060.m… BART   BART_0… BART_0… 2014-06-03 AEDCOM  Aedes … species abunda…
#>  7 BART_060.m… BART   BART_0… BART_0… 2014-06-03 AEDABS  Aedes … species abunda…
#>  8 BART_060.m… BART   BART_0… BART_0… 2014-06-03 AEDINT  Aedes … species abunda…
#>  9 BART_054.m… BART   BART_0… BART_0… 2014-06-03 AEDCOM  Aedes … species abunda…
#> 10 BART_054.m… BART   BART_0… BART_0… 2014-06-03 AEDINT  Aedes … species abunda…
#> # … with 109,202 more rows, 17 more variables: value <dbl>, unit <chr>,
#> #   nativeStatusCode <chr>, release <chr>, remarks_sorting <chr>,
#> #   samplingProtocolVersion <chr>, sex <chr>, sortDate <chr>,
#> #   subsampleWeight <chr>, totalWeight <chr>, trapHours <chr>,
#> #   weightBelowDetection <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>, nlcdClass <chr>, plotType <chr>, and abbreviated variable
#> #   names ¹​unique_sample_id, ²​subsampleID, ³​observation_datetime, ⁴​taxon_id, …
neonDivData::data_plant
#> # A tibble: 1,034,093 × 26
#>    location_id siteID plotID uniqu…¹ subpl…² subpl…³ subsu…⁴ observation_datet…⁵
#>    <chr>       <chr>  <chr>  <chr>   <chr>   <chr>   <chr>   <dttm>             
#>  1 BART_006.b… BART   BART_… BART_0… 31.4.1  31      4       2014-06-10 00:00:00
#>  2 BART_006.b… BART   BART_… BART_0… 31.4.1  31      4       2014-06-10 00:00:00
#>  3 BART_006.b… BART   BART_… BART_0… 41.1.1  41      1       2014-06-10 00:00:00
#>  4 BART_006.b… BART   BART_… BART_0… 41.4.1  41      4       2014-06-10 00:00:00
#>  5 BART_006.b… BART   BART_… BART_0… 41.4.1  41      4       2014-06-10 00:00:00
#>  6 BART_006.b… BART   BART_… BART_0… 41.4.1  41      4       2014-06-10 00:00:00
#>  7 BART_006.b… BART   BART_… BART_0… 32.2.1  32      2       2014-06-10 00:00:00
#>  8 BART_006.b… BART   BART_… BART_0… 41.1.1  41      1       2014-06-10 00:00:00
#>  9 BART_006.b… BART   BART_… BART_0… 32.4.1  32      4       2014-06-10 00:00:00
#> 10 BART_006.b… BART   BART_… BART_0… 32.4.1  32      4       2014-06-10 00:00:00
#> # … with 1,034,083 more rows, 18 more variables: taxon_id <chr>,
#> #   taxon_name <chr>, taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, presence_absence <dbl>, boutNumber <chr>,
#> #   nativeStatusCode <chr>, heightPlantOver300cm <chr>,
#> #   heightPlantSpecies <chr>, release <chr>, sample_area_m2 <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, plotType <chr>,
#> #   nlcdClass <chr>, and abbreviated variable names ¹​unique_sample_id, …
neonDivData::data_small_mammal
#> # A tibble: 17,279 × 22
#>    location_id  siteID plotID uniqu…¹ observat…² taxon…³ taxon…⁴ taxon…⁵ varia…⁶
#>    <chr>        <chr>  <chr>  <chr>   <date>     <chr>   <chr>   <chr>   <chr>  
#>  1 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2016-08-27 MIOR    Microt… species count  
#>  2 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2016-08-27 PEKE    Peromy… species count  
#>  3 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2016-08-27 PEMA    Peromy… species count  
#>  4 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2016-08-27 SOMO    Sorex … species count  
#>  5 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2017-04-23 MIOR    Microt… species count  
#>  6 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2017-04-23 PEMA    Peromy… species count  
#>  7 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2017-04-23 SOMO    Sorex … species count  
#>  8 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2017-04-23 SOSP    Sorex … genus   count  
#>  9 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2017-04-23 SOTR    Sorex … species count  
#> 10 ABBY_002.ma… ABBY   ABBY_… ABBY_0… 2017-04-23 SOVA    Sorex … species count  
#> # … with 17,269 more rows, 13 more variables: value <dbl>, unit <chr>,
#> #   year <chr>, month <chr>, n_trap_nights_per_bout_per_plot <chr>,
#> #   n_nights_per_bout <chr>, nativeStatusCode <chr>, release <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, plotType <chr>,
#> #   nlcdClass <chr>, and abbreviated variable names ¹​unique_sample_id,
#> #   ²​observation_datetime, ³​taxon_id, ⁴​taxon_name, ⁵​taxon_rank, ⁶​variable_name
neonDivData::data_tick
#> # A tibble: 357,235 × 22
#>    location_id siteID plotID uniqu…¹ observation_datet…² taxon…³ taxon…⁴ taxon…⁵
#>    <chr>       <chr>  <chr>  <chr>   <dttm>              <chr>   <chr>   <chr>  
#>  1 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 IXOSP   Ixodid… family 
#>  2 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 IXOSCA  Ixodes… species
#>  3 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 AMBAME  Amblyo… species
#>  4 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 AMBSPP  Amblyo… genus  
#>  5 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 IXOSP2  Ixodid… order  
#>  6 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 IXOANG  Ixodes… species
#>  7 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 IXOPAC  Ixodes… species
#>  8 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 DERVAR  Dermac… species
#>  9 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 IXOSCA  Ixodes… species
#> 10 ABBY_001.t… ABBY   ABBY_… ABBY_0… 2016-09-22 18:12:00 AMBAME  Amblyo… species
#> # … with 357,225 more rows, 14 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, LifeStage <chr>, release <chr>,
#> #   remarks_field <chr>, samplingMethod <chr>, targetTaxaPresent <chr>,
#> #   totalSampledArea <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>,
#> #   nlcdClass <chr>, plotType <chr>, and abbreviated variable names
#> #   ¹​unique_sample_id, ²​observation_datetime, ³​taxon_id, ⁴​taxon_name,
#> #   ⁵​taxon_rank
neonDivData::data_tick_pathogen
#> # A tibble: 8,490 × 21
#>    location_id siteID plotID uniqu…¹ observation_datet…² taxon…³ taxon…⁴ taxon…⁵
#>    <chr>       <chr>  <chr>  <chr>   <dttm>              <chr>   <chr>   <chr>  
#>  1 HARV_001.t… HARV   HARV_… HARV_0… 2014-06-02 16:10:00 Borrel… Borrel… species
#>  2 HARV_001.t… HARV   HARV_… HARV_0… 2014-06-24 13:50:00 Borrel… Borrel… species
#>  3 HARV_001.t… HARV   HARV_… HARV_0… 2014-07-14 17:53:00 Borrel… Borrel… species
#>  4 HARV_022.t… HARV   HARV_… HARV_0… 2015-06-03 13:30:00 Anapla… Anapla… species
#>  5 HARV_022.t… HARV   HARV_… HARV_0… 2015-06-03 13:30:00 Babesi… Babesi… species
#>  6 HARV_022.t… HARV   HARV_… HARV_0… 2015-06-03 13:30:00 Borrel… Borrel… species
#>  7 HARV_022.t… HARV   HARV_… HARV_0… 2015-06-03 13:30:00 Borrel… Borrel… species
#>  8 HARV_022.t… HARV   HARV_… HARV_0… 2015-06-03 13:30:00 Borrel… Borrel… species
#>  9 HARV_022.t… HARV   HARV_… HARV_0… 2015-06-03 13:30:00 Borrel… Borrel… genus  
#> 10 HARV_022.t… HARV   HARV_… HARV_0… 2015-06-03 13:30:00 Ehrlic… Ehrlic… species
#> # … with 8,480 more rows, 13 more variables: variable_name <chr>, value <dbl>,
#> #   unit <chr>, lifeStage <chr>, testProtocolVersion <chr>, release <chr>,
#> #   n_tests <chr>, n_positive_tests <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>, nlcdClass <chr>, plotType <chr>, and abbreviated variable
#> #   names ¹​unique_sample_id, ²​observation_datetime, ³​taxon_id, ⁴​taxon_name,
#> #   ⁵​taxon_rank
```

# Contributing

Contributions are welcome. You can provide comments and feedback or ask
questions by filing an issue on Github
[here](https://github.com/daijiang/neonDivData/issues) or making pull
requests.

# Code of conduct

Please note that the ‘neonDivData’ project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to
this project, you agree to abide by its terms.
