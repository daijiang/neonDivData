# Makefile for neonDivData annual update pipeline
#
# Typical usage each year:
#   make all          # run the full pipeline, skipping completed steps
#   make download     # step 1 only (1-2 days; needs NEON_TOKEN in environment)
#   make clean-data   # step 2 only
#   make plants       # step 3 only
#   make check        # R CMD CHECK
#
# To force a full re-run from scratch:
#   rm -f $(SENTINEL) && make all
#
# NEON_TOKEN must be set in your environment before running step 1:
#   export NEON_TOKEN=your_token_here
#   (or add it to ~/.Renviron as NEON_TOKEN=your_token_here)

.PHONY: all download clean-data plants check

# Sentinel file touched after step 1 completes (avoids re-downloading if RDS files exist)
SENTINEL   := data-raw/NEON_raw_data/.last_download

# Track neon_taxa.rda as a proxy for all step-2 outputs
CLEAN_DONE := data/neon_taxa.rda

# Step-3 output: plant name lookup cache (also updates data/data_plant.rda)
LOOKUP     := data-raw/plant_name_lookup.csv

# ── Default target ────────────────────────────────────────────────────────────
all: $(LOOKUP)

# ── Step 1: download raw NEON data (slow, ~1-2 days) ─────────────────────────
$(SENTINEL):
	Rscript data-raw/01_download_data.R
	touch $@

download: $(SENTINEL)

# ── Step 2: clean and save package data ──────────────────────────────────────
$(CLEAN_DONE): $(SENTINEL)
	Rscript data-raw/02_clean_save_data.R

clean-data: $(CLEAN_DONE)

# ── Step 3: standardise plant names against WCVP ─────────────────────────────
$(LOOKUP): $(CLEAN_DONE)
	Rscript data-raw/03_plant_names.R

plants: $(LOOKUP)

# ── R CMD CHECK ───────────────────────────────────────────────────────────────
check:
	Rscript -e "devtools::check()"
