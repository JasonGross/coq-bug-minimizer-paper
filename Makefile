.SUFFIXES: .tex .pdf

LATEXFLAGS?=
LATEX_EXTRA_FLAGS?=
PDFLATEX?=pdflatex
BIBTEX?=bibtex

.PHONY: all
all: coq-bug-minimizer.pdf

.tex.pdf: $<.tex
	@ $(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) -synctex=1 $<
	@ $(BIBTEX) ${<:.tex=.aux}
	@ $(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) -synctex=1 $<
	@ $(PDFLATEX) $(LATEXFLAGS) $(LATEX_EXTRA_FLAGS) -synctex=1 $<

clean::
	@ rm -f *.aux *.out *.nav *.toc *.vrb *.pdf *.snm *.log *.bbl *.blg *.auxlock

EMBED_OPTS := -dPDFSETTINGS=/prepress -dSubsetFonts=true -dEmbedAllFonts=true -dMaxSubsetPct=100 -dCompatibilityLevel=1.3
# These are options to make 'ps2pdf' embed all fonts.
