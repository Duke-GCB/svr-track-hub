# Binaries
MKDIR_P = mkdir -p

# Directory locations
DATA = data
DOCKER = docker
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
BED_MERGED = $(DERIVED)/merged

# Targets
all: docker_image

# Fetch chromosome sizes using docker container
chrom_sizes: $(CACHE)/hg19.sizes

$(CACHE)/hg19.sizes:
	$(MKDIR_P) $(CACHE)
	docker run hubutils fetchChromSizes hg19 > "$(CACHE)/hg19.sizes"

bigwig: \
	$(DERIVED)/combined_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bw

# Making a .bw file with bedGraphToBigWig depends on the combined .bed file and the chrom_sizes
$(DERIVED)/%.bw: $(BED_MERGED)/%.bed chrom_sizes
	$(MKDIR_P) $(DERIVED)
	docker run -v $(DATA_ABSPATH):/data \
	  hubutils \
	  bedGraphToBigWig \
	  /$< \
	  /$(CACHE)/hg19.sizes \
	  /$@

# Intermediate steps for combining
bed_combined: bed_headlesses $(BED_COMBINED)/combined_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bed

bed_merged: bed_combined $(BED_MERGED)/combined_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bed

# The combined .bed file depends on its parts - the headless BED files from each chrom
#
# Explanation of steps
# cat: combine all headless files
# sort: files must be sorted by chromosome then start index
# tr: bedtools merge requires tab-delimeted files
$(BED_COMBINED)/%.bed: bed_headlesses
	$(MKDIR_P) $(BED_COMBINED)
	cat $(BED_HEADLESS)/*.bed | sort -k1,1 -k2,2n | tr ' ' '\t' > $@

$(BED_MERGED)/%.bed: $(BED_COMBINED)/%.bed
	$(MKDIR_P) $(BED_MERGED)
	docker run -v $(DATA_ABSPATH):/data hubutils bedtools merge -scores mean -i /$< > $@

# The target to make the headless files, expanded from above patsubst
bed_headlesses: $(BED_HEADLESSES)

# Generic rule to make a headless file - depends on its raw headed file
$(BED_HEADLESS)/%.bed: $(RAW)/bed/%.bed
	$(MKDIR_P) $(BED_HEADLESS)
	tail -n+6 $< > $@

clean:
	rm -rf $(CACHE) $(DERIVED)

# Location of the template directory to copy
HUB_SOURCE=$(RAW)/web
HUB_BUILD=$(DERIVED)/hub
DOCKERFILE=$(DOCKER)/svr-track-hub-web/Dockerfile
DOCKERIMAGE=dukegcb/svr-track-hub-web

docker_image: bigwig hub_root
	cp $(DERIVED)/*.bb $(HUB_BUILD)/hub-root/hg19/
	cd $(HUB_BUILD) && docker build -t $(DOCKERIMAGE) .

hub_root: $(HUB_BUILD)

$(HUB_BUILD):
	cp -r $(HUB_SOURCE) $@
	cp $(DOCKERFILE) $@/

hubcheck:
	docker run -d -P --name hub $(DOCKERIMAGE); \
	echo "Checking hub..."; \
	docker run --link hub:hub hubutils sh -c "hubCheck http://\$$HUB_PORT_80_TCP_ADDR:\$$HUB_PORT_80_TCP_PORT/hub.txt"; \
	docker kill hub; \
	docker rm hub; \
	echo "Done."
