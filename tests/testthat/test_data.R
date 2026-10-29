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

# datasets rebuilt by data-raw/02_clean_save_data.R (fish and herp bycatch are discontinued)
current_data <- list(
  algae = data_algae, beetle = data_beetle, bird = data_bird,
  macroinvertebrate = data_macroinvertebrate, mosquito = data_mosquito,
  plant = data_plant, small_mammal = data_small_mammal, tick = data_tick,
  tick_pathogen = data_tick_pathogen, zooplankton = data_zooplankton
)

test_that("zero-catch rows have taxon_id = NA and value = 0", {
  for (nm in names(current_data)) {
    x <- current_data[[nm]]
    zero <- x[is.na(x$taxon_id), ]
    expect_true(all(zero$value == 0), info = nm)
  }
  # these datasets must keep zero-catch samples to preserve sampling effort
  for (nm in c("beetle", "bird", "macroinvertebrate", "mosquito", "plant", "small_mammal", "tick")) {
    expect_gt(sum(is.na(current_data[[nm]]$taxon_id)), 0, label = nm)
  }
})

test_that("at most one zero row per sample, and none in samples with taxa", {
  # columns identifying one sample in each dataset with zero rows
  sample_keys <- list(
    beetle = "unique_sample_id", bird = c("unique_sample_id", "plotID", "pointID"),
    macroinvertebrate = "unique_sample_id", mosquito = "unique_sample_id",
    plant = c("unique_sample_id", "subplotID"), small_mammal = "unique_sample_id",
    tick = "unique_sample_id"
  )
  for (nm in names(sample_keys)) {
    x <- current_data[[nm]]
    # small mammal: non-target captures may sit next to a zero row by design
    if (nm == "small_mammal") x <- x[!x$target_taxon %in% FALSE, ]
    key <- do.call(paste, unname(as.list(x[sample_keys[[nm]]])))
    zero_keys <- key[is.na(x$taxon_id)]
    expect_false(anyDuplicated(zero_keys) > 0, info = nm)
    expect_false(any(zero_keys %in% key[!is.na(x$taxon_id)]), info = nm)
  }
})

test_that("observation_datetime is POSIXct in all datasets", {
  for (nm in names(current_data)) {
    expect_s3_class(current_data[[nm]]$observation_datetime, "POSIXct")
  }
})

test_that("flag columns are present", {
  for (nm in setdiff(names(current_data), "tick_pathogen")) {
    expect_true("redundant_genus" %in% names(current_data[[nm]]), info = nm)
  }
  expect_true("vector_taxon_id" %in% names(data_tick_pathogen))
  expect_true("target_taxon" %in% names(data_small_mammal))
})

test_that("tick species-ID assays are not reported as pathogens", {
  host_tests <- c("Amblyomma americanum", "Ixodes scapularis", "Dermacentor variabilis",
                  "Haemaphysalis longicornis", "Ixodes pacificus", "HardTick DNA Quality")
  expect_false(any(data_tick_pathogen$taxon_id %in% host_tests))
})

test_that("plant WCVP binomials are Genus + epithet, and species are not split", {
  sp <- data_plant[data_plant$taxon_rank %in% c("species", "subspecies", "variety"), ]
  bin <- unique(sp$accepted_wcvp_name_binomial)
  # Genus + epithet (hybrid sign allowed); no "Taraxacum sect." style values
  expect_true(all(grepl("^×? ?[A-Z][^ ]* ×? ?[a-zà-öø-ÿ][a-zà-öø-ÿ-]*$", bin)),
              info = paste(head(bin[!grepl("^×? ?[A-Z][^ ]* ×? ?[a-zà-öø-ÿ][a-zà-öø-ÿ-]*$", bin)]), collapse = "; "))
  # a subspecies/variety must not keep its old NEON binomial when its species
  # resolved to a different accepted binomial (one species under two names)
  neon_bin <- sub("^(\\S+ \\S+).*", "\\1", sp$taxon_name)
  species_bin <- tapply(sp$accepted_wcvp_name_binomial[sp$taxon_rank == "species"],
                        neon_bin[sp$taxon_rank == "species"], function(x) x[1])
  infra <- sp$taxon_rank != "species"
  parent <- species_bin[neon_bin[infra]]
  split <- !is.na(parent) & parent != neon_bin[infra] & sp$accepted_wcvp_name_binomial[infra] == neon_bin[infra]
  expect_false(any(split), info = paste(unique(sp$taxon_name[infra][split]), collapse = "; "))
})

test_that("neon_taxa has no missing taxon_id", {
  expect_false(any(is.na(neon_taxa$taxon_id)))
})
