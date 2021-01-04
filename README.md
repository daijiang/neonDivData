
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
inforamtions are in `neon_locations`; taxonomic informations are in
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
knitr::kable(neonDivData::data_summary)
```

| taxa              | neon\_DPI     | data\_product           | n\_site | n\_species | start\_year | end\_year | modify\_time |
|:------------------|:--------------|:------------------------|--------:|-----------:|------------:|----------:|:-------------|
| algae             | DP1.20166.001 | data\_algae             |      33 |       1824 |        2014 |      2019 | 2020-10-30   |
| beetle            | DP1.10022.001 | data\_beetle            |      47 |        756 |        2013 |      2020 | 2020-11-10   |
| bird              | DP1.10003.001 | data\_bird              |      47 |        535 |        2013 |      2019 | 2020-12-08   |
| fish              | DP1.20107.001 | data\_fish              |      27 |        125 |        2016 |      2020 | 2020-11-11   |
| herp\_bycatch     | DP1.10022.001 | data\_herp\_bycatch     |      41 |        125 |        2014 |      2020 | 2021-01-03   |
| macroinvertebrate | DP1.20120.001 | data\_macroinvertebrate |      34 |       1276 |        2014 |      2020 | 2020-10-30   |
| mosquito          | DP1.10043.001 | data\_mosquito          |      47 |        126 |        2015 |      2020 | 2020-10-30   |
| plant             | DP1.10058.001 | data\_plant             |      47 |       6075 |        2013 |      2020 | 2020-12-09   |
| small\_mammal     | DP1.10072.001 | data\_small\_mammal     |      46 |        137 |        2014 |      2019 | 2020-12-08   |
| tick              | DP1.10093.001 | data\_tick              |      41 |         19 |        2014 |      2018 | 2020-10-30   |
| tick\_pathogen    | DP1.10092.001 | data\_tick\_pathogen    |      14 |         12 |        2013 |      2020 | 2020-10-30   |
| zooplankton       | DP1.20219.001 | data\_zooplankton       |       7 |        154 |        2014 |      2020 | 2020-12-16   |

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
#> # A tibble: 11,255 x 7
#>    taxonID  scientificName   taxonRank family  identificationRefe… taxa  neonDPI
#>    <chr>    <chr>            <chr>     <chr>   <chr>               <chr> <chr>  
#>  1 ACHNANT… Achnanthidium s… genus     Achnan… NA; Academy of Nat… algae DP1.20…
#>  2 ACTINEL… Actinella sp.    genus     Eunoti… NA; Spaulding, S.,… algae DP1.20…
#>  3 AMPHORA… Amphora spp.     genus     Catenu… Academy of Natural… algae DP1.20…
#>  4 ANABAEN… Anabaena spp.    genus     Nostoc… Academy of Natural… algae DP1.20…
#>  5 AUDHER   Audouinella her… species   Acroch… M.D. Guiry in Guir… algae DP1.20…
#>  6 AULACOS… Aulacoseira spp. genus     Aulaco… Academy of Natural… algae DP1.20…
#>  7 BACILLA… Bacillaria spp.  genus     Bacill… NA                  algae DP1.20…
#>  8 BACILLA… Bacillariophyce… class     <NA>    NA; Wehr, J.D. and… algae DP1.20…
#>  9 BACILLA… Bacillariophyce… class     <NA>    NA                  algae DP1.20…
#> 10 BATRACH… Batrachospermac… family    Batrac… NA; Wehr, J.D. and… algae DP1.20…
#> # … with 11,245 more rows
neonDivData::neon_locations
#> # A tibble: 4,732 x 14
#>    domainID siteID plotID namedLocation nlcdClass decimalLatitude
#>    <chr>    <chr>  <chr>  <chr>         <chr>               <dbl>
#>  1 D01      BART   BART_… BART_012.bas… deciduou…            44.0
#>  2 D01      BART   BART_… BART_062.bas… deciduou…            44.1
#>  3 D01      BART   BART_… BART_028.bas… evergree…            44.1
#>  4 D01      BART   BART_… BART_015.bas… mixedFor…            44.0
#>  5 D01      BART   BART_… BART_011.bas… mixedFor…            44.1
#>  6 D01      BART   BART_… BART_007.bas… mixedFor…            44.0
#>  7 D01      BART   BART_… BART_018.bas… mixedFor…            44.1
#>  8 D01      BART   BART_… BART_031.bas… evergree…            44.1
#>  9 D01      BART   BART_… BART_029.bas… evergree…            44.1
#> 10 D01      BART   BART_… BART_068.bas… mixedFor…            44.1
#> # … with 4,722 more rows, and 8 more variables: decimalLongitude <dbl>,
#> #   geodeticDatum <chr>, coordinateUncertainty <dbl>, elevation <dbl>,
#> #   elevationUncertainty <dbl>, taxa <chr>, neonDPI <chr>,
#> #   aquaticSiteType <chr>

neonDivData::data_algae
#> # A tibble: 85,628 x 18
#>    siteID sampleID eventID namedLocation habitatType taxonID scientificName
#>    <chr>  <chr>    <chr>   <chr>         <chr>       <chr>   <chr>         
#>  1 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Leptolyngbya …
#>  2 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Achnanthidium…
#>  3 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Eunotia musci…
#>  4 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Navicula vene…
#>  5 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Nitzschia aci…
#>  6 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Encyonema ven…
#>  7 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Ulnaria contr…
#>  8 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Cocconeis pla…
#>  9 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Gomphonema mi…
#> 10 HOPB   HOPB.20… HOPB.2… HOPB.AOS.rea… riffle      NEONDR… Gomphonema sp.
#> # … with 85,618 more rows, and 11 more variables: family <chr>,
#> #   taxonRank <chr>, collectDate <dttm>, density <dbl>,
#> #   cell_density_standardized_unit <chr>, algalParameterValue <dbl>,
#> #   algalParameter <chr>, perBSVol <dbl>, fieldSampleVolume <dbl>,
#> #   algalSampleType <chr>, benthicArea <dbl>
neonDivData::data_beetle
#> # A tibble: 117,612 x 13
#>    sampleID boutID siteID plotID namedLocation trapID collectDate        
#>    <chr>    <chr>  <chr>  <chr>  <chr>         <chr>  <dttm>             
#>  1 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2016-09-13 00:00:00
#>  2 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2016-09-13 00:00:00
#>  3 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2016-09-27 00:00:00
#>  4 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2017-05-03 00:00:00
#>  5 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2017-05-17 00:00:00
#>  6 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2017-05-31 00:00:00
#>  7 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2017-05-31 00:00:00
#>  8 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2017-05-31 00:00:00
#>  9 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2017-06-14 00:00:00
#> 10 ABBY_00… ABBY_… ABBY   ABBY_… ABBY_002.bas… E      2017-06-14 00:00:00
#> # … with 117,602 more rows, and 6 more variables: trappingDays <dbl>,
#> #   family <chr>, taxonID <chr>, taxonRank <chr>, scientificName <chr>,
#> #   count <dbl>
neonDivData::data_bird
#> # A tibble: 164,106 x 27
#>    namedLocation siteID plotID pointID startDate           pointCountMinute
#>    <chr>         <chr>  <chr>  <chr>   <dttm>                         <dbl>
#>  1 BART_025.bir… BART   BART_… C1      2015-06-14 09:00:00                2
#>  2 BART_025.bir… BART   BART_… C1      2015-06-14 09:00:00                1
#>  3 BART_025.bir… BART   BART_… C1      2015-06-14 09:00:00                2
#>  4 BART_025.bir… BART   BART_… C1      2015-06-14 09:00:00                1
#>  5 BART_025.bir… BART   BART_… C1      2015-06-14 09:00:00                1
#>  6 BART_025.bir… BART   BART_… B1      2015-06-14 10:00:00                1
#>  7 BART_025.bir… BART   BART_… B1      2015-06-14 10:00:00                4
#>  8 BART_025.bir… BART   BART_… B1      2015-06-14 10:00:00                3
#>  9 BART_025.bir… BART   BART_… B1      2015-06-14 10:00:00                1
#> 10 BART_025.bir… BART   BART_… A1      2015-06-14 11:00:00                6
#> # … with 164,096 more rows, and 21 more variables: targetTaxaPresent <chr>,
#> #   taxonID <chr>, scientificName <chr>, taxonRank <chr>, vernacularName <chr>,
#> #   family <chr>, nativeStatusCode <chr>, observerDistance <dbl>,
#> #   detectionMethod <chr>, visualConfirmation <chr>, sexOrAge <chr>,
#> #   clusterSize <dbl>, clusterCode <chr>, startCloudCoverPercentage <dbl>,
#> #   endCloudCoverPercentage <dbl>, startRH <dbl>, endRH <dbl>,
#> #   observedHabitat <chr>, observedAirTemp <dbl>,
#> #   kmPerHourObservedWindSpeed <dbl>, samplingProtocolVersion <chr>
neonDivData::data_fish
#> # A tibble: 4,924 x 29
#>    siteID namedLocation reachID eventID samplerType taxonID taxonRank
#>    <chr>  <chr>         <chr>   <chr>   <chr>       <chr>   <chr>    
#>  1 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… RHIATR  species  
#>  2 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… SALTRU  species  
#>  3 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… SALFON  species  
#>  4 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… RHIATR  species  
#>  5 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… SALTRU  species  
#>  6 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… SALFON  species  
#>  7 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… SEMATR  species  
#>  8 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… RHIATR  species  
#>  9 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… SALFON  species  
#> 10 HOPB   HOPB.AOS.fis… HOPB.2… HOPB.2… electrofis… SEMATR  species  
#> # … with 4,914 more rows, and 22 more variables: scientificName <chr>,
#> #   catch_per_effort <dbl>, number_of_fish <dbl>, n_obs <int>,
#> #   startDate <dttm>, endDate <dttm>, netSetTime <dttm>, netEndTime <dttm>,
#> #   netDeploymentTime <dbl>, netLength <dbl>, netDepth <dbl>,
#> #   fixedRandomReach <chr>, measuredReachLength <dbl>, efTime <dbl>,
#> #   efTime2 <dbl>, passStartTime <dttm>, passEndTime <dttm>, passNumber <dbl>,
#> #   targetTaxaPresent <chr>, year <dbl>, month <dbl>, mean_efishtime <dbl>
neonDivData::data_herp_bycatch
#> # A tibble: 2,276 x 15
#>    namedLocation siteID plotID trapID setDate             collectDate        
#>    <chr>         <chr>  <chr>  <chr>  <dttm>              <dttm>             
#>  1 BART_066.bas… BART   BART_… E      2014-06-12 00:00:00 2014-06-26 00:00:00
#>  2 BART_028.bas… BART   BART_… W      2014-06-12 00:00:00 2014-06-26 00:00:00
#>  3 BART_002.bas… BART   BART_… W      2014-06-12 00:00:00 2014-06-26 00:00:00
#>  4 BART_031.bas… BART   BART_… E      2014-06-26 00:00:00 2014-07-10 00:00:00
#>  5 BART_066.bas… BART   BART_… N      2014-06-26 00:00:00 2014-07-10 00:00:00
#>  6 BART_068.bas… BART   BART_… W      2014-06-26 00:00:00 2014-07-10 00:00:00
#>  7 BART_031.bas… BART   BART_… S      2014-07-10 00:00:00 2014-07-24 00:00:00
#>  8 BART_002.bas… BART   BART_… N      2014-07-10 00:00:00 2014-07-24 00:00:00
#>  9 BART_028.bas… BART   BART_… N      2014-07-10 00:00:00 2014-07-24 00:00:00
#> 10 BART_028.bas… BART   BART_… W      2014-07-24 00:00:00 2014-08-07 00:00:00
#> # … with 2,266 more rows, and 9 more variables: eventID <chr>,
#> #   trappingDays <dbl>, taxonID <chr>, scientificName <chr>, taxonRank <chr>,
#> #   individualCount <dbl>, nativeStatusCode <chr>, remarksSorting <chr>,
#> #   remarksFielddata <chr>
neonDivData::data_macroinvertebrate
#> # A tibble: 119,871 x 11
#>    siteID sampleID namedLocation collectDate         taxonID scientificName
#>    <chr>  <chr>    <chr>         <dttm>              <chr>   <chr>         
#>  1 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 LUMSP2  Lumbriculidae…
#>  2 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 BRUSP   Brundiniella …
#>  3 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 PARSP15 Paracapnia sp.
#>  4 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 FELSP1  Feltria sp.   
#>  5 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 LUMSP2  Lumbriculidae…
#>  6 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 LUMSP2  Lumbriculidae…
#>  7 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 PROSP37 Prostoma sp.  
#>  8 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 LEUSP8  Leuctra sp.   
#>  9 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 CERSP10 Ceratopogonin…
#> 10 HOPB   HOPB.20… HOPB.AOS.rea… 2016-10-11 14:38:00 LEPSP20 Lepidostoma s…
#> # … with 119,861 more rows, and 5 more variables: family <chr>,
#> #   taxonRank <chr>, subsamplePercent <dbl>, individualCount <dbl>,
#> #   estimatedTotalCount <dbl>
neonDivData::data_mosquito
#> # A tibble: 86,619 x 20
#>    siteID plotID namedLocation eventID sampleID taxonID scientificName taxonRank
#>    <chr>  <chr>  <chr>         <chr>   <chr>    <chr>   <chr>          <chr>    
#>  1 BART   BART_… BART_056.mos… BART.2… BART_05… CULIMP  Culiseta impa… species  
#>  2 BART   BART_… BART_061.mos… BART.2… BART_06… CULIMP  Culiseta impa… species  
#>  3 BART   BART_… BART_055.mos… BART.2… BART_05… CULIMP  Culiseta impa… species  
#>  4 BART   BART_… BART_057.mos… BART.2… BART_05… ANOPUN  Anopheles pun… species  
#>  5 BART   BART_… BART_057.mos… BART.2… BART_05… CULIMP  Culiseta impa… species  
#>  6 BART   BART_… BART_058.mos… BART.2… BART_05… CULIMP  Culiseta impa… species  
#>  7 BART   BART_… BART_054.mos… BART.2… BART_05… CULIMP  Culiseta impa… species  
#>  8 BART   BART_… BART_059.mos… BART.2… BART_05… CULIMP  Culiseta impa… species  
#>  9 BART   BART_… BART_086.mos… BART.2… BART_08… CULIMP  Culiseta impa… species  
#> 10 BART   BART_… BART_057.mos… BART.2… BART_05… CULIMP  Culiseta impa… species  
#> # … with 86,609 more rows, and 12 more variables: family <chr>,
#> #   nativeStatusCode <chr>, sex <chr>, collectDate <dttm>,
#> #   startCollectDate <dttm>, endCollectDate <dttm>, individualCount <dbl>,
#> #   estimated_totIndividuals <dbl>, trapHours <dbl>, nightOrDay <chr>,
#> #   totalWeight <dbl>, subsampleWeight <dbl>
neonDivData::data_plant
#> # A tibble: 840,373 x 18
#>    namedLocation siteID plotID subplotID boutNumber endDate             taxonID
#>    <chr>         <chr>  <chr>  <chr>          <dbl> <dttm>              <chr>  
#>  1 BART_012.bas… BART   BART_… 32.4.1             1 2014-07-02 00:00:00 UVSE   
#>  2 BART_012.bas… BART   BART_… 40.3.1             1 2014-07-02 00:00:00 FRPE   
#>  3 BART_012.bas… BART   BART_… 40.3.1             1 2014-07-02 00:00:00 ACSAS  
#>  4 BART_012.bas… BART   BART_… 40.1.1             1 2014-07-02 00:00:00 FRPE   
#>  5 BART_012.bas… BART   BART_… 41.1.1             1 2014-07-02 00:00:00 PICEA  
#>  6 BART_012.bas… BART   BART_… 41.1.1             1 2014-07-02 00:00:00 UVSE   
#>  7 BART_012.bas… BART   BART_… 41.1.1             1 2014-07-02 00:00:00 ACPE   
#>  8 BART_012.bas… BART   BART_… 41.1.1             1 2014-07-02 00:00:00 FRPE   
#>  9 BART_012.bas… BART   BART_… 40.3.1             1 2014-07-02 00:00:00 FAGR   
#> 10 BART_012.bas… BART   BART_… 40.3.1             1 2014-07-02 00:00:00 UVSE   
#> # … with 840,363 more rows, and 11 more variables: scientificName <chr>,
#> #   taxonRank <chr>, family <chr>, nativeStatusCode <chr>, percentCover <dbl>,
#> #   heightPlantOver300cm <chr>, heightPlantSpecies <dbl>, sample_area_m2 <dbl>,
#> #   subplot_id <chr>, subsubplot_id <chr>, year <dbl>
neonDivData::data_small_mammal
#> # A tibble: 1,227,131 x 18
#>    siteID plotID namedLocation trapCoordinate trapStatus  year month   day
#>    <chr>  <chr>  <chr>         <chr>          <chr>      <dbl> <dbl> <int>
#>  1 BART   BART_… BART_012.mam… H6             6 - trap …  2014     5    28
#>  2 BART   BART_… BART_012.mam… H7             6 - trap …  2014     5    28
#>  3 BART   BART_… BART_012.mam… J10            6 - trap …  2014     5    28
#>  4 BART   BART_… BART_012.mam… H9             6 - trap …  2014     5    28
#>  5 BART   BART_… BART_012.mam… H8             6 - trap …  2014     5    28
#>  6 BART   BART_… BART_012.mam… G1             6 - trap …  2014     5    28
#>  7 BART   BART_… BART_012.mam… G2             6 - trap …  2014     5    28
#>  8 BART   BART_… BART_012.mam… G5             6 - trap …  2014     5    28
#>  9 BART   BART_… BART_012.mam… G6             6 - trap …  2014     5    28
#> 10 BART   BART_… BART_012.mam… G3             6 - trap …  2014     5    28
#> # … with 1,227,121 more rows, and 10 more variables: taxonID <chr>,
#> #   scientificName <chr>, taxonRank <chr>, nativeStatusCode <chr>, sex <chr>,
#> #   lifeStage <chr>, pregnancyStatus <chr>, tailLength <dbl>,
#> #   totalLength <dbl>, weight <dbl>
neonDivData::data_tick
#> # A tibble: 120,820 x 17
#>    namedLocation siteID plotID collectDate         eventID sampleID sampleCode
#>    <chr>         <chr>  <chr>  <dttm>              <chr>   <chr>    <chr>     
#>  1 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  2 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  3 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  4 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  5 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  6 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  7 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  8 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#>  9 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#> 10 BART_011.tic… BART   BART_… 2014-06-02 18:32:00 BART.2… BART_01… <NA>      
#> # … with 120,810 more rows, and 10 more variables: samplingMethod <chr>,
#> #   totalSampledArea <dbl>, targetTaxaPresent <chr>, remarks_field <chr>,
#> #   taxonID <chr>, LifeStage <chr>, IndividualCount <dbl>, taxonRank <chr>,
#> #   scientificName <chr>, family <chr>
neonDivData::data_tick_pathogen
#> # A tibble: 59,920 x 12
#>    namedLocation siteID plotID collectDate         endDate            
#>    <chr>         <chr>  <chr>  <dttm>              <dttm>             
#>  1 HARV_001.tic… HARV   HARV_… 2014-06-02 16:10:00 2014-06-02 16:41:00
#>  2 HARV_001.tic… HARV   HARV_… 2014-06-02 16:10:00 2014-06-02 16:41:00
#>  3 HARV_001.tic… HARV   HARV_… 2014-06-02 16:10:00 2014-06-02 16:41:00
#>  4 HARV_001.tic… HARV   HARV_… 2014-06-02 16:10:00 2014-06-02 16:41:00
#>  5 HARV_001.tic… HARV   HARV_… 2014-06-24 13:50:00 2014-06-24 14:36:00
#>  6 HARV_001.tic… HARV   HARV_… 2014-06-24 13:50:00 2014-06-24 14:36:00
#>  7 HARV_001.tic… HARV   HARV_… 2014-07-14 17:53:00 2014-07-14 18:24:00
#>  8 HARV_022.tic… HARV   HARV_… 2015-06-03 13:30:00 2015-06-03 14:20:00
#>  9 HARV_022.tic… HARV   HARV_… 2015-06-03 13:30:00 2015-06-03 14:20:00
#> 10 HARV_022.tic… HARV   HARV_… 2015-06-03 13:30:00 2015-06-03 14:20:00
#> # … with 59,910 more rows, and 7 more variables: hostSpecies <chr>,
#> #   lifeStage <chr>, testedDate <dttm>, testingID <chr>, batchID <chr>,
#> #   testResult <chr>, testPathogenName <chr>
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
