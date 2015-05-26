# Binaries
MKDIR_P = mkdir -p

# Directory locations
DATA = data
RAW = $(DATA)/raw
CACHE = $(DATA)/cache
DERIVED = $(DATA)/derived

DATA_ABSPATH = $(abspath $(DATA))

# BED files in text format without headers
BED_HEADLESS = $(DERIVED)/headless

# Combined BED files
BED_COMBINED = $(DERIVED)/combined

# Targets
all: bigbed

# Fetch chromosome sizes using docker container
chrom_sizes: $(CACHE)/hg19.sizes

$(CACHE)/hg19.sizes:
	$(MKDIR_P) $(CACHE)
	docker run bigbed fetchChromSizes hg19 > "$(CACHE)/hg19.sizes"

bigbed: chrom_sizes $(DERIVED)/combined_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb

# Master bigbed
$(DERIVED)/%.bb: $(BED_COMBINED)/%.bed
	$(MKDIR_P) $(DERIVED)
	docker run -v $(DATA_ABSPATH):/data \
	  bigbed \
	  bedToBigBed \
	  -type=bed4+1 \
	  -as=/$(RAW)/SVR.as \
	  /$< \
	  /$(CACHE)/hg19.sizes \
	  /$@

# Combining headless BED files
bed_combined: bed_headless $(BED_COMBINED)/combined_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bed

bed_headless: \
	$(BED_HEADLESS)/chrY_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bed \
	$(BED_HEADLESS)/chrX_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bed

$(BED_COMBINED)/%.bed:
	$(MKDIR_P) $(BED_COMBINED)
	cat $(BED_HEADLESS)/*.bed > $@

$(BED_HEADLESS)/%.bed: $(RAW)/bed/%.bed
	$(MKDIR_P) $(BED_HEADLESS)
	tail -n+6 $< > $@

clean:
	rm -rf $(CACHE) $(DERIVED)

# TODO: hubcheck and build distribution dir
