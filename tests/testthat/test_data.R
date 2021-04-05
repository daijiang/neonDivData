context("test data structure and values")

test_that("all data value should be numbers or NAs", {
  expect_false(any(is.infinite(unique(data_algae$value))))
  expect_false(any(is.infinite(unique(data_beetle$value))))
  expect_false(any(is.infinite(unique(data_bird$value))))
  expect_false(any(is.infinite(unique(data_fish$value))))
  expect_false(any(is.infinite(unique(data_herp_bycatch$value))))
  expect_false(any(is.infinite(unique(data_macroinvertebrate$value))))
  expect_false(any(is.infinite(unique(data_mosquito$value))))
  expect_false(any(is.infinite(unique(data_plant$value))))
  expect_false(any(is.infinite(unique(data_small_mammal$value))))
  expect_false(any(is.infinite(unique(data_tick$value))))
  expect_false(any(is.infinite(unique(data_tick_pathogen$value))))
  expect_false(any(is.infinite(unique(data_zooplankton$value))))
})


test_that("nativeStatusCode", {
  # should be in these groups: beetles, herp by catch, bird, mosquito, plant, small mammal
  expect_true("nativeStatusCode" %in% names(data_beetle))
  expect_true("nativeStatusCode" %in% names(data_bird))
  expect_true("nativeStatusCode" %in% names(data_herp_bycatch))
  expect_true("nativeStatusCode" %in% names(data_mosquito))
  expect_true("nativeStatusCode" %in% names(data_plant))
  expect_true("nativeStatusCode" %in% names(data_small_mammal))
})
