library(testthat)
library(neonDivData)

test_check("neonDivData")

# Mosquito data: "subsampleWeight"      "totalWeight"          "weightBelowDetection" no longer available
# Fish data: "passStartTime" "passEndTime" no longer available

# fish data not downloading recent years' data.