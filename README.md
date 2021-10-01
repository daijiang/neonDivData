
<!-- README.md is generated from README.Rmd. Please edit that file -->

# neonDivData

<!-- badges: start -->
<!-- badges: end -->

The goal of neonDivData is to provide cleaned NEON organismal data to
facilitate biodiversity research. The authors of this R data package
have all spent lots of effort to clean NEON data for our own research;
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

| taxon\_group       | n\_taxa | n\_sites | start\_date | end\_date  | data\_package\_title                                                                        | neon\_ecocomdp\_mapping\_method | original\_neon\_data\_product\_id | original\_neon\_data\_version | r\_object               | variable\_names                   | units                                                     |
|:-------------------|--------:|---------:|:------------|:-----------|:--------------------------------------------------------------------------------------------|:--------------------------------|:----------------------------------|:------------------------------|:------------------------|:----------------------------------|:----------------------------------------------------------|
| ALGAE              |    1946 |       33 | 2014-07-02  | 2019-07-15 | ALGAE from the NEON data product: Periphyton, seston, and phytoplankton collection          | neon.ecocomdp.20166.001.001     | DP1.20166.001                     | RELEASE-2021\|PROVISIONAL     | data\_algae             | cell density OR cells OR valves   | cells/cm2 OR cells/mL                                     |
| SMALL\_MAMMALS     |     145 |       46 | 2013-06-19  | 2020-11-20 | SMALL\_MAMMALS from the NEON data product: Small mammal box trapping                        | neon.ecocomdp.10072.001.001     | DP1.10072.001                     | RELEASE-2021\|PROVISIONAL     | data\_small\_mammal     | count                             | unique individuals per 100 trap nights per plot per month |
| PLANTS             |    6197 |       47 | 2013-06-24  | 2020-10-07 | PLANTS from the NEON data product: Plant presence and percent cover                         | neon.ecocomdp.10058.001.001     | DP1.10058.001                     | RELEASE-2021\|PROVISIONAL     | data\_plant             | percent cover OR presence absence | percent of plot area covered by taxon OR Unitless         |
| BEETLES            |     758 |       47 | 2013-07-03  | 2020-10-13 | BEETLES from the NEON data product: Ground beetles sampled from pitfall traps               | neon.ecocomdp.10022.001.001     | DP1.10022.001                     | RELEASE-2021\|PROVISIONAL     | data\_herp\_bycatch     | abundance                         | count per trap day                                        |
| HERPTILES          |     128 |       41 | 2014-04-02  | 2020-09-29 | HERPTILES (bycatch) from the NEON data product: Ground beetles sampled from pitfall traps   | neon.ecocomdp.10022.001.002     | DP1.10022.001                     | RELEASE-2021\|PROVISIONAL     | data\_herp\_bycatch     | abundance                         | count per trap day                                        |
| MACROINVERTEBRATES |    1330 |       34 | 2014-07-01  | 2020-07-29 | MACROINVERTEBRATES from the NEON data product: Macroinvertebrate collection                 | neon.ecocomdp.20120.001.001     | DP1.20120.001                     | RELEASE-2021\|PROVISIONAL     | data\_macroinvertebrate | density                           | count per square meter                                    |
| MOSQUITOES         |     128 |       47 | 2014-04-09  | 2020-06-16 | MOSQUITOES from the NEON data product: Mosquitoes sampled from CO2 traps                    | neon.ecocomdp.10043.001.001     | DP1.10043.001                     | RELEASE-2021\|PROVISIONAL     | data\_mosquito          | abundance                         | count per trap hour                                       |
| BIRDS              |     541 |       47 | 2015-05-13  | 2020-07-20 | BIRDS from the NEON data product: Breeding landbird point counts                            | neon.ecocomdp.10003.001.001     | DP1.10003.001                     | RELEASE-2021\|PROVISIONAL     | data\_bird              | cluster size                      | count of individuals                                      |
| TICKS              |      18 |       41 | 2014-04-17  | 2019-03-18 | TICKS from the NEON data product: Ticks sampled using drag cloths                           | neon.ecocomdp.10093.001.001     | DP1.10093.001                     | RELEASE-2021                  | data\_tick              | abundance                         | count per square meter                                    |
| ZOOPLANKTON        |     157 |        7 | 2014-07-02  | 2020-07-22 | ZOOPLANKTON from the NEON data product: Zooplankton collection                              | neon.ecocomdp.20219.001.001     | DP1.20219.001                     | RELEASE-2021\|PROVISIONAL     | data\_zooplankton       | density                           | count per liter                                           |
| TICK\_PATHOGENS    |      12 |       15 | 2014-04-17  | 2018-10-03 | TICK\_PATHOGENS from the NEON data product: Tick-borne pathogen status                      | neon.ecocomdp.10092.001.001     | DP1.10092.001                     | RELEASE-2021                  | data\_tick\_pathogen    | positivity rate                   | positive tests per pathogen per sampling event            |
| FISH               |     147 |       28 | 2016-03-29  | 2020-12-03 | FISH from the NEON data product: Fish electrofishing, gill netting, and fyke netting counts | neon.ecocomdp.20107.001.001     | DP1.20107.001                     | NA                            | data\_fish              | abundance                         | catch per unit effort                                     |

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
#> # A tibble: 81 x 10
#>    `Site Name` siteID `Domain Name` domainID State Latitude Longitude
#>    <chr>       <chr>  <chr>         <chr>    <chr>    <dbl>     <dbl>
#>  1 Little Roc… LIRO   Great Lakes   D05      WI        46.0     -89.7
#>  2 West St Lo… WLOU   Southern Roc… D13      CO        39.9    -106. 
#>  3 Pu'u Maka'… PUUM   Pacific Trop… D20      HI        19.6    -155. 
#>  4 Flint River FLNT   Southeast     D03      GA        31.2     -84.4
#>  5 McDiffett … MCDI   Prairie Peni… D06      KS        38.9     -96.4
#>  6 Lewis Run   LEWI   Mid-Atlantic  D02      VA        39.1     -78.0
#>  7 Blue River  BLUE   Southern Pla… D11      OK        34.4     -96.6
#>  8 Teakettle … TECR   Pacific Sout… D17      CA        37.0    -119. 
#>  9 Lower Hop … HOPB   Northeast     D01      MA        42.5     -72.3
#> 10 Martha Cre… MART   Pacific Nort… D16      WA        45.8    -122. 
#> # … with 71 more rows, and 3 more variables: `Site Type` <chr>, `Site
#> #   Subtype` <chr>, `Site Host` <chr>
neonDivData::neon_taxa
#> # A tibble: 11,507 x 4
#>    taxon_id     taxon_name                                taxon_rank taxon_group
#>    <chr>        <chr>                                     <chr>      <chr>      
#>  1 NEONDREX850… Heteroleibleinia sp.                      genus      ALGAE      
#>  2 BATRACHOSPF… Batrachospermaceae sp.                    family     ALGAE      
#>  3 NEONDREX550… Reimeria sinuata (Gregory) Kociolek et S… species    ALGAE      
#>  4 NEONDREX330… Eunotia rhomboidea Hustedt                species    ALGAE      
#>  5 NEONDREX1038 Achnanthidium deflexum (Reimer) Kingston  species    ALGAE      
#>  6 NEONDREX1036 Achnanthidium rivulare Potapova et Ponad… species    ALGAE      
#>  7 NEONDREX331… Eunotia muscicola var. tridentula Nörpel… variety    ALGAE      
#>  8 NEONDREX465… Navicula veneta Kützing                   species    ALGAE      
#>  9 NEONDREX483… Nitzschia acidoclinata Lange-Bertalot     species    ALGAE      
#> 10 NEONDREX110… Encyonema ventricosum (C. A. Agardh) Gru… species    ALGAE      
#> # … with 11,497 more rows
neonDivData::neon_location
#> # A tibble: 4,162 x 8
#>    location_id siteID plotID latitude longitude elevation nlcdClass
#>    <chr>       <chr>  <chr>     <dbl>     <dbl>     <dbl> <chr>    
#>  1 ABBY_001.b… ABBY   ABBY_…     45.8     -122.      303. evergree…
#>  2 ABBY_001.b… ABBY   ABBY_…     45.8     -122.      303. evergree…
#>  3 ABBY_001.t… ABBY   ABBY_…     45.8     -122.      298. evergree…
#>  4 ABBY_002.b… ABBY   ABBY_…     45.7     -122.      638. grasslan…
#>  5 ABBY_002.b… ABBY   ABBY_…     45.7     -122.      638. grasslan…
#>  6 ABBY_002.b… ABBY   ABBY_…     45.7     -122.      638. grasslan…
#>  7 ABBY_002.m… ABBY   ABBY_…     45.7     -122.      624. grasslan…
#>  8 ABBY_002.t… ABBY   ABBY_…     45.7     -122.      651. grasslan…
#>  9 ABBY_003.b… ABBY   ABBY_…     45.8     -122.      602. evergree…
#> 10 ABBY_003.b… ABBY   ABBY_…     45.8     -122.      602. evergree…
#> # … with 4,152 more rows, and 1 more variable: aquaticSiteType <chr>
neonDivData::data_algae
#> # A tibble: 90,224 x 24
#>    location_id siteID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Heterolei… genus     
#>  2 HOPB.AOS.r… HOPB   2016-10-05 10:4… BATRACH… Batrachos… family    
#>  3 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Reimeria … species   
#>  4 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Eunotia r… species   
#>  5 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Achnanthi… species   
#>  6 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Achnanthi… species   
#>  7 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Eunotia m… variety   
#>  8 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Navicula … species   
#>  9 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Nitzschia… species   
#> 10 HOPB.AOS.r… HOPB   2016-10-05 10:4… NEONDRE… Encyonema… species   
#> # … with 90,214 more rows, and 18 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, sampleCondition <chr>,
#> #   perBottleSampleVolume <chr>, release <chr>, habitatType <chr>,
#> #   algalSampleType <chr>, benthicArea <chr>, samplingProtocolVersion <chr>,
#> #   substratumSizeClass <chr>, samplerType <chr>, phytoDepth1 <chr>,
#> #   phytoDepth2 <chr>, phytoDepth3 <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
neonDivData::data_beetle
#> # A tibble: 65,605 x 20
#>    location_id siteID plotID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 ABBY_002.b… ABBY   ABBY_… 2016-09-13       PTELAM   Pterostic… species   
#>  2 ABBY_002.b… ABBY   ABBY_… 2016-09-13       SYNAME   Syntomus … species   
#>  3 ABBY_002.b… ABBY   ABBY_… 2016-09-27       AMAFAR   Amara far… species   
#>  4 ABBY_002.b… ABBY   ABBY_… 2017-05-17       PTELAM   Pterostic… species   
#>  5 ABBY_002.b… ABBY   ABBY_… 2017-05-31       OMUDEJ   Omus deje… species   
#>  6 ABBY_002.b… ABBY   ABBY_… 2017-05-31       PTELAM   Pterostic… species   
#>  7 ABBY_002.b… ABBY   ABBY_… 2017-06-14       SYNAME   Syntomus … species   
#>  8 ABBY_002.b… ABBY   ABBY_… 2017-06-14       OMUDEJ   Omus deje… species   
#>  9 ABBY_002.b… ABBY   ABBY_… 2017-06-28       HARINN   Harpalus … species   
#> 10 ABBY_002.b… ABBY   ABBY_… 2018-05-01       NOTSYL   Notiophil… species   
#> # … with 65,595 more rows, and 13 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, boutID <chr>, trapID <chr>, trappingDays <chr>,
#> #   release <chr>, samplingProtocolVersion <chr>, nativeStatusCode <chr>,
#> #   remarks <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_bird
#> # A tibble: 186,431 x 28
#>    location_id siteID plotID pointID observation_dat… taxon_id taxon_name
#>    <chr>       <chr>  <chr>  <chr>   <chr>            <chr>    <chr>     
#>  1 BART_025.b… BART   BART_… C1      2015-06-14 09:2… BAWW     Mniotilta…
#>  2 BART_025.b… BART   BART_… C1      2015-06-14 09:2… REVI     Vireo oli…
#>  3 BART_025.b… BART   BART_… C1      2015-06-14 09:2… BCCH     Poecile a…
#>  4 BART_025.b… BART   BART_… C1      2015-06-14 09:2… BTNW     Setophaga…
#>  5 BART_025.b… BART   BART_… C1      2015-06-14 09:2… BTNW     Setophaga…
#>  6 BART_025.b… BART   BART_… B1      2015-06-14 09:4… WIWR     Troglodyt…
#>  7 BART_025.b… BART   BART_… B1      2015-06-14 09:4… WIWR     Troglodyt…
#>  8 BART_025.b… BART   BART_… B1      2015-06-14 09:4… BAWW     Mniotilta…
#>  9 BART_025.b… BART   BART_… B1      2015-06-14 09:4… BTNW     Setophaga…
#> 10 BART_025.b… BART   BART_… A1      2015-06-14 10:3… WIWR     Troglodyt…
#> # … with 186,421 more rows, and 21 more variables: taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, pointCountMinute <chr>,
#> #   targetTaxaPresent <chr>, nativeStatusCode <chr>, observerDistance <chr>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   release <chr>, observedHabitat <chr>, observedAirTemp <chr>,
#> #   kmPerHourObservedWindSpeed <chr>, samplingProtocolVersion <chr>,
#> #   remarks <chr>, clusterCode <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
neonDivData::data_fish
#> # A tibble: 5,341 x 26
#>    location_id siteID pointID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>   <chr>            <chr>    <chr>      <chr>     
#>  1 HOPB.AOS.f… HOPB   point.… 2017-05-01       RHIATR   Rhinichth… species   
#>  2 HOPB.AOS.f… HOPB   point.… 2017-05-01       SALTRU   Salmo tru… species   
#>  3 HOPB.AOS.f… HOPB   point.… 2017-05-01       SALFON   Salvelinu… species   
#>  4 HOPB.AOS.f… HOPB   point.… 2017-10-23       RHIATR   Rhinichth… species   
#>  5 HOPB.AOS.f… HOPB   point.… 2017-10-23       SALTRU   Salmo tru… species   
#>  6 HOPB.AOS.f… HOPB   point.… 2017-10-23       SALFON   Salvelinu… species   
#>  7 HOPB.AOS.f… HOPB   point.… 2017-10-23       SEMATR   Semotilus… species   
#>  8 HOPB.AOS.f… HOPB   point.… 2019-05-06       RHIATR   Rhinichth… species   
#>  9 HOPB.AOS.f… HOPB   point.… 2019-05-06       SALFON   Salvelinu… species   
#> 10 HOPB.AOS.f… HOPB   point.… 2019-05-06       SEMATR   Semotilus… species   
#> # … with 5,331 more rows, and 19 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, samplerType <chr>, fixedRandomReach <chr>,
#> #   measuredReachLength <chr>, efTime <chr>, passStartTime <chr>,
#> #   passEndTime <chr>, mean_efishtime <chr>, netSetTime <chr>,
#> #   netEndTime <chr>, netDeploymentTime <chr>, netLength <chr>, netDepth <chr>,
#> #   efTime2 <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_herp_bycatch
#> # A tibble: 2,385 x 20
#>    location_id siteID plotID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 BART_028.b… BART   BART_… 2014-06-12       PLECIN   Plethodon… species   
#>  2 BART_002.b… BART   BART_… 2014-06-12       PLECIN   Plethodon… species   
#>  3 BART_066.b… BART   BART_… 2014-06-12       PLECIN   Plethodon… species   
#>  4 BART_031.b… BART   BART_… 2014-06-26       PLECIN   Plethodon… species   
#>  5 BART_066.b… BART   BART_… 2014-06-26       PLECIN   Plethodon… species   
#>  6 BART_068.b… BART   BART_… 2014-06-26       PLECIN   Plethodon… species   
#>  7 BART_031.b… BART   BART_… 2014-07-10       PLECIN   Plethodon… species   
#>  8 BART_002.b… BART   BART_… 2014-07-10       PLECIN   Plethodon… species   
#>  9 BART_028.b… BART   BART_… 2014-07-10       PLECIN   Plethodon… species   
#> 10 BART_028.b… BART   BART_… 2014-07-24       PLECIN   Plethodon… species   
#> # … with 2,375 more rows, and 13 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, neon_event_id <chr>, trappingDays <chr>,
#> #   release <chr>, nativeStatusCode <chr>, neon_trap_id <chr>,
#> #   remarksSorting <chr>, remarksFielddata <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>
neonDivData::data_macroinvertebrate
#> # A tibble: 134,728 x 23
#>    location_id siteID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 HOPB.AOS.r… HOPB   2016-10-11 14:3… STISP4   Stilobezz… genus     
#>  2 HOPB.AOS.r… HOPB   2016-10-11 14:3… EMPSP    Empididae… family    
#>  3 HOPB.AOS.r… HOPB   2016-10-11 14:3… PSEHER   Psephenus… species   
#>  4 HOPB.AOS.r… HOPB   2016-10-11 14:3… LEPSP4   Leptophle… family    
#>  5 HOPB.AOS.r… HOPB   2016-10-11 14:3… CAPSP2   Capniidae… family    
#>  6 HOPB.AOS.r… HOPB   2016-10-11 14:3… THIGRO   Thieneman… speciesGr…
#>  7 HOPB.AOS.r… HOPB   2016-10-11 14:3… NAISP1   Nais sp.   genus     
#>  8 HOPB.AOS.r… HOPB   2016-10-11 14:3… ACESP1   Acerpenna… genus     
#>  9 HOPB.AOS.r… HOPB   2016-10-11 14:3… LEUSP8   Leuctra s… genus     
#> 10 HOPB.AOS.r… HOPB   2016-10-11 14:3… HEPSP    Heptageni… family    
#> # … with 134,718 more rows, and 17 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, subsamplePercent <chr>, release <chr>,
#> #   benthicArea <chr>, habitatType <chr>, samplerType <chr>,
#> #   substratumSizeClass <chr>, neon_sample_id <chr>, remarks <chr>,
#> #   ponarDepth <chr>, snagLength <chr>, snagDiameter <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>
neonDivData::data_mosquito
#> # A tibble: 96,843 x 23
#>    location_id siteID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 BART_059.m… BART   2014-06-03 10:1… AEDABS   Aedes abs… species   
#>  2 BART_059.m… BART   2014-06-03 10:1… AEDCOM   Aedes com… species   
#>  3 BART_059.m… BART   2014-06-03 10:1… AEDINT   Aedes int… species   
#>  4 BART_058.m… BART   2014-06-03 11:1… AEDINT   Aedes int… species   
#>  5 BART_058.m… BART   2014-06-03 11:1… AEDCOM   Aedes com… species   
#>  6 BART_060.m… BART   2014-06-03 11:0… AEDINT   Aedes int… species   
#>  7 BART_060.m… BART   2014-06-03 11:0… AEDABS   Aedes abs… species   
#>  8 BART_060.m… BART   2014-06-03 11:0… AEDCOM   Aedes com… species   
#>  9 BART_054.m… BART   2014-06-03 10:5… AEDCAN2  Aedes can… species   
#> 10 BART_054.m… BART   2014-06-03 10:5… AEDABS   Aedes abs… species   
#> # … with 96,833 more rows, and 17 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, sortDate <chr>, sampleID <chr>, subsampleID <chr>,
#> #   totalWeight <chr>, subsampleWeight <chr>, release <chr>, trapHours <chr>,
#> #   samplingProtocolVersion <chr>, nativeStatusCode <chr>, sex <chr>,
#> #   weightBelowDetection <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
neonDivData::data_plant
#> # A tibble: 915,205 x 23
#>    location_id siteID plotID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 BART_006.b… BART   BART_… 2014-06-10       VILA11   Viburnum … species   
#>  2 BART_006.b… BART   BART_… 2014-06-10       ACSA3    Acer sacc… species   
#>  3 BART_006.b… BART   BART_… 2014-06-10       FAGR     Fagus gra… species   
#>  4 BART_006.b… BART   BART_… 2014-06-10       FAGR     Fagus gra… species   
#>  5 BART_006.b… BART   BART_… 2014-06-10       FAGR     Fagus gra… species   
#>  6 BART_006.b… BART   BART_… 2014-06-10       FAGR     Fagus gra… species   
#>  7 BART_006.b… BART   BART_… 2014-06-10       ACSA3    Acer sacc… species   
#>  8 BART_006.b… BART   BART_… 2014-06-10       FAGR     Fagus gra… species   
#>  9 BART_006.b… BART   BART_… 2014-06-10       ACPE     Acer pens… species   
#> 10 BART_006.b… BART   BART_… 2014-06-10       ACSA3    Acer sacc… species   
#> # … with 915,195 more rows, and 16 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, presence_absence <dbl>, subplotID <chr>,
#> #   subplot_id <chr>, subsubplot_id <chr>, boutNumber <chr>,
#> #   nativeStatusCode <chr>, heightPlantOver300cm <chr>,
#> #   heightPlantSpecies <chr>, release <chr>, sample_area_m2 <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_small_mammal
#> # A tibble: 15,275 x 19
#>    location_id siteID plotID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 HARV_001.m… HARV   HARV_… 2013-10-03       BLBR     Blarina b… species   
#>  2 HARV_001.m… HARV   HARV_… 2013-10-03       NAIN     Napaeozap… species   
#>  3 HARV_001.m… HARV   HARV_… 2013-10-03       PELE     Peromyscu… species   
#>  4 HARV_001.m… HARV   HARV_… 2013-10-03       PEMA     Peromyscu… species   
#>  5 HARV_001.m… HARV   HARV_… 2013-10-03       SOCI     Sorex cin… species   
#>  6 HARV_001.m… HARV   HARV_… 2013-10-03       TAST     Tamias st… species   
#>  7 HARV_006.m… HARV   HARV_… 2013-10-03       PELE     Peromyscu… species   
#>  8 HARV_006.m… HARV   HARV_… 2013-10-03       PEMA     Peromyscu… species   
#>  9 HARV_006.m… HARV   HARV_… 2013-10-03       PESP     Peromyscu… genus     
#> 10 HARV_006.m… HARV   HARV_… 2013-10-03       TAST     Tamias st… species   
#> # … with 15,265 more rows, and 12 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, year <chr>, month <chr>,
#> #   n_trap_nights_per_bout_per_plot <chr>, n_nights_per_bout <chr>,
#> #   nativeStatusCode <chr>, release <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
neonDivData::data_tick
#> # A tibble: 123,060 x 20
#>    location_id siteID plotID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 BART_011.t… BART   BART_… 2014-06-02 18:3… IXOSP2   Ixodida s… order     
#>  2 BART_011.t… BART   BART_… 2014-06-02 18:3… IXOSPP   Ixodidae … family    
#>  3 BART_011.t… BART   BART_… 2014-06-02 18:3… IXOSP    Ixodidae … family    
#>  4 BART_011.t… BART   BART_… 2014-06-02 18:3… IXOSCA   Ixodes sc… species   
#>  5 BART_011.t… BART   BART_… 2014-06-02 18:3… AMBAME   Amblyomma… species   
#>  6 BART_011.t… BART   BART_… 2014-06-02 18:3… IXOANG   Ixodes an… species   
#>  7 BART_011.t… BART   BART_… 2014-06-02 18:3… IXOPAC   Ixodes pa… species   
#>  8 BART_011.t… BART   BART_… 2014-06-02 18:3… DERVAR   Dermacent… species   
#>  9 BART_011.t… BART   BART_… 2014-06-02 18:3… AMBAME   Amblyomma… species   
#> 10 BART_011.t… BART   BART_… 2014-06-02 18:3… HAELON   Haemaphys… species   
#> # … with 123,050 more rows, and 13 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, neon_event_id <chr>, samplingMethod <chr>,
#> #   totalSampledArea <chr>, targetTaxaPresent <chr>, release <chr>,
#> #   LifeStage <chr>, remarks_field <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
neonDivData::data_tick_pathogen
#> # A tibble: 6,498 x 17
#>    location_id siteID plotID observation_dat… taxon_id taxon_name taxon_rank
#>    <chr>       <chr>  <chr>  <chr>            <chr>    <chr>      <chr>     
#>  1 HARV_001.t… HARV   HARV_… 2014-06-02 16:1… Borreli… Borrelia … species   
#>  2 HARV_001.t… HARV   HARV_… 2014-06-24 13:5… Borreli… Borrelia … species   
#>  3 HARV_001.t… HARV   HARV_… 2014-07-14 17:5… Borreli… Borrelia … species   
#>  4 HARV_022.t… HARV   HARV_… 2015-06-03 13:3… Anaplas… Anaplasma… species   
#>  5 HARV_022.t… HARV   HARV_… 2015-06-03 13:3… Babesia… Babesia m… species   
#>  6 HARV_022.t… HARV   HARV_… 2015-06-03 13:3… Borreli… Borrelia … species   
#>  7 HARV_022.t… HARV   HARV_… 2015-06-03 13:3… Borreli… Borrelia … species   
#>  8 HARV_022.t… HARV   HARV_… 2015-06-03 13:3… Borreli… Borrelia … species   
#>  9 HARV_022.t… HARV   HARV_… 2015-06-03 13:3… Borreli… Borrelia … species   
#> 10 HARV_022.t… HARV   HARV_… 2015-06-03 13:3… Borreli… Borrelia … genus     
#> # … with 6,488 more rows, and 10 more variables: variable_name <chr>,
#> #   value <dbl>, unit <chr>, lifeStage <chr>, batchID <chr>,
#> #   testProtocolVersion <chr>, release <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>
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
