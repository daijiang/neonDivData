
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
# install.packages("devtools")
devtools::install_github("daijiang/neonDivData")
```

## Available data products

``` r
neonDivData::neon_sites
#> # A tibble: 81 × 10
#>    `Site Name`            siteID `Domain Name` domainID State Latitude Longitude
#>    <chr>                  <chr>  <chr>         <chr>    <chr>    <dbl>     <dbl>
#>  1 Little Rock Lake       LIRO   Great Lakes   D05      WI        46.0     -89.7
#>  2 West St Louis Creek    WLOU   Southern Roc… D13      CO        39.9    -106. 
#>  3 Pu'u Maka'ala Natural… PUUM   Pacific Trop… D20      HI        19.6    -155. 
#>  4 Flint River            FLNT   Southeast     D03      GA        31.2     -84.4
#>  5 McDiffett Creek        MCDI   Prairie Peni… D06      KS        38.9     -96.4
#>  6 Lewis Run              LEWI   Mid-Atlantic  D02      VA        39.1     -78.0
#>  7 Blue River             BLUE   Southern Pla… D11      OK        34.4     -96.6
#>  8 Teakettle 2 Creek      TECR   Pacific Sout… D17      CA        37.0    -119. 
#>  9 Lower Hop Brook        HOPB   Northeast     D01      MA        42.5     -72.3
#> 10 Martha Creek           MART   Pacific Nort… D16      WA        45.8    -122. 
#> # … with 71 more rows, and 3 more variables: `Site Type` <chr>,
#> #   `Site Subtype` <chr>, `Site Host` <chr>
neonDivData::neon_taxa
#> # A tibble: 12,312 × 4
#>    taxon_id       taxon_name                              taxon_rank taxon_group
#>    <chr>          <chr>                                   <chr>      <chr>      
#>  1 NEONDREX48008  Nitzschia dissipata (Kützing) Grunow    species    ALGAE      
#>  2 NEONDREX33183  Eunotia minor (Kützing) Grunow          species    ALGAE      
#>  3 NEONDREX186008 Psammothidium subatomoides (Hustedt) B… species    ALGAE      
#>  4 NEONDREX1032   Achnanthidium latecephalum Kobayashi    species    ALGAE      
#>  5 NEONDREX37311  Gomphonema parvulius (Lange-Bertalot e… species    ALGAE      
#>  6 NEONDREX155017 Planothidium frequentissimum (Lange-Be… species    ALGAE      
#>  7 NEONDREX62008  Stauroneis kriegeri Patrick             species    ALGAE      
#>  8 NEONDREX172006 Staurosira construens var. venter (Ehr… variety    ALGAE      
#>  9 NEONDREX1036   Achnanthidium rivulare Potapova et Pon… species    ALGAE      
#> 10 NEONDREX48025  Nitzschia palea (Kützing) Smith         species    ALGAE      
#> # … with 12,302 more rows
neonDivData::neon_location
#> # A tibble: 4,259 × 8
#>    location_id             siteID plotID  latitude longitude elevation nlcdClass
#>    <chr>                   <chr>  <chr>      <dbl>     <dbl>     <dbl> <chr>    
#>  1 ABBY_001.basePlot.brd   ABBY   ABBY_0…     45.8     -122.      303. evergree…
#>  2 ABBY_001.basePlot.div   ABBY   ABBY_0…     45.8     -122.      303. evergree…
#>  3 ABBY_001.tickPlot.tck   ABBY   ABBY_0…     45.8     -122.      298. evergree…
#>  4 ABBY_002.basePlot.bet   ABBY   ABBY_0…     45.7     -122.      638. grasslan…
#>  5 ABBY_002.basePlot.brd   ABBY   ABBY_0…     45.7     -122.      638. grasslan…
#>  6 ABBY_002.basePlot.div   ABBY   ABBY_0…     45.7     -122.      638. grasslan…
#>  7 ABBY_002.mammalGrid.mam ABBY   ABBY_0…     45.7     -122.      624. grasslan…
#>  8 ABBY_002.tickPlot.tck   ABBY   ABBY_0…     45.7     -122.      651. grasslan…
#>  9 ABBY_003.basePlot.bet   ABBY   ABBY_0…     45.8     -122.      602. evergree…
#> 10 ABBY_003.basePlot.brd   ABBY   ABBY_0…     45.8     -122.      602. evergree…
#> # … with 4,249 more rows, and 1 more variable: aquaticSiteType <chr>
neonDivData::data_algae
#> # A tibble: 114,340 × 25
#>    location_id   siteID unique_sample_id observation_dateti… taxon_id taxon_name
#>    <chr>         <chr>  <chr>            <dttm>              <chr>    <chr>     
#>  1 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Nitzschia…
#>  2 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Eunotia m…
#>  3 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Psammothi…
#>  4 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Achnanthi…
#>  5 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Gomphonem…
#>  6 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Planothid…
#>  7 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Stauronei…
#>  8 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Staurosir…
#>  9 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Achnanthi…
#> 10 HOPB.AOS.rea… HOPB   HOPB.20161005.E… 2016-10-05 10:45:00 NEONDRE… Nitzschia…
#> # … with 114,330 more rows, and 19 more variables: taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, sampleCondition <chr>,
#> #   perBottleSampleVolume <chr>, release <chr>, habitatType <chr>,
#> #   algalSampleType <chr>, benthicArea <chr>, samplingProtocolVersion <chr>,
#> #   substratumSizeClass <chr>, samplerType <chr>, phytoDepth1 <chr>,
#> #   phytoDepth2 <chr>, phytoDepth3 <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
neonDivData::data_beetle
#> # A tibble: 71,660 × 22
#>    location_id         siteID plotID unique_sample_id trapID observation_dateti…
#>    <chr>               <chr>  <chr>  <chr>            <chr>  <dttm>             
#>  1 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2016… E      2016-09-13 00:00:00
#>  2 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2016… E      2016-09-13 00:00:00
#>  3 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2016… E      2016-09-27 00:00:00
#>  4 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2017… E      2017-05-17 00:00:00
#>  5 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2017… E      2017-05-31 00:00:00
#>  6 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2017… E      2017-05-31 00:00:00
#>  7 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2017… E      2017-06-14 00:00:00
#>  8 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2017… E      2017-06-14 00:00:00
#>  9 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2017… E      2017-06-28 00:00:00
#> 10 ABBY_002.basePlot.… ABBY   ABBY_… ABBY_002.E.2018… E      2018-05-01 00:00:00
#> # … with 71,650 more rows, and 16 more variables: taxon_id <chr>,
#> #   taxon_name <chr>, taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, boutID <chr>, nativeStatusCode <chr>, release <chr>,
#> #   remarks <chr>, samplingProtocolVersion <chr>, trappingDays <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, nlcdClass <chr>
neonDivData::data_bird
#> # A tibble: 226,804 × 35
#>    location_id        siteID plotID pointID unique_sample_id observation_dateti…
#>    <chr>              <chr>  <chr>  <list>  <chr>            <dttm>             
#>  1 BART_025.birdGrid… BART   BART_… <chr>   BART_025.C1.201… 2015-06-14 09:23:00
#>  2 BART_025.birdGrid… BART   BART_… <chr>   BART_025.C1.201… 2015-06-14 09:23:00
#>  3 BART_025.birdGrid… BART   BART_… <chr>   BART_025.C1.201… 2015-06-14 09:23:00
#>  4 BART_025.birdGrid… BART   BART_… <chr>   BART_025.C1.201… 2015-06-14 09:23:00
#>  5 BART_025.birdGrid… BART   BART_… <chr>   BART_025.C1.201… 2015-06-14 09:23:00
#>  6 BART_025.birdGrid… BART   BART_… <chr>   BART_025.B1.201… 2015-06-14 09:43:00
#>  7 BART_025.birdGrid… BART   BART_… <chr>   BART_025.B1.201… 2015-06-14 09:43:00
#>  8 BART_025.birdGrid… BART   BART_… <chr>   BART_025.B1.201… 2015-06-14 09:43:00
#>  9 BART_025.birdGrid… BART   BART_… <chr>   BART_025.B1.201… 2015-06-14 09:43:00
#> 10 BART_025.birdGrid… BART   BART_… <chr>   BART_025.A1.201… 2015-06-14 10:31:00
#> # … with 226,794 more rows, and 29 more variables: taxon_id <chr>,
#> #   taxon_name <chr>, taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, pointCountMinute <list>, targetTaxaPresent <list>,
#> #   nativeStatusCode <list>, observerDistance <list>, detectionMethod <list>,
#> #   visualConfirmation <list>, sexOrAge <list>, release <list>,
#> #   startCloudCoverPercentage <list>, endCloudCoverPercentage <list>,
#> #   startRH <list>, endRH <list>, observedHabitat <list>, …
neonDivData::data_fish
#> # A tibble: 6,639 × 29
#>    location_id      siteID pointID unique_sample_id observation_dateti… taxon_id
#>    <chr>            <chr>  <chr>   <chr>            <dttm>              <chr>   
#>  1 HOPB.AOS.fish.p… HOPB   point.… HOPB.20170501.0… 2017-05-01 00:00:00 RHIATR  
#>  2 HOPB.AOS.fish.p… HOPB   point.… HOPB.20170501.0… 2017-05-01 00:00:00 SALTRU  
#>  3 HOPB.AOS.fish.p… HOPB   point.… HOPB.20170501.0… 2017-05-01 00:00:00 SALFON  
#>  4 HOPB.AOS.fish.p… HOPB   point.… HOPB.20171023.0… 2017-10-23 00:00:00 RHIATR  
#>  5 HOPB.AOS.fish.p… HOPB   point.… HOPB.20171023.0… 2017-10-23 00:00:00 SALTRU  
#>  6 HOPB.AOS.fish.p… HOPB   point.… HOPB.20171023.0… 2017-10-23 00:00:00 SALFON  
#>  7 HOPB.AOS.fish.p… HOPB   point.… HOPB.20171023.0… 2017-10-23 00:00:00 SEMATR  
#>  8 HOPB.AOS.fish.p… HOPB   point.… HOPB.20190506.0… 2019-05-06 00:00:00 RHIATR  
#>  9 HOPB.AOS.fish.p… HOPB   point.… HOPB.20190506.0… 2019-05-06 00:00:00 SALFON  
#> 10 HOPB.AOS.fish.p… HOPB   point.… HOPB.20190506.0… 2019-05-06 00:00:00 SEMATR  
#> # … with 6,629 more rows, and 23 more variables: taxon_name <chr>,
#> #   taxon_rank <chr>, variable_name <chr>, value <dbl>, unit <chr>,
#> #   reachID <chr>, samplerType <chr>, fixedRandomReach <chr>,
#> #   measuredReachLength <chr>, efTime <chr>, passStartTime <chr>,
#> #   passEndTime <chr>, mean_efishtime <chr>, release <chr>, netSetTime <chr>,
#> #   netEndTime <chr>, netDeploymentTime <chr>, netLength <chr>, netDepth <chr>,
#> #   efTime2 <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_herp_bycatch
#> # A tibble: 2,732 × 22
#>    location_id         siteID plotID unique_sample_id trapID observation_dateti…
#>    <chr>               <chr>  <chr>  <chr>            <chr>  <dttm>             
#>  1 BART_066.basePlot.… BART   BART_… BART_066.E.2014… E      2014-06-12 00:00:00
#>  2 BART_002.basePlot.… BART   BART_… BART_002.W.2014… W      2014-06-12 00:00:00
#>  3 BART_028.basePlot.… BART   BART_… BART_028.W.2014… W      2014-06-12 00:00:00
#>  4 BART_066.basePlot.… BART   BART_… BART_066.N.2014… N      2014-06-26 00:00:00
#>  5 BART_031.basePlot.… BART   BART_… BART_031.E.2014… E      2014-06-26 00:00:00
#>  6 BART_068.basePlot.… BART   BART_… BART_068.W.2014… W      2014-06-26 00:00:00
#>  7 BART_028.basePlot.… BART   BART_… BART_028.N.2014… N      2014-07-10 00:00:00
#>  8 BART_002.basePlot.… BART   BART_… BART_002.N.2014… N      2014-07-10 00:00:00
#>  9 BART_031.basePlot.… BART   BART_… BART_031.S.2014… S      2014-07-10 00:00:00
#> 10 BART_068.basePlot.… BART   BART_… BART_068.E.2014… E      2014-07-24 00:00:00
#> # … with 2,722 more rows, and 16 more variables: taxon_id <chr>,
#> #   taxon_name <chr>, taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, trappingDays <chr>, release <chr>, nativeStatusCode <chr>,
#> #   remarksSorting <chr>, remarksFielddata <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>, plotType <chr>, nlcdClass <chr>
neonDivData::data_macroinvertebrate
#> # A tibble: 106,641 × 25
#>    location_id   siteID unique_sample_id observation_dateti… taxon_id taxon_name
#>    <chr>         <chr>  <chr>            <dttm>              <chr>    <chr>     
#>  1 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 ABLSP    Ablabesmy…
#>  2 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 BAESP    Baetidae …
#>  3 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 CAESP5   Caenis sp.
#>  4 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 CALFLU   Callibaet…
#>  5 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 CERSP18  Ceratopog…
#>  6 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 CHISP2   Chironomi…
#>  7 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 CHISP8   Chironomu…
#>  8 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 CLISP3   Clinotany…
#>  9 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 COESP    Coenagrio…
#> 10 ARIK.AOS.rea… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00 CORSP4   Corixidae…
#> # … with 106,631 more rows, and 19 more variables: taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, estimatedTotalCount <chr>,
#> #   individualCount <chr>, subsamplePercent <chr>, release <chr>,
#> #   benthicArea <chr>, habitatType <chr>, samplerType <chr>,
#> #   substratumSizeClass <chr>, remarks <chr>, ponarDepth <dbl>,
#> #   snagLength <dbl>, snagDiameter <dbl>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
neonDivData::data_mosquito
#> # A tibble: 109,212 × 26
#>    location_id     siteID unique_sample_id subsampleID observation_dat… taxon_id
#>    <chr>           <chr>  <chr>            <chr>       <date>           <chr>   
#>  1 BART_059.mosqu… BART   BART_059.201406… BART_059.2… 2014-06-03       AEDCOM  
#>  2 BART_059.mosqu… BART   BART_059.201406… BART_059.2… 2014-06-03       AEDABS  
#>  3 BART_059.mosqu… BART   BART_059.201406… BART_059.2… 2014-06-03       AEDINT  
#>  4 BART_058.mosqu… BART   BART_058.201406… BART_058.2… 2014-06-03       AEDINT  
#>  5 BART_058.mosqu… BART   BART_058.201406… BART_058.2… 2014-06-03       AEDCOM  
#>  6 BART_060.mosqu… BART   BART_060.201406… BART_060.2… 2014-06-03       AEDCOM  
#>  7 BART_060.mosqu… BART   BART_060.201406… BART_060.2… 2014-06-03       AEDABS  
#>  8 BART_060.mosqu… BART   BART_060.201406… BART_060.2… 2014-06-03       AEDINT  
#>  9 BART_054.mosqu… BART   BART_054.201406… BART_054.2… 2014-06-03       AEDCOM  
#> 10 BART_054.mosqu… BART   BART_054.201406… BART_054.2… 2014-06-03       AEDINT  
#> # … with 109,202 more rows, and 20 more variables: taxon_name <chr>,
#> #   taxon_rank <chr>, variable_name <chr>, value <dbl>, unit <chr>,
#> #   nativeStatusCode <chr>, release <chr>, remarks_sorting <chr>,
#> #   samplingProtocolVersion <chr>, sex <chr>, sortDate <chr>,
#> #   subsampleWeight <chr>, totalWeight <chr>, trapHours <chr>,
#> #   weightBelowDetection <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>, nlcdClass <chr>, plotType <chr>
neonDivData::data_plant
#> # A tibble: 1,034,093 × 26
#>    location_id siteID plotID unique_sample_id subplotID subplot_id subsubplot_id
#>    <chr>       <chr>  <chr>  <chr>            <chr>     <chr>      <chr>        
#>  1 BART_006.b… BART   BART_… BART_006.basePl… 31.4.1    31         4            
#>  2 BART_006.b… BART   BART_… BART_006.basePl… 31.4.1    31         4            
#>  3 BART_006.b… BART   BART_… BART_006.basePl… 41.1.1    41         1            
#>  4 BART_006.b… BART   BART_… BART_006.basePl… 41.4.1    41         4            
#>  5 BART_006.b… BART   BART_… BART_006.basePl… 41.4.1    41         4            
#>  6 BART_006.b… BART   BART_… BART_006.basePl… 41.4.1    41         4            
#>  7 BART_006.b… BART   BART_… BART_006.basePl… 32.2.1    32         2            
#>  8 BART_006.b… BART   BART_… BART_006.basePl… 41.1.1    41         1            
#>  9 BART_006.b… BART   BART_… BART_006.basePl… 32.4.1    32         4            
#> 10 BART_006.b… BART   BART_… BART_006.basePl… 32.4.1    32         4            
#> # … with 1,034,083 more rows, and 19 more variables:
#> #   observation_datetime <dttm>, taxon_id <chr>, taxon_name <chr>,
#> #   taxon_rank <chr>, variable_name <chr>, value <dbl>, unit <chr>,
#> #   presence_absence <dbl>, boutNumber <chr>, nativeStatusCode <chr>,
#> #   heightPlantOver300cm <chr>, heightPlantSpecies <chr>, release <chr>,
#> #   sample_area_m2 <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>,
#> #   plotType <chr>, nlcdClass <chr>
neonDivData::data_small_mammal
#> # A tibble: 17,279 × 22
#>    location_id          siteID plotID unique_sample_id observation_dat… taxon_id
#>    <chr>                <chr>  <chr>  <chr>            <date>           <chr>   
#>  1 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2016-08-27       MIOR    
#>  2 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2016-08-27       PEKE    
#>  3 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2016-08-27       PEMA    
#>  4 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2016-08-27       SOMO    
#>  5 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23       MIOR    
#>  6 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23       PEMA    
#>  7 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23       SOMO    
#>  8 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23       SOSP    
#>  9 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23       SOTR    
#> 10 ABBY_002.mammalGrid… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23       SOVA    
#> # … with 17,269 more rows, and 16 more variables: taxon_name <chr>,
#> #   taxon_rank <chr>, variable_name <chr>, value <dbl>, unit <chr>, year <chr>,
#> #   month <chr>, n_trap_nights_per_bout_per_plot <chr>,
#> #   n_nights_per_bout <chr>, nativeStatusCode <chr>, release <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, plotType <chr>,
#> #   nlcdClass <chr>
neonDivData::data_tick
#> # A tibble: 357,235 × 22
#>    location_id       siteID plotID unique_sample_id observation_dateti… taxon_id
#>    <chr>             <chr>  <chr>  <chr>            <dttm>              <chr>   
#>  1 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 IXOSP   
#>  2 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 IXOSCA  
#>  3 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 AMBAME  
#>  4 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 AMBSPP  
#>  5 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 IXOSP2  
#>  6 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 IXOANG  
#>  7 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 IXOPAC  
#>  8 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 DERVAR  
#>  9 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 IXOSCA  
#> 10 ABBY_001.tickPlo… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00 AMBAME  
#> # … with 357,225 more rows, and 16 more variables: taxon_name <chr>,
#> #   taxon_rank <chr>, variable_name <chr>, value <dbl>, unit <chr>,
#> #   LifeStage <chr>, release <chr>, remarks_field <chr>, samplingMethod <chr>,
#> #   targetTaxaPresent <chr>, totalSampledArea <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>, nlcdClass <chr>, plotType <chr>
neonDivData::data_tick_pathogen
#> # A tibble: 8,490 × 21
#>    location_id       siteID plotID unique_sample_id observation_dateti… taxon_id
#>    <chr>             <chr>  <chr>  <chr>            <dttm>              <chr>   
#>  1 HARV_001.tickPlo… HARV   HARV_… HARV_001.tickPl… 2014-06-02 16:10:00 Borreli…
#>  2 HARV_001.tickPlo… HARV   HARV_… HARV_001.tickPl… 2014-06-24 13:50:00 Borreli…
#>  3 HARV_001.tickPlo… HARV   HARV_… HARV_001.tickPl… 2014-07-14 17:53:00 Borreli…
#>  4 HARV_022.tickPlo… HARV   HARV_… HARV_022.tickPl… 2015-06-03 13:30:00 Anaplas…
#>  5 HARV_022.tickPlo… HARV   HARV_… HARV_022.tickPl… 2015-06-03 13:30:00 Babesia…
#>  6 HARV_022.tickPlo… HARV   HARV_… HARV_022.tickPl… 2015-06-03 13:30:00 Borreli…
#>  7 HARV_022.tickPlo… HARV   HARV_… HARV_022.tickPl… 2015-06-03 13:30:00 Borreli…
#>  8 HARV_022.tickPlo… HARV   HARV_… HARV_022.tickPl… 2015-06-03 13:30:00 Borreli…
#>  9 HARV_022.tickPlo… HARV   HARV_… HARV_022.tickPl… 2015-06-03 13:30:00 Borreli…
#> 10 HARV_022.tickPlo… HARV   HARV_… HARV_022.tickPl… 2015-06-03 13:30:00 Ehrlich…
#> # … with 8,480 more rows, and 15 more variables: taxon_name <chr>,
#> #   taxon_rank <chr>, variable_name <chr>, value <dbl>, unit <chr>,
#> #   lifeStage <chr>, testProtocolVersion <chr>, release <chr>, n_tests <chr>,
#> #   n_positive_tests <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>,
#> #   nlcdClass <chr>, plotType <chr>
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
