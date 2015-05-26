# Binaries
MKDIR_P = mkdir -p

# Directory locations
DATA = data
RAW = $(DATA)/raw
CACHE = $(DATA)/cache
DERIVED = $(DATA)/derived

DATA_ABSPATH = $(abspath $(DATA))
all: bigbeds

# Fetch chromosome sizes using docker container
chrom_sizes: $(CACHE)/hg19.sizes

$(CACHE)/hg19.sizes:
	$(MKDIR_P) $(CACHE)
	docker run bigbed fetchChromSizes hg19 > "$(CACHE)/hg19.sizes"

# expected bigbed files
bigbeds: chrom_sizes \
	$(DERIVED)/chr10_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr11_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr12_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr13_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr14_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr15_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr16_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr17_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr18_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr19_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr1_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr20_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr21_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr22_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr2_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr3_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr4_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr5_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr6_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr7_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr8_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chr9_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chrX_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb \
	$(DERIVED)/chrY_E2F1_SVR.model_SVRpredict_E2F1_SVR_SVR-scores_browser-track.bb

$(DERIVED)/%.bb: $(RAW)/bed/%.bed
	$(MKDIR_P) $(DERIVED)
	tail -n+6 $< > $<.headless
	docker run -v $(DATA_ABSPATH):/data \
	  bigbed \
	  bedToBigBed \
	  -type=bed4+1 \
	  -as=/$(RAW)/SVR.as \
	  /$<.headless \
	  /$(CACHE)/hg19.sizes \
	  /$@
	rm $<.headless

clean:
	rm -rf $(CACHE) $(DERIVED)

# TODO: hubcheck and build distribution dir
