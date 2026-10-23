# Annual Data Update Guide

This folder contains the scripts used to download, clean, and package NEON
organismal data into the `neonDivData` R package. Follow these steps each year
after NEON releases their updated annual data.

---

## Prerequisites

- A valid NEON API token stored in the environment variable `NEON_TOKEN`
  (add to `~/.Renviron` or set via `Sys.setenv(NEON_TOKEN = "...")`).
- R packages: `neonUtilities`, `tidyverse`, `usethis`, `devtools`.
- Access to the shared plant name base (`sp_names_all.rds` from the
  `species_name_standardization` project on bot211). Set `SP_NAME_BASE` to its
  path if it is not at the default server location (see Step 3).
- Run all scripts from the **package root** (not from inside `data-raw/`), e.g.
  open the project in RStudio or set the working directory with
  `setwd("<repo root>")`.

---

## Step 1 — Download raw NEON data

**Script:** `01_download_data.R`

Downloads all ten NEON taxon data products using `neonUtilities::loadByProduct()`
and saves each as a timestamped RDS file in `data-raw/NEON_raw_data/`. All files
from the same run share the same date stamp, e.g.
`plant_DP1.10058.001_20260423.RDS`.

```r
source("data-raw/01_download_data.R")
```

**Notes:**
- Downloads are large and slow — run overnight if possible.
- Only released (non-provisional) data is included (`include.provisional = FALSE`).
- Fish (`DP1.20107.001`) and herp bycatch are handled separately and are not
  downloaded here.
- If a single taxon fails, re-run just that block manually rather than
  re-downloading everything.

---

## Step 2 — Clean and save all datasets

**Script:** `02_clean_save_data.R`

Reads the most recent RDS file for each taxon (by date stamp), dispatches to
the corresponding `clean_neon_*()` function defined in `00_taxon_clean.R`,
builds the shared lookup tables (`neon_taxa`, `neon_location`, `data_summary`),
and saves all datasets as package data via `usethis::use_data()`.

```r
source("data-raw/02_clean_save_data.R")
```

**What it produces (all saved to `data/`):**
- `data_algae`, `data_beetle`, `data_bird`, `data_macroinvertebrate`,
  `data_mosquito`, `data_plant`, `data_small_mammal`, `data_tick`,
  `data_tick_pathogen`, `data_zooplankton`
- `neon_taxa` — accumulated taxon list (unions new + previous release so no
  names are lost between years)
- `neon_location` — accumulated location list (same union logic)
- `data_summary` — one-row-per-taxon-group overview table

**Notes:**
- The script always picks up the *most recent* RDS file per taxon, so leftover
  files from prior years are safe to keep (but can be deleted to save space).
- After running, do a quick sanity check on taxon and site counts:
  
  ```r
  neon_taxa |> count(taxon_group)
  data_summary |> select(taxon_group, n_taxa, n_sites, start_date, end_date)
  ```

---

## Step 3 — Standardize plant names against WCVP

**Script:** `03_plant_names.R`

Joins species-, subspecies-, and variety-level plant taxa against the shared
plant name base (`species_name_standardization` project), which standardizes
raw names against the World Checklist of Vascular Plants (WCVP) with `rWCVP`.
Adds three columns to `data_plant`: `accepted_wcvp_name`,
`accepted_wcvp_name_binomial`, and `species_group_assigned`. Original NEON
names are always preserved in `taxon_name`.

```r
# default: /media/dli/Data/common_data/species_name_standardization/data_output/sp_names_all.rds
Sys.setenv(SP_NAME_BASE = "<path to a local copy of sp_names_all.rds>")
source("data-raw/03_plant_names.R")
```

**Join on the raw name.** The join uses `sp_original` = NEON `taxon_name`
*with* its authorship, never the canonical name: the same canonical name can
resolve to different accepted taxa depending on its author (homonyms).

**New NEON names.** Names not yet in the name base keep their NEON name and are
listed with `in_name_base = FALSE` in `plant_name_lookup.csv`. Each year, add
the new `data_plant` names to the name base (register neonDivData as a source
in its `code/01_collect_raw_names.R` and re-run its pipeline), then re-run this
step.

**speciesGroup taxa** (e.g. "Fraxinus americana/pennsylvanica") are assigned
to one member species (first-listed by default or, if it is not recorded at
that site, the first later-listed member that is) and flagged with
`species_group_assigned = TRUE`.

**Outputs:**
- `data-raw/plant_name_lookup.csv`: every species-level NEON taxon with its
  name-base match (`match_way`, `resolved_match_type`, accepted name and IDs)
  and the WCVP version.
- `data-raw/plant_name_lookup_applied.csv` — the before/after name table
  (`taxon_name` → `accepted_wcvp_name` → `accepted_wcvp_name_binomial`).
- `data/data_plant.rda`: updated with the WCVP columns.

---

## Step 4 — Update documentation and version

1. **Bump the version** in `DESCRIPTION` (e.g. `0.2.2` → `0.3.0`).
2. **Regenerate Rd files** from roxygen comments:
   ```r
   devtools::document()
   ```
3. **Check the package** builds cleanly:
   ```r
   devtools::check()
   ```
4. **Rebuild the pkgdown site** (optional but recommended before a release):
   ```r
   pkgdown::build_site()
   ```

---

## Step 5 — Export CSVs for EDI deposit

**Script:** `03_save_to_EDI.R`

Writes flat CSV files for all taxa (provisional data excluded) to `data-raw/edi/`
for deposit to the Environmental Data Initiative (EDI) repository.

```r
source("data-raw/03_save_to_EDI.R")
```

Upload the resulting CSVs to EDI and update the associated EML metadata to
reflect the new date range and any schema changes.

---

## Step 6 — Commit and push

```r
# Stage everything
git add data/ data-raw/plant_name_lookup*.csv data-raw/03_plant_names.R \
        man/ DESCRIPTION
git commit -m "update data to NEON <YEAR> release"
git push
```

Tag the release on GitHub after pushing:

```bash
git tag v0.3.0
git push origin v0.3.0
```

---

## File overview

| File | Purpose |
|------|---------|
| `00_taxon_clean.R` | Cleaning functions for each taxon group (`clean_neon_*()`) |
| `01_download_data.R` | Download raw NEON data → `NEON_raw_data/*.RDS` |
| `02_clean_save_data.R` | Clean + save all `data/*.rda` package datasets |
| `03_plant_names.R` | WCVP name standardisation for `data_plant` |
| `03_save_to_EDI.R` | Export CSVs for EDI deposit |
| `plant_name_lookup.csv` | Name-base (WCVP) match details for all species-level plant taxa (audit trail) |
| `plant_name_lookup_applied.csv` | Before/after plant name table |
| `NEON_raw_data/` | Timestamped raw RDS downloads (not committed to git) |
| `edi/` | CSV exports for EDI (not committed to git) |
