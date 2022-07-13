PPTX := coq-bug-minimizer-with-notes.pptx

all: $(PPTX)
.PHONY: all

define add_uncompress
uncompress::
	mkdir -p $(1)
	unzip -od $(1) $(1).pptx
	find $(1) -name "*.xml" | xargs sed -i 's/>/>\n/g'
endef

$(foreach p,$(PPTX:.pptx=),$(eval $(call add_uncompress,$(p))))


.SECONDEXPANSION:

$(PPTX:.pptx=.zip): %.zip : $$(wildcard %/* %/*/* %/*/*/* %/*/*/*/*)
	rm -f $@
	rm -rf $*.tmp
	cp -a $* $*.tmp
	for f in $$(find $*.tmp -name "*.xml"); do \
	  cat $$f | tr '\n' '\0' | sed 's/>\x0/>/g' | tr '\0' '\n' > $$f.bak; \
	  mv $$f.bak $$f; \
	done
	cd $*.tmp && zip -r ../$@ .

$(PPTX): %.pptx: %.zip
	cp $< $@

uncompress::
.PHONY: uncompress
