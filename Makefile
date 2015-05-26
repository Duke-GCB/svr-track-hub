# Binaries
MKDIR_P = mkdir -p

# Directory locations
DATA = data
RAW = $(DATA)/raw
CACHE = $(DATA)/cache
DERIVED = $(DATA)/derived

DATA_ABSPATH = $(abspath $(DATA))

# BED files in text format without headers
BED_SOURCES = $(wildcard $(RAW)/bed/*.bed)
BED_HEADLESS = $(DERIVED)/headless
BED_HEADLESSES = $(patsubst data/raw/bed/%.bed, data/derived/headless/%.bed, $(BED_SOURCES))

# Combined BED files
BED_COMBINED = $(DERIVED)/combined

# Targets
all: bigbed

# Fetch chromosome sizes using docker container
chrom_sizes: $(CACHE)/hg19.sizes

$(CACHE)/hg19.sizes:
	$(MKDIR_P) $(CACHE)
	docker run bigbed fetchChromSizes hg19 > "$(CACHE)/hg19.sizes"

bigbed: \
	$(DERIVED)/combined_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb

# Making a .bb file with bedToBigBed depends on the combined .bed file and the chrom_sizes
$(DERIVED)/%.bb: $(BED_COMBINED)/%.bed chrom_sizes
	$(MKDIR_P) $(DERIVED)
	docker run -v $(DATA_ABSPATH):/data \
	  bigbed \
	  bedToBigBed \
	  -type=bed4+1 \
	  -as=/$(RAW)/SVR.as \
	  /$< \
	  /$(CACHE)/hg19.sizes \
	  /$@

# Intermediate steps for combining
bed_combined: bed_headlesses $(BED_COMBINED)/combined_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bed

# The combined .bed file depends on its parts - the headless BED files from each chrom
#
# Explanation of steps
# cat: combine all headless files
# sort: files must be sorted by chromosome then start index
# cut: source files are bedGraph format with a 'name' column between 'end' and 'value'
#   bedGraphToBigWig requires 'chrom', 'start', 'end', 'data', so we cut out 'name'
$(BED_COMBINED)/%.bed: bed_headlesses
	$(MKDIR_P) $(BED_COMBINED)
	cat $(BED_HEADLESS)/*.bed | sort -k1,1 -k2,2n |  cut -d ' ' -f 1-3,5 > $@

# The target to make the headless files, expanded from above patsubst
bed_headlesses: $(BED_HEADLESSES)

# Generic rule to make a headless file - depends on its raw headed file
$(BED_HEADLESS)/%.bed: $(RAW)/bed/%.bed
	$(MKDIR_P) $(BED_HEADLESS)
	tail -n+6 $< > $@

clean:
	rm -rf $(CACHE) $(DERIVED)

# TODO: hubcheck and build distribution dir
