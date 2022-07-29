PPTX := coq-bug-minimizer-with-notes.pptx
XLSX := CI-job-timing.xlsx

all: $(PPTX) $(XLSX)
.PHONY: all


FIND_ARGS_NEWLINE_EXTS := -name "*.xml" -o -name "*.rels" -o -name "*.svg"

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
