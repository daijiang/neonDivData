
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Update of RELEASE-2026

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

| taxon_group | neon_product_id | r_object | n_taxa | n_sites | start_date | end_date | variable_names | units |
|:---|:---|:---|---:|---:|:---|:---|:---|:---|
| ALGAE | DP1.20166.001 | data_algae | 2278 | 34 | 2014-07-02 | 2020-07-28 | cell density | cells/cm2 OR cells/mL |
| BEETLES | DP1.10022.001 | data_beetle | 831 | 47 | 2013-07-02 | 2023-12-20 | abundance | count per trap day |
| BIRDS | DP1.10003.001 | data_bird | 600 | 47 | 2013-06-05 | 2024-07-16 | cluster size | count of individuals |
| MACROINVERTEBRATES | DP1.20120.001 | data_macroinvertebrate | 1526 | 34 | 2014-07-01 | 2024-11-26 | density | count per square meter |
| MOSQUITOES | DP1.10043.001 | data_mosquito | 136 | 47 | 2014-04-09 | 2024-12-31 | abundance | count per trap hour |
| PLANTS | DP1.10058.001 | data_plant | 7047 | 47 | 2013-06-24 | 2024-11-21 | percent cover OR presence absence | percent of plot area covered by taxon |
| SMALL_MAMMALS | DP1.10072.001 | data_small_mammal | 169 | 46 | 2013-06-21 | 2024-11-12 | count | unique individuals per 100 trap nights per plot per month |
| TICKS | DP1.10093.001 | data_tick | 22 | 46 | 2014-04-02 | 2024-11-14 | abundance | count per square meter |
| TICK_PATHOGENS | DP1.10092.001 | data_tick_pathogen | 18 | 18 | 2014-04-17 | 2024-09-23 | positivity rate | positive tests per pathogen per sampling event |
| ZOOPLANKTON | DP1.20219.001 | data_zooplankton | 201 | 7 | 2014-07-02 | 2024-10-31 | density | count per liter |

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
#> # A tibble: 13,188 × 4
#>    taxon_id         taxon_name                            taxon_rank taxon_group
#>    <chr>            <chr>                                 <chr>      <chr>      
#>  1 ACHNANTHIDIUMSPP Achnanthidium spp.                    genus      ALGAE      
#>  2 ACHROS           Achnanthidium rosenstockii (Lange-Be… species    ALGAE      
#>  3 ACHSUB1          Achnanthidium subhudsonis var. kraeu… variety    ALGAE      
#>  4 ACTINELLASP      Actinella sp.                         genus      ALGAE      
#>  5 AMPCUN           Amphora cuneatiformis Levkov & Krist… species    ALGAE      
#>  6 AMPHORASPP       Amphora spp.                          genus      ALGAE      
#>  7 ANABAENASPP      Anabaena spp.                         genus      ALGAE      
#>  8 ANABAENOPSISSPP  Anabaenopsis spp.                     genus      ALGAE      
#>  9 ANEROS           Aneumastus rostratus (Hustedt) Lange… species    ALGAE      
#> 10 ANKISTRODEGSPP   Ankistrodesmus spp.                   genus      ALGAE      
#> # ℹ 13,178 more rows
neonDivData::neon_location
#> # A tibble: 4,328 × 8
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
#> # ℹ 4,318 more rows
#> # ℹ 1 more variable: aquaticSiteType <chr>
neonDivData::data_algae
#> # A tibble: 112,764 × 25
#>    location_id  siteID unique_sample_id observation_datetime taxon_id taxon_name
#>    <chr>        <chr>  <chr>            <dttm>               <chr>    <chr>     
#>  1 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  BACILLA… Bacillari…
#>  2 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  BATRACH… Batrachos…
#>  3 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  CHLOROP… Chlorophy…
#>  4 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  NEONDRE… Aulacosei…
#>  5 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  NEONDRE… Achnanthi…
#>  6 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  NEONDRE… Achnanthi…
#>  7 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  NEONDRE… Encyonema…
#>  8 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  NEONDRE… Caloneis …
#>  9 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  NEONDRE… Planothid…
#> 10 ARIK.AOS.re… ARIK   ARIK.20140715.E… 2014-07-15 18:00:00  NEONDRE… Planothid…
#> # ℹ 112,754 more rows
#> # ℹ 19 more variables: taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, sampleCondition <chr>, perBottleSampleVolume <dbl>,
#> #   release <chr>, habitatType <chr>, algalSampleType <chr>, samplerType <chr>,
#> #   benthicArea <dbl>, samplingProtocolVersion <chr>,
#> #   substratumSizeClass <chr>, phytoDepth1 <dbl>, phytoDepth2 <dbl>,
#> #   phytoDepth3 <dbl>, latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_beetle
#> # A tibble: 154,272 × 24
#>    location_id        siteID plotID unique_sample_id trapID observation_datetime
#>    <chr>              <chr>  <chr>  <chr>            <chr>  <date>              
#>  1 BART_066.basePlot… BART   BART_… BART_066.N.2014… N      2014-09-04          
#>  2 BART_066.basePlot… BART   BART_… BART_066.N.2014… N      2014-09-04          
#>  3 BART_066.basePlot… BART   BART_… BART_066.N.2014… N      2014-09-04          
#>  4 BART_066.basePlot… BART   BART_… BART_066.W.2014… W      2014-09-04          
#>  5 BART_068.basePlot… BART   BART_… BART_068.E.2014… E      2014-09-04          
#>  6 BART_068.basePlot… BART   BART_… BART_068.E.2014… E      2014-09-04          
#>  7 BART_068.basePlot… BART   BART_… BART_068.E.2014… E      2014-09-04          
#>  8 BART_028.basePlot… BART   BART_… BART_028.E.2014… E      2014-09-04          
#>  9 BART_028.basePlot… BART   BART_… BART_028.E.2014… E      2014-09-04          
#> 10 BART_028.basePlot… BART   BART_… BART_028.E.2014… E      2014-09-04          
#> # ℹ 154,262 more rows
#> # ℹ 18 more variables: taxon_id <chr>, taxon_name <chr>, taxon_rank <chr>,
#> #   variable_name <chr>, value <dbl>, unit <chr>, boutID <chr>,
#> #   nativeStatusCode <chr>, release <chr>, remarks <chr>,
#> #   samplingProtocolVersion <chr>, samplingImpractical <chr>,
#> #   trapConditionFlag <chr>, trappingDays <chr>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>, nlcdClass <chr>
neonDivData::data_bird
#> # A tibble: 372,767 × 35
#>    location_id       siteID plotID pointID unique_sample_id observation_datetime
#>    <chr>             <chr>  <chr>  <chr>   <chr>            <dttm>              
#>  1 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  2 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  3 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  4 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  5 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  6 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  7 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  8 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#>  9 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#> 10 BART_012.birdGri… BART   BART_… 9       BRD.BART.2018.1  2018-06-07 08:59:00 
#> # ℹ 372,757 more rows
#> # ℹ 29 more variables: taxon_id <chr>, taxon_name <chr>, taxon_rank <chr>,
#> #   variable_name <chr>, value <int>, unit <chr>, pointCountMinute <int>,
#> #   targetTaxaPresent <chr>, nativeStatusCode <chr>, observerDistance <dbl>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   release <chr>, startCloudCoverPercentage <int>,
#> #   endCloudCoverPercentage <int>, startRH <int>, endRH <int>, …
neonDivData::data_macroinvertebrate
#> # A tibble: 181,928 × 25
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
#> # ℹ 181,918 more rows
#> # ℹ 19 more variables: taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, estimatedTotalCount <dbl>, individualCount <int>,
#> #   subsamplePercent <chr>, release <chr>, benthicArea <dbl>,
#> #   habitatType <chr>, samplerType <chr>, substratumSizeClass <chr>,
#> #   remarks <chr>, ponarDepth <dbl>, snagLength <dbl>, snagDiameter <dbl>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>
neonDivData::data_mosquito
#> # A tibble: 172,850 × 24
#>    location_id siteID unique_sample_id subsampleID observation_datetime taxon_id
#>    <chr>       <chr>  <chr>            <chr>       <dttm>               <chr>   
#>  1 BART_055.m… BART   BART_055.201409… BART_055.2… 2014-09-23 11:06:00  AEDTRI1 
#>  2 BART_054.m… BART   BART_054.201409… BART_054.2… 2014-09-23 11:31:00  AEDCIN  
#>  3 BART_056.m… BART   BART_056.201409… BART_056.2… 2014-09-23 19:23:00  AEDTRI1 
#>  4 BART_061.m… BART   BART_061.201409… BART_061.2… 2014-09-23 19:32:00  AEDTRI1 
#>  5 BART_061.m… BART   BART_061.201409… BART_061.2… 2014-09-23 19:32:00  AEDCAN2 
#>  6 BART_055.m… BART   BART_055.201409… BART_055.2… 2014-09-23 19:38:00  AEDTRI1 
#>  7 BART_055.m… BART   BART_055.201409… BART_055.2… 2014-09-23 19:38:00  AEDCAN2 
#>  8 BART_057.m… BART   BART_057.201409… BART_057.2… 2014-09-23 19:45:00  AEDCIN  
#>  9 BART_057.m… BART   BART_057.201409… BART_057.2… 2014-09-23 19:45:00  AEDTRI1 
#> 10 BART_058.m… BART   BART_058.201409… BART_058.2… 2014-09-23 19:54:00  ANOWAL  
#> # ℹ 172,840 more rows
#> # ℹ 18 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, nativeStatusCode <chr>,
#> #   proportionIdentified <dbl>, release <chr>, remarks_sorting <chr>,
#> #   samplingProtocolVersion <chr>, sex <chr>, sortDate <date>, trapHours <dbl>,
#> #   latitude <dbl>, longitude <dbl>, elevation <dbl>, nlcdClass <chr>,
#> #   plotType <chr>
neonDivData::data_plant
#> # A tibble: 1,343,848 × 25
#>    location_id siteID plotID unique_sample_id subplotID subplot_id subsubplot_id
#>    <chr>       <chr>  <chr>  <chr>            <chr>     <chr>      <chr>        
#>  1 BART_006.b… BART   BART_… BART_006.basePl… 40_1_1    40         1            
#>  2 BART_006.b… BART   BART_… BART_006.basePl… 32_1_2    32         2            
#>  3 BART_006.b… BART   BART_… BART_006.basePl… 41_1_1    41         1            
#>  4 BART_006.b… BART   BART_… BART_006.basePl… 41_1_4    41         4            
#>  5 BART_006.b… BART   BART_… BART_006.basePl… 40_1_3    40         3            
#>  6 BART_006.b… BART   BART_… BART_006.basePl… 41_1_1    41         1            
#>  7 BART_006.b… BART   BART_… BART_006.basePl… 32_1_2    32         2            
#>  8 BART_006.b… BART   BART_… BART_006.basePl… 31_1_4    31         4            
#>  9 BART_006.b… BART   BART_… BART_006.basePl… 31_1_1    31         1            
#> 10 BART_006.b… BART   BART_… BART_006.basePl… 31_1_4    31         4            
#> # ℹ 1,343,838 more rows
#> # ℹ 18 more variables: observation_datetime <dttm>, taxon_id <chr>,
#> #   taxon_name <chr>, taxon_rank <chr>, variable_name <chr>, value <dbl>,
#> #   unit <chr>, presence_absence <dbl>, boutNumber <int>,
#> #   nativeStatusCode <chr>, heightPlantOver300cm <chr>,
#> #   heightPlantSpecies <int>, sample_area_m2 <dbl>, latitude <dbl>,
#> #   longitude <dbl>, elevation <dbl>, plotType <chr>, nlcdClass <chr>
neonDivData::data_small_mammal
#> # A tibble: 25,918 × 22
#>    location_id      siteID plotID unique_sample_id observation_datetime taxon_id
#>    <chr>            <chr>  <chr>  <chr>            <date>               <chr>   
#>  1 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-29           MIOR    
#>  2 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-29           MUER    
#>  3 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-29           PEKE    
#>  4 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-29           PEMA    
#>  5 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2016-08-29           SOMO    
#>  6 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-04-24           MIOR    
#>  7 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-04-24           PEMA    
#>  8 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-04-24           SOMO    
#>  9 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-04-24           SOSP    
#> 10 ABBY_002.mammal… ABBY   ABBY_… ABBY_002.mammal… 2017-04-24           SOTR    
#> # ℹ 25,908 more rows
#> # ℹ 16 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, year <chr>, month <chr>,
#> #   n_trap_nights_per_bout_per_plot <int>, n_nights_per_bout <int>,
#> #   nativeStatusCode <chr>, release <chr>, latitude <dbl>, longitude <dbl>,
#> #   elevation <dbl>, plotType <chr>, nlcdClass <chr>
neonDivData::data_tick
#> # A tibble: 18,184 × 22
#>    location_id      siteID plotID unique_sample_id observation_datetime taxon_id
#>    <chr>            <chr>  <chr>  <chr>            <dttm>               <chr>   
#>  1 BART_015.tickPl… BART   BART_… BART_015_2014-0… 2014-05-15 13:45:00  <NA>    
#>  2 BART_002.tickPl… BART   BART_… BART_002_2014-0… 2014-05-15 16:35:00  <NA>    
#>  3 BART_019.tickPl… BART   BART_… BART_019_2014-0… 2014-08-06 15:38:00  <NA>    
#>  4 BART_015.tickPl… BART   BART_… BART_015_2014-0… 2014-08-06 17:22:00  <NA>    
#>  5 BART_002.tickPl… BART   BART_… BART_002_2014-0… 2014-08-06 18:31:00  <NA>    
#>  6 BART_010.tickPl… BART   BART_… BART_010_2014-0… 2014-08-06 19:54:00  <NA>    
#>  7 BART_011.tickPl… BART   BART_… BART_011_2014-0… 2014-08-07 12:00:00  <NA>    
#>  8 BART_002.tickPl… BART   BART_… BART_002_2014-0… 2014-08-25 17:53:00  <NA>    
#>  9 BART_010.tickPl… BART   BART_… BART_010_2014-0… 2014-08-25 17:56:00  <NA>    
#> 10 BART_019.tickPl… BART   BART_… BART_019_2014-0… 2014-08-26 17:46:00  <NA>    
#> # ℹ 18,174 more rows
#> # ℹ 16 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, LifeStage <chr>, release <chr>,
#> #   remarks_field <chr>, samplingMethod <chr>, targetTaxaPresent <chr>,
#> #   totalSampledArea <dbl>, latitude <dbl>, longitude <dbl>, elevation <dbl>,
#> #   nlcdClass <chr>, plotType <chr>
neonDivData::data_tick_pathogen
#> # A tibble: 18,114 × 21
#>    location_id      siteID plotID unique_sample_id observation_datetime taxon_id
#>    <chr>            <chr>  <chr>  <chr>            <dttm>               <chr>   
#>  1 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-05-16 15:37:00  Anaplas…
#>  2 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-05-16 15:37:00  Babesia…
#>  3 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-05-16 15:37:00  Borreli…
#>  4 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-05-16 15:37:00  Borreli…
#>  5 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-05-16 15:37:00  Borreli…
#>  6 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-05-16 15:37:00  Borreli…
#>  7 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-05-16 15:37:00  Ehrlich…
#>  8 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-06-06 18:18:00  Anaplas…
#>  9 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-06-06 18:18:00  Babesia…
#> 10 BLAN_005.tickPl… BLAN   BLAN_… BLAN_005.tickPl… 2016-06-06 18:18:00  Borreli…
#> # ℹ 18,104 more rows
#> # ℹ 15 more variables: taxon_name <chr>, taxon_rank <chr>, variable_name <chr>,
#> #   value <dbl>, unit <chr>, lifeStage <chr>, testProtocolVersion <chr>,
#> #   release <chr>, n_tests <int>, n_positive_test <int>, latitude <dbl>,
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
