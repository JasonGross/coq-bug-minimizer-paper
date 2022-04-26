.SUFFIXES: .tex .pdf

V = 0

Q_0 := @
Q_1 :=
Q = $(Q_$(V))
HIDE = $(Q)

VECHO_0 := @echo ""
VECHO_1 := @true ""
VECHO = $(VECHO_$(V))
SHOW = $(VECHO)

LATEXFLAGS?=--synctex=1 --shell-escape
LATEX_EXTRA_FLAGS?=
PDFLATEX?=pdflatex
BIBTEX?=bibtex

PDFS := coq-bug-minimizer.pdf

CAMERA_READY_FILES := coq-bug-minimizer.bib coq-bug-minimizer.tex cc-by.pdf lipics-logo-bw.pdf lipics-v2021.cls orcid.pdf
CAMERA_READY_ZIP := camera-ready.zip

.PHONY: all camera-ready
all: $(PDFS) $(CAMERA_READY_ZIP)

camera-ready: $(CAMERA_READY_ZIP)

$(CAMERA_READY_ZIP): $(CAMERA_READY_FILES)
	rm -f $@
	zip -r $@ $(CAMERA_READY_FILES)

coq-bug-minimizer.pdf: coq-bug-minimizer.bib

.tex.pdf: $<.tex
	$(SHOW)"PDFLATEX (run 1)"
	$(HIDE)$(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) $<
	$(SHOW)"BIBTEX"
	$(HIDE)rm -f $*-bibtex.ok
	$(HIDE)($(BIBTEX) ${<:.tex=.aux} 2>&1 && touch $*-bibtex.ok) | tee $*-bibtex.log
	$(HIDE)rm $*-bibtex.ok
	$(SHOW)"PDFLATEX (run 2)"
	$(HIDE)$(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) --interaction=nonstopmode $< 2>&1 >/dev/null || true
	$(SHOW)"PDFLATEX (run 3)"
	$(HIDE)$(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) $<

.PHONY: clean
clean::
	@ rm -f *.aux *.out *.nav *.toc *.vrb *.snm *.log *.bbl *.blg *.auxlock $(PDFS)
