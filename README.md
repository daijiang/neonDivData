
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Update of RELEASE-2025

Note that Fish and By catch herp have not been updated this time. By
catch herps likely will be removed in future release given their design
was not suitable for diversity data. Fish data are currently under
updating by NEON.

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

| taxon_group | n_taxa | n_sites | start_date | end_date | data_package_title | neon_ecocomdp_mapping_method | original_neon_data_product_id | original_neon_data_version | original_neon_data_doi | r_object | variable_names | units |
|:---|---:|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| ALGAE | 2278 | 34 | 2014-07-02 | 2020-07-28 | ALGAE from the NEON data product: Periphyton, seston, and phytoplankton collection | neon.ecocomdp.20166.001.001 | DP1.20166.001 | RELEASE-2025 | <https://doi.org/10.48443/3cvp-hw55%7Chttps://doi.org/10.48443/g2k4-d258%7Chttps://doi.org/10.48443/cebv-nn73%7Chttps://doi.org/10.48443/swyk-0p63%7Chttps://doi.org/10.48443/d24k-p307> | data_algae | cell density | cells/cm2 OR cells/mL |
| SMALL_MAMMALS | 92 | 46 | 2013-06-19 | 2023-11-16 | SMALL_MAMMALS from the NEON data product: Small mammal box trapping | neon.ecocomdp.10072.001.001 | DP1.10072.001 | RELEASE-2025 | <https://doi.org/10.48443/j1g9-2j27%7Chttps://doi.org/10.48443/h3dk-3a71%7Chttps://doi.org/10.48443/p4re-p954%7Chttps://doi.org/10.48443/nvpj-4j94%7Chttps://doi.org/10.48443/yrh2-6058> | data_small_mammal | count | unique individuals per 100 trap nights per plot per month |
| PLANTS | 6859 | 47 | 2013-06-24 | 2023-11-08 | PLANTS from the NEON data product: Plant presence and percent cover | neon.ecocomdp.10058.001.001 | DP1.10058.001 | RELEASE-2025 | <https://doi.org/10.48443/abge-r811%7Chttps://doi.org/10.48443/pr5e-1q60%7Chttps://doi.org/10.48443/9579-a253%7Chttps://doi.org/10.48443/c50b-qx77%7Chttps://doi.org/10.48443/zp67-s364> | data_plant | percent cover | percent of plot area covered by taxon |
| BEETLES | 818 | 47 | 2013-07-03 | 2022-12-21 | BEETLES from the NEON data product: Ground beetles sampled from pitfall traps | neon.ecocomdp.10022.001.001 | DP1.10022.001 | RELEASE-2025 | <https://doi.org/10.48443/tx5f-dy17%7Chttps://doi.org/10.48443/xgea-hw23%7Chttps://doi.org/10.48443/3v35-v852%7Chttps://doi.org/10.48443/rcxn-t544%7Chttps://doi.org/10.48443/cd21-q875> | data_herp_bycatch | abundance | count per trap day |
| MACROINVERTEBRATES | 1491 | 34 | 2014-07-01 | 2023-07-27 | MACROINVERTEBRATES from the NEON data product: Macroinvertebrate collection | neon.ecocomdp.20120.001.001 | DP1.20120.001 | RELEASE-2025 | <https://doi.org/10.48443/855x-0n27%7Chttps://doi.org/10.48443/gn8x-k322%7Chttps://doi.org/10.48443/zj4y-4073%7Chttps://doi.org/10.48443/je35-bc57%7Chttps://doi.org/10.48443/rmeq-8897> | data_macroinvertebrate | density | count per square meter |
| MOSQUITOES | 136 | 47 | 2014-04-09 | 2023-12-28 | MOSQUITOES from the NEON data product: Mosquitoes sampled from CO2 traps | neon.ecocomdp.10043.001.001 | DP1.10043.001 | RELEASE-2025 | <https://doi.org/10.48443/9smm-v091%7Chttps://doi.org/10.48443/c7h7-q918%7Chttps://doi.org/10.48443/bxnk-jb11%7Chttps://doi.org/10.48443/3cyq-6v47%7Chttps://doi.org/10.48443/y3fp-9583> | data_mosquito | abundance | count per trap hour |
| BIRDS | 589 | 47 | 2013-06-05 | 2023-07-16 | BIRDS from the NEON data product: Breeding landbird point counts | neon.ecocomdp.10003.001.001 | DP1.10003.001 | RELEASE-2025 | <https://doi.org/10.48443/s730-dy13%7Chttps://doi.org/10.48443/88sy-ah40%7Chttps://doi.org/10.48443/00pg-vm19%7Chttps://doi.org/10.48443/4a0h-fy23%7Chttps://doi.org/10.48443/3nka-yg96> | data_bird | cluster size | count of individuals |
| TICKS | 21 | 46 | 2014-04-02 | 2023-12-28 | TICKS from the NEON data product: Ticks sampled using drag cloths | neon.ecocomdp.10093.001.001 | DP1.10093.001 | RELEASE-2025 | <https://doi.org/10.48443/dx40-wr20%7Chttps://doi.org/10.48443/7jh5-8s51%7Chttps://doi.org/10.48443/fh83-k817%7Chttps://doi.org/10.48443/3zmh-xx57%7Chttps://doi.org/10.48443/6zpz-5z19> | data_tick | abundance | count per square meter |
| ZOOPLANKTON | 172 | 7 | 2014-07-02 | 2021-11-02 | ZOOPLANKTON from the NEON data product: Zooplankton collection | neon.ecocomdp.20219.001.001 | DP1.20219.001 | RELEASE-2025 | <https://doi.org/10.48443/qzr1-jr79%7Chttps://doi.org/10.48443/150d-yf27%7Chttps://doi.org/10.48443/eqmn-5b37%7Chttps://doi.org/10.48443/6kxg-hb11%7Chttps://doi.org/10.48443/5h5n-3d49> | data_zooplankton | density | count per liter |
| TICK_PATHOGENS | 18 | 18 | 2014-04-17 | 2023-09-28 | TICK_PATHOGENS from the NEON data product: Tick-borne pathogen status | neon.ecocomdp.10092.001.001 | DP1.10092.001 | RELEASE-2025 | <https://doi.org/10.48443/5fab-xv19%7Chttps://doi.org/10.48443/nygx-dm71%7Chttps://doi.org/10.48443/nyst-jp72%7Chttps://doi.org/10.48443/4d7n-w481%7Chttps://doi.org/10.48443/8nhe-cp13> | data_tick_pathogen | positivity rate | positive tests per pathogen per sampling event |

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
#> # ℹ 71 more rows
#> # ℹ 3 more variables: `Site Type` <chr>, `Site Subtype` <chr>,
#> #   `Site Host` <chr>
neonDivData::neon_taxa
#> # A tibble: 12,879 × 4
#>    taxon_id       taxon_name                              taxon_rank taxon_group
#>    <chr>          <chr>                                   <chr>      <chr>      
#>  1 NEONDREX890025 Phormidium sp.                          genus      ALGAE      
#>  2 NEONDREX852004 Homoeothrix janthina (Bornet et Flahau… species    ALGAE      
#>  3 BATRACHOSPFSP  Batrachospermaceae sp.                  family     ALGAE      
#>  4 NEONDREX1038   Achnanthidium deflexum (Reimer) Kingst… species    ALGAE      
#>  5 NEONDREX37010  Gomphonema parvulum (Kützing) Kützing   species    ALGAE      
#>  6 NEONDREX245001 Ulnaria ulna (Nitzsch) Compère          species    ALGAE      
#>  7 NEONDREX316008 Closterium sp.                          genus      ALGAE      
#>  8 NEONDREX1010   Achnanthidium minutissimum (Kützing) C… species    ALGAE      
#>  9 NEONDREX52009  Pinnularia appendiculata (Agardh) Cleve species    ALGAE      
#> 10 NEONDREX34030  Fragilaria vaucheriae (Kützing) Peters… species    ALGAE      
#> # ℹ 12,869 more rows
neonDivData::neon_location
#> # A tibble: 4,283 × 8
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
#> # ℹ 4,273 more rows
#> # ℹ 1 more variable: aquaticSiteType <chr>
neonDivData::data_algae
#> # A tibble: 112,508 × 25
#>    location_id  siteID unique_sample_id observation_datetime taxon_id taxon_name
#>    <chr>        <chr>  <chr>            <dttm>               <chr>    <chr>     
#>  1 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Phormidiu…
#>  2 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Homoeothr…
#>  3 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  BATRACH… Batrachos…
#>  4 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Achnanthi…
#>  5 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Gomphonem…
#>  6 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Ulnaria u…
#>  7 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Closteriu…
#>  8 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Achnanthi…
#>  9 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Pinnulari…
#> 10 HOPB.AOS.re… HOPB   HOPB.20170419.E… 2017-04-19 09:05:00  NEONDRE… Fragilari…
#> # ℹ 112,498 more rows
#> # ℹ 19 more variables: taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, sampleCondition <chr>, perBottleSampleVolume <chr>,
#> #   release <chr>, habitatType <chr>, algalSampleType <chr>, samplerType <chr>,
#> #   benthicArea <chr>, samplingProtocolVersion <chr>,
#> #   substratumSizeClass <chr>, phytoDepth1 <chr>, phytoDepth2 <chr>,
#> #   phytoDepth3 <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_beetle
#> # A tibble: 91,017 × 22
#>    location_id        siteID plotID unique_sample_id trapID observation_datetime
#>    <chr>              <chr>  <chr>  <chr>            <chr>  <date>              
#>  1 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2016… E      2016-09-13          
#>  2 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2016… E      2016-09-13          
#>  3 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2016… E      2016-09-27          
#>  4 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2017… E      2017-05-17          
#>  5 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2017… E      2017-05-31          
#>  6 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2017… E      2017-05-31          
#>  7 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2017… E      2017-06-14          
#>  8 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2017… E      2017-06-14          
#>  9 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2017… E      2017-06-28          
#> 10 ABBY_002.basePlot… ABBY   ABBY_… ABBY_002.E.2018… E      2018-05-01          
#> # ℹ 91,007 more rows
#> # ℹ 16 more variables: taxon_id <chr>, taxon_name <chr>, taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, boutID <chr>,
#> #   nativeStatusCode <chr>, release <chr>, remarks <chr>,
#> #   samplingProtocolVersion <chr>, trappingDays <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>, nlcdClass <chr>
neonDivData::data_bird
#> # A tibble: 302,186 × 35
#>    location_id       siteID plotID pointID unique_sample_id observation_datetime
#>    <chr>             <chr>  <chr>  <chr>   <chr>            <dttm>              
#>  1 BART_025.birdGri… BART   BART_… 3       BRD.BART.2015.1  2015-06-14 09:23:00 
#>  2 BART_025.birdGri… BART   BART_… 3       BRD.BART.2015.1  2015-06-14 09:23:00 
#>  3 BART_025.birdGri… BART   BART_… 3       BRD.BART.2015.1  2015-06-14 09:23:00 
#>  4 BART_025.birdGri… BART   BART_… 3       BRD.BART.2015.1  2015-06-14 09:23:00 
#>  5 BART_025.birdGri… BART   BART_… 3       BRD.BART.2015.1  2015-06-14 09:23:00 
#>  6 BART_025.birdGri… BART   BART_… 2       BRD.BART.2015.1  2015-06-14 09:43:00 
#>  7 BART_025.birdGri… BART   BART_… 2       BRD.BART.2015.1  2015-06-14 09:43:00 
#>  8 BART_025.birdGri… BART   BART_… 2       BRD.BART.2015.1  2015-06-14 09:43:00 
#>  9 BART_025.birdGri… BART   BART_… 2       BRD.BART.2015.1  2015-06-14 09:43:00 
#> 10 BART_025.birdGri… BART   BART_… 1       BRD.BART.2015.1  2015-06-14 10:31:00 
#> # ℹ 302,176 more rows
#> # ℹ 29 more variables: taxon_id <chr>, taxon_name <chr>, taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, pointCountMinute <chr>,
#> #   targetTaxaPresent <chr>, nativeStatusCode <chr>, observerDistance <chr>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   release <chr>, startCloudCoverPercentage <chr>,
#> #   endCloudCoverPercentage <chr>, startRH <chr>, endRH <chr>, …
neonDivData::data_macroinvertebrate
#> # A tibble: 154,008 × 25
#>    location_id  siteID unique_sample_id observation_datetime taxon_id taxon_name
#>    <chr>        <chr>  <chr>            <dttm>               <chr>    <chr>     
#>  1 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  ABLSP    Ablabesmy…
#>  2 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  BAESP    Baetidae …
#>  3 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  CAESP5   Caenis sp.
#>  4 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  CALFLU   Callibaet…
#>  5 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  CERSP18  Ceratopog…
#>  6 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  CHISP2   Chironomi…
#>  7 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  CHISP8   Chironomu…
#>  8 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  CLISP3   Clinotany…
#>  9 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  COESP    Coenagrio…
#> 10 ARIK.AOS.re… ARIK   ARIK.20140714.C… 2014-07-14 17:51:00  CORSP4   Corixidae…
#> # ℹ 153,998 more rows
#> # ℹ 19 more variables: taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, estimatedTotalCount <chr>, individualCount <chr>,
#> #   subsamplePercent <chr>, release <chr>, benthicArea <chr>,
#> #   habitatType <chr>, samplerType <chr>, substratumSizeClass <chr>,
#> #   remarks <chr>, ponarDepth <dbl>, snagLength <dbl>, snagDiameter <dbl>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_mosquito
#> # A tibble: 152,891 × 24
#>    location_id siteID unique_sample_id subsampleID observation_datetime taxon_id
#>    <chr>       <chr>  <chr>            <chr>       <date>               <chr>   
#>  1 BART_055.m… BART   BART_055.201409… BART_055.2… 2014-09-23           AEDTRI1 
#>  2 BART_054.m… BART   BART_054.201409… BART_054.2… 2014-09-23           AEDCIN  
#>  3 BART_056.m… BART   BART_056.201409… BART_056.2… 2014-09-23           AEDTRI1 
#>  4 BART_061.m… BART   BART_061.201409… BART_061.2… 2014-09-23           AEDTRI1 
#>  5 BART_061.m… BART   BART_061.201409… BART_061.2… 2014-09-23           AEDCAN2 
#>  6 BART_055.m… BART   BART_055.201409… BART_055.2… 2014-09-23           AEDTRI1 
#>  7 BART_055.m… BART   BART_055.201409… BART_055.2… 2014-09-23           AEDCAN2 
#>  8 BART_057.m… BART   BART_057.201409… BART_057.2… 2014-09-23           AEDCIN  
#>  9 BART_057.m… BART   BART_057.201409… BART_057.2… 2014-09-23           AEDTRI1 
#> 10 BART_058.m… BART   BART_058.201409… BART_058.2… 2014-09-23           ANOWAL  
#> # ℹ 152,881 more rows
#> # ℹ 18 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, nativeStatusCode <chr>,
#> #   proportionIdentified <chr>, release <chr>, remarks_sorting <chr>,
#> #   samplingProtocolVersion <chr>, sex <chr>, sortDate <chr>, trapHours <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, nlcdClass <chr>,
#> #   plotType <chr>
neonDivData::data_plant
#> # A tibble: 1,263,716 × 26
#>    location_id siteID plotID unique_sample_id subplotID subplot_id subsubplot_id
#>    <chr>       <chr>  <chr>  <chr>            <chr>     <chr>      <chr>        
#>  1 BART_006.b… BART   BART_… BART_006.basePl… 40_1_1    40         1            
#>  2 BART_006.b… BART   BART_… BART_006.basePl… 32_1_2    32         1            
#>  3 BART_006.b… BART   BART_… BART_006.basePl… 41_1_1    41         1            
#>  4 BART_006.b… BART   BART_… BART_006.basePl… 41_1_4    41         1            
#>  5 BART_006.b… BART   BART_… BART_006.basePl… 40_1_3    40         1            
#>  6 BART_006.b… BART   BART_… BART_006.basePl… 41_1_1    41         1            
#>  7 BART_006.b… BART   BART_… BART_006.basePl… 32_1_2    32         1            
#>  8 BART_006.b… BART   BART_… BART_006.basePl… 31_1_4    31         1            
#>  9 BART_006.b… BART   BART_… BART_006.basePl… 31_1_1    31         1            
#> 10 BART_006.b… BART   BART_… BART_006.basePl… 31_1_4    31         1            
#> # ℹ 1,263,706 more rows
#> # ℹ 19 more variables: observation_datetime <date>, taxon_id <chr>,
#> #   taxon_name <chr>, taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, presence_absence <dbl>, boutNumber <chr>,
#> #   nativeStatusCode <chr>, heightPlantOver300cm <chr>,
#> #   heightPlantSpecies <chr>, release <chr>, sample_area_m2 <chr>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, plotType <chr>, …
neonDivData::data_small_mammal
#> # A tibble: 17,086 × 22
#>    location_id      siteID plotID unique_sample_id observation_datetime taxon_id
#>    <chr>            <chr>  <chr>  <chr>            <date>               <chr>   
#>  1 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-27           MIOR    
#>  2 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-27           PEKE    
#>  3 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-27           PEMA    
#>  4 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23           MIOR    
#>  5 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-04-23           PEMA    
#>  6 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-06-19           MIOR    
#>  7 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-06-19           PEMA    
#>  8 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-06-19           ZATR    
#>  9 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-07-17           MILO    
#> 10 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-07-17           MIOR    
#> # ℹ 17,076 more rows
#> # ℹ 16 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, year <chr>, month <chr>,
#> #   n_trap_nights_per_bout_per_plot <chr>, n_nights_per_bout <chr>,
#> #   nativeStatusCode <chr>, release <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>, plotType <chr>, nlcdClass <chr>
neonDivData::data_tick
#> # A tibble: 489,360 × 22
#>    location_id      siteID plotID unique_sample_id observation_datetime taxon_id
#>    <chr>            <chr>  <chr>  <chr>            <dttm>               <chr>   
#>  1 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  IXOSP   
#>  2 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  IXOSCA  
#>  3 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  AMBAME  
#>  4 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  AMBSPP  
#>  5 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  IXOSP2  
#>  6 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  IXOANG  
#>  7 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  IXOPAC  
#>  8 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  HAELEP  
#>  9 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  DERVAR  
#> 10 ABBY_001.tickPl… ABBY   ABBY_… ABBY_001_2016-0… 2016-09-22 18:12:00  IXOSCA  
#> # ℹ 489,350 more rows
#> # ℹ 16 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, LifeStage <chr>, release <chr>,
#> #   remarks_field <chr>, samplingMethod <chr>, targetTaxaPresent <chr>,
#> #   totalSampledArea <chr>, latitude <dbl>, longitude <dbl>, elevation <dbl>,
#> #   nlcdClass <chr>, plotType <chr>
neonDivData::data_tick_pathogen
#> # A tibble: 15,159 × 21
#>    location_id      siteID plotID unique_sample_id observation_datetime taxon_id
#>    <chr>            <chr>  <chr>  <chr>            <dttm>               <chr>   
#>  1 HARV_001.tickPl… HARV   HARV_… HARV_001.tickPl… 2014-06-02 16:10:00  Borreli…
#>  2 HARV_001.tickPl… HARV   HARV_… HARV_001.tickPl… 2014-06-24 13:50:00  Borreli…
#>  3 HARV_001.tickPl… HARV   HARV_… HARV_001.tickPl… 2014-07-14 17:53:00  Borreli…
#>  4 HARV_004.tickPl… HARV   HARV_… HARV_004.tickPl… 2015-07-13 18:22:00  Anaplas…
#>  5 HARV_004.tickPl… HARV   HARV_… HARV_004.tickPl… 2015-07-13 18:22:00  Babesia…
#>  6 HARV_004.tickPl… HARV   HARV_… HARV_004.tickPl… 2015-07-13 18:22:00  Borreli…
#>  7 HARV_004.tickPl… HARV   HARV_… HARV_004.tickPl… 2015-07-13 18:22:00  Borreli…
#>  8 HARV_004.tickPl… HARV   HARV_… HARV_004.tickPl… 2015-07-13 18:22:00  Borreli…
#>  9 HARV_004.tickPl… HARV   HARV_… HARV_004.tickPl… 2015-07-13 18:22:00  Borreli…
#> 10 HARV_004.tickPl… HARV   HARV_… HARV_004.tickPl… 2015-07-13 18:22:00  Ehrlich…
#> # ℹ 15,149 more rows
#> # ℹ 15 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, lifeStage <chr>, testProtocolVersion <chr>,
#> #   release <chr>, n_tests <chr>, n_positive_tests <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>, nlcdClass <chr>, plotType <chr>
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
