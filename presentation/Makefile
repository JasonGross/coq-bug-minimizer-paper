PPTX := coq-bug-minimizer-with-notes.pptx coq-bug-minimizer.pptx
XLSX := CI-job-timing.xlsx
PDFS := ci-timing-data-box-whisker.pdf

all: $(PPTX) $(XLSX) $(PDFS)
pptx: $(PPTX)
.PHONY: all pdf pptx strip

PDFLATEX?=lualatex # pdflatex
LATEXFLAGS?=--shell-escape --synctex=1
LATEX_EXTRA_FLAGS?=
MD5?=md5sum

pdf: $(PDFS)

%.md5: %
	$(MD5) '$<' | awk '{print $$1}' > '$@'

ci-timing-data-box-whisker.pdf: ci-durations-sorted-2022.csv.md5 ci-boxplots.lst ci-boxplots.lst.tex ci-boxplots.all.tex ci-boxplots.all.tex.md5

ci-boxplots.lst: ci-jobs-by-ave-duration-2022.json
	jq -crs 'sort_by(.ave_success_duration) | map(.name) | (.[:10] + .[-10:]) as $$interesting | .[] | . as $$n | select((["bbv", "bedrock2", "color", "fiat_crypto_legacy", "gappa", "itauto", "rewriter", "verdi_raft", "vst"]+$$interesting) | index($$n) != null)' $< > $@

ci-boxplots.lst.tex: ci-boxplots.lst
	cat $< | sed 's|^\(.*\)$$|\\einput{ci-timing-by-job/\1-2022-failed.txt.md5}\\einput{ci-timing-by-job/\1-2022-success.txt.md5}|g' > $@

add_success_failure = $(addsuffix -2022-failed,$(1)) $(addsuffix -2022-success,$(1))

ci-timing-data-box-whisker.pdf: $(addprefix ci-timing-by-job/,$(addsuffix .txt.md5,$(call add_success_failure,$(shell cat ci-boxplots.lst))))

ADD_PLOT_BOXPLOT=\\addplot+[boxplot,$(1)] table[y index=0]
ci-boxplots.all.tex: ci-boxplots.lst
	cat $< | sed 's|^\(.*\)$$|\\message{\1-success }$(call ADD_PLOT_BOXPLOT,green){ci-timing-by-job/\1-2022-success.txt}; \\message{\1-failed }$(call ADD_PLOT_BOXPLOT,red){ci-timing-by-job/\1-2022-failed.txt};|g' > $@


$(PDFS): %.pdf : %.tex
	@ $(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) $<
	@ $(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) $<

FIND_ARGS_NEWLINE_EXTS := -name "*.xml" -o -name "*.rels" -o -name "*.svg"

.PHONY: strip

define add_strip
.PHONY: strip-$(1)
strip:: strip-$(1)

strip-$(1):
	rm -rf $(3)
	cp -a $(2) $(3)
	rm -rf $(3)/ppt/notesSlides
	grep -v notesSlides '$(3)/[Content_Types].xml' > '$(3)/[Content_Types].xml.tmp'
	mv '$(3)/[Content_Types].xml.tmp' '$(3)/[Content_Types].xml'
	sed -i 's,^.*notesSlide.*$$$$,,g' $(3)/ppt/slides/_rels/slide*.xml.rels
endef

define add_uncompress
uncompress::
	rm -rf $(1)
	mkdir -p $(1)
	unzip -od $(1) $(1).pptx
	for f in $$$$(find $(1) -name "*.xlsx"); do \
	  unzip -od "$$$$f.dir" "$$$$f"; \
	  rm -f "$$$$f"; \
	done
	find "$(1)" $(FIND_ARGS_NEWLINE_EXTS) | xargs sed -i 's/>/>\n/g'
endef

define add_uncompress_xlsx
uncompress::
	rm -rf $(1)
	mkdir -p $(1)
	unzip -od $(1) $(1).xlsx
	find "$(1)" $(FIND_ARGS_NEWLINE_EXTS) | xargs sed -i 's/>/>\n/g'
endef

$(foreach p,$(PPTX:.pptx=),$(eval $(call add_uncompress,$(p))))
$(foreach p,$(XLSX:.xlsx=),$(eval $(call add_uncompress_xlsx,$(p))))


.SECONDEXPANSION:

$(PPTX:.pptx=.zip): %.zip : $$(wildcard %/* %/*/* %/*/*/* %/*/*/*/*)
	rm -f $@
	rm -rf $*.tmp
	cp -a $* $*.tmp
	for f in $$(find $*.tmp $(FIND_ARGS_NEWLINE_EXTS)); do \
	  cat "$$f" | tr '\n' '\0' | sed 's/>\x0/>/g' | tr '\0' '\n' > "$$f.bak"; \
	  mv "$$f.bak" "$$f"; \
	done
	for f in $$(find "$$(pwd)/$*.tmp" -name "*.xlsx.dir" -type d | sed 's/\.dir$$//g'); do \
	  rm -f "$$f"; \
	  (cd "$$f.dir" && zip -r "../$$(basename "$$f")" . ); \
	  rm -rf "$$f.dir"; \
	done
	cd "$*.tmp" && zip -r "../$@" .

$(XLSX:.xlsx=.zip): %.zip : $$(wildcard %/* %/*/* %/*/*/* %/*/*/*/*)
	rm -f $@
	rm -rf $*.tmp
	cp -a $* $*.tmp
	for f in $$(find $*.tmp $(FIND_ARGS_NEWLINE_EXTS)); do \
	  cat "$$f" | tr '\n' '\0' | sed 's/>\x0/>/g' | tr '\0' '\n' > "$$f.bak"; \
	  mv "$$f.bak" "$$f"; \
	done
	cd "$*.tmp" && zip -r "../$@" .

$(PPTX): %.pptx: %.zip
	cp "$<" "$@"

$(XLSX): %.xlsx: %.zip
	cp "$<" "$@"

uncompress::
.PHONY: uncompress

$(eval $(call add_strip,coq-bug-minimizer,coq-bug-minimizer-with-notes,coq-bug-minimizer))
