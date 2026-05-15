SHELL := /bin/bash
.DEFAULT_GOAL := all

ROOT := $(CURDIR)
LATEXMK ?= latexmk
VERBOSE ?= 0

ENTRY_DIR := 95_Entries
PDF_DIR := 99_PDF
MAIN_DIR := 20_MainMatter

ONE_TEX := $(ENTRY_DIR)/01_Full/AMaN_One.tex
ONE_PDF := $(PDF_DIR)/01_Full/AMaN_One.pdf

TWO_TEX := $(ENTRY_DIR)/01_Full/AMaN_Two.tex
TWO_PDF := $(PDF_DIR)/01_Full/AMaN_Two.pdf

FULL_PDF := $(ONE_PDF) $(TWO_PDF)

PART01_TEX := $(ENTRY_DIR)/02_Parts/AMaN_Part01.tex
PART02_TEX := $(ENTRY_DIR)/02_Parts/AMaN_Part02.tex
PART03_TEX := $(ENTRY_DIR)/02_Parts/AMaN_Part03.tex
PART_TEX := $(PART01_TEX) $(PART02_TEX) $(PART03_TEX)

PART01_PDF := $(PDF_DIR)/02_Parts/AMaN_Part01.pdf
PART02_PDF := $(PDF_DIR)/02_Parts/AMaN_Part02.pdf
PART03_PDF := $(PDF_DIR)/02_Parts/AMaN_Part03.pdf
PART_PDF := $(PART01_PDF) $(PART02_PDF) $(PART03_PDF)

CHAP01_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap01.tex
CHAP02_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap02.tex
CHAP03_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap03.tex
CHAP04_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap04.tex
CHAP05_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap05.tex
CHAP06_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap06.tex
CHAP07_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap07.tex
CHAP08_TEX := $(ENTRY_DIR)/03_Chapters/AMaN_Chap08.tex
CHAP_TEX := $(CHAP01_TEX) $(CHAP02_TEX) $(CHAP03_TEX) $(CHAP04_TEX) \
            $(CHAP05_TEX) $(CHAP06_TEX) $(CHAP07_TEX) $(CHAP08_TEX)

CHAP01_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap01.pdf
CHAP02_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap02.pdf
CHAP03_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap03.pdf
CHAP04_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap04.pdf
CHAP05_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap05.pdf
CHAP06_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap06.pdf
CHAP07_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap07.pdf
CHAP08_PDF := $(PDF_DIR)/03_Chapters/AMaN_Chap08.pdf
CHAP_PDF := $(CHAP01_PDF) $(CHAP02_PDF) $(CHAP03_PDF) $(CHAP04_PDF) \
            $(CHAP05_PDF) $(CHAP06_PDF) $(CHAP07_PDF) $(CHAP08_PDF)

ALL_PDF := $(FULL_PDF) $(PART_PDF) $(CHAP_PDF)
LEGACY_ROOT_PDF := advmacro-one.pdf advmacro-two.pdf advmacro.pdf \
                   advmacro-part01.pdf advmacro-part02.pdf advmacro-part03.pdf \
                   advmacro-chap01.pdf advmacro-chap02.pdf advmacro-chap03.pdf advmacro-chap04.pdf \
                   advmacro-chap05.pdf advmacro-chap06.pdf advmacro-chap07.pdf advmacro-chap08.pdf \
                   AMaN_One.pdf AMaN_Two.pdf AMaN_Part01.pdf AMaN_Part02.pdf AMaN_Part03.pdf \
                   AMaN_Chap01.pdf AMaN_Chap02.pdf AMaN_Chap03.pdf AMaN_Chap04.pdf \
                   AMaN_Chap05.pdf AMaN_Chap06.pdf AMaN_Chap07.pdf AMaN_Chap08.pdf

.PHONY: all full one two parts chapters clean distclean vscode __run __build_pdf \
        $(ALL_PDF) \
        part01 part02 part03 \
        chap01 chap02 chap03 chap04 chap05 chap06 chap07 chap08

define run_targets
	@set -uo pipefail; \
	target_name="$(1)"; \
	items="$(2)"; \
	if [ -z "$$items" ]; then \
	  printf '\nAMaN LaTeX Build\n'; \
	  printf 'Result : FAILED\n'; \
	  printf 'Reason : no build target was resolved\n\n'; \
	  exit 2; \
	fi; \
	start_epoch=$$(date +%s); \
	start_text=$$(date '+%Y-%m-%d %H:%M:%S'); \
	fmt_time() { local t="$$1"; printf '%02d:%02d' $$((t / 60)) $$((t % 60)); }; \
	output_width=58; \
	for pdf in $$items; do \
	  if [ "$${#pdf}" -gt "$$output_width" ]; then output_width="$${#pdf}"; fi; \
	done; \
	output_rule="$$(printf '%*s' "$$output_width" '' | tr ' ' '-')"; \
	printf '\nAMaN LaTeX Build\n'; \
	printf '%s\n' '========================'; \
	printf 'Target  : %s\n' "$$target_name"; \
	printf 'Started : %s\n\n' "$$start_text"; \
	printf '%-8s %-*s %5s\n' "Status" "$$output_width" "Output" "Time"; \
	printf '%-8s %-*s %5s\n' "------" "$$output_width" "$$output_rule" "-----"; \
	status=0; \
	count=0; \
	for pdf in $$items; do \
	  count=$$((count + 1)); \
	  item_start=$$(date +%s); \
	  if "$(MAKE)" --no-print-directory --silent __build_pdf PDF="$$pdf"; then \
	    item_elapsed=$$(( $$(date +%s) - item_start )); \
	    item_time=$$(fmt_time "$$item_elapsed"); \
	    printf '%-8s %-*s %5s\n' "OK" "$$output_width" "$$pdf" "$$item_time"; \
	  else \
	    status=$$?; \
	    item_elapsed=$$(( $$(date +%s) - item_start )); \
	    item_time=$$(fmt_time "$$item_elapsed"); \
	    printf '%-8s %-*s %5s\n' "FAILED" "$$output_width" "$$pdf" "$$item_time"; \
	    break; \
	  fi; \
	done; \
	total_elapsed=$$(( $$(date +%s) - start_epoch )); \
	total_time=$$(fmt_time "$$total_elapsed"); \
	printf '\nSummary\n'; \
	printf '%s\n' '------------------------'; \
	if [ "$$status" -eq 0 ]; then \
	  printf 'Result : SUCCESS\n'; \
	else \
	  printf 'Result : FAILED\n'; \
	fi; \
	printf 'Items  : %s\n' "$$count"; \
	printf 'Total  : %s\n\n' "$$total_time"; \
	exit "$$status"
endef

all:
	$(call run_targets,all,$(ALL_PDF))

full:
	$(call run_targets,full,$(FULL_PDF))

one:
	$(call run_targets,one,$(ONE_PDF))

two:
	$(call run_targets,two,$(TWO_PDF))

parts:
	$(call run_targets,parts,$(PART_PDF))

chapters:
	$(call run_targets,chapters,$(CHAP_PDF))

part01:
	$(call run_targets,part01,$(PART01_PDF))

part02:
	$(call run_targets,part02,$(PART02_PDF))

part03:
	$(call run_targets,part03,$(PART03_PDF))

chap01:
	$(call run_targets,chap01,$(CHAP01_PDF))

chap02:
	$(call run_targets,chap02,$(CHAP02_PDF))

chap03:
	$(call run_targets,chap03,$(CHAP03_PDF))

chap04:
	$(call run_targets,chap04,$(CHAP04_PDF))

chap05:
	$(call run_targets,chap05,$(CHAP05_PDF))

chap06:
	$(call run_targets,chap06,$(CHAP06_PDF))

chap07:
	$(call run_targets,chap07,$(CHAP07_PDF))

chap08:
	$(call run_targets,chap08,$(CHAP08_PDF))

$(ALL_PDF):
	$(call run_targets,$@,$@)

__run:
	$(call run_targets,$(TARGET_NAME),$(TARGETS))

__build_pdf:
	@set -euo pipefail; \
	cd "$(ROOT)"; \
	pdf="$${PDF:?PDF is required}"; \
	case "$$pdf" in \
	  $(ONE_PDF)) tex="$(ONE_TEX)" ;; \
	  $(TWO_PDF)) tex="$(TWO_TEX)" ;; \
	  $(PDF_DIR)/02_Parts/AMaN_Part*.pdf) tex="$(ENTRY_DIR)/02_Parts/$$(basename "$${pdf%.pdf}").tex" ;; \
	  $(PDF_DIR)/03_Chapters/AMaN_Chap*.pdf) tex="$(ENTRY_DIR)/03_Chapters/$$(basename "$${pdf%.pdf}").tex" ;; \
	  *) printf 'Unknown PDF target: %s\n' "$$pdf"; exit 2 ;; \
	esac; \
	if [ ! -f "$$tex" ]; then \
	  printf 'Missing TeX entry: %s\n' "$$tex"; \
	  exit 2; \
	fi; \
	mkdir -p "$$(dirname "$$pdf")"; \
	tmp="$$(mktemp -d "$${TMPDIR:-/tmp}/aman-latex.XXXXXX")"; \
	log="$$tmp/latexmk.log"; \
	cleanup() { rm -rf "$$tmp"; }; \
	trap cleanup EXIT; \
	if [ "$(VERBOSE)" = "1" ]; then \
	  "$(LATEXMK)" -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$$tmp" "$$tex"; \
	else \
	  if "$(LATEXMK)" -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$$tmp" "$$tex" >"$$log" 2>&1; then \
	    :; \
	  else \
	    code=$$?; \
	    printf '\nLog excerpt for %s\n' "$$pdf"; \
	    printf '%s\n' '------------------------------------------'; \
	    tail -n 36 "$$log" | sed 's/^/  /'; \
	    printf '\n'; \
	    exit "$$code"; \
	  fi; \
	fi; \
	out="$$tmp/$$(basename "$$pdf")"; \
	if [ ! -f "$$out" ]; then \
	  printf 'Expected PDF was not produced: %s\n' "$$out"; \
	  exit 3; \
	fi; \
	cp "$$out" "$$pdf"

vscode:
	@set -euo pipefail; \
	cd "$(ROOT)"; \
	doc="$${DOC:-$(ONE_TEX)}"; \
	doc="$${doc%\"}"; \
	doc="$${doc#\"}"; \
	file="$$(basename "$$doc")"; \
	base="$${file%.tex}"; \
	target=""; \
	case "$$doc" in \
	  *$(MAIN_DIR)/01_Part01/PartCover.tex|*AMaN_Part01.tex) target="$(PART01_PDF)" ;; \
	  *$(MAIN_DIR)/02_Part02/PartCover.tex|*AMaN_Part02.tex) target="$(PART02_PDF)" ;; \
	  *$(MAIN_DIR)/03_Part03/PartCover.tex|*AMaN_Part03.tex) target="$(PART03_PDF)" ;; \
	  *$(MAIN_DIR)/01_Part01/Chap01.tex|*AMaN_Chap01.tex) target="$(CHAP01_PDF)" ;; \
	  *$(MAIN_DIR)/01_Part01/Chap02.tex|*AMaN_Chap02.tex) target="$(CHAP02_PDF)" ;; \
	  *$(MAIN_DIR)/02_Part02/Chap03.tex|*AMaN_Chap03.tex) target="$(CHAP03_PDF)" ;; \
	  *$(MAIN_DIR)/02_Part02/Chap04.tex|*AMaN_Chap04.tex) target="$(CHAP04_PDF)" ;; \
	  *$(MAIN_DIR)/02_Part02/Chap05.tex|*AMaN_Chap05.tex) target="$(CHAP05_PDF)" ;; \
	  *$(MAIN_DIR)/02_Part02/Chap06.tex|*AMaN_Chap06.tex) target="$(CHAP06_PDF)" ;; \
	  *$(MAIN_DIR)/02_Part02/Chap07.tex|*AMaN_Chap07.tex) target="$(CHAP07_PDF)" ;; \
	  *$(MAIN_DIR)/03_Part03/Chap08.tex|*AMaN_Chap08.tex) target="$(CHAP08_PDF)" ;; \
	  *AMaN_Two.tex) target="$(TWO_PDF)" ;; \
	  *AMaN_One.tex|*AMaN.tex|*10_FrontMatter/*|*90_BackMatter/*|*00_Config/*) target="$(ONE_PDF)" ;; \
	esac; \
	if [ -z "$$target" ]; then \
	  if [[ "$$base" =~ ^AMaN_Chap[0-9][0-9]$$ ]]; then \
	    target="$(PDF_DIR)/03_Chapters/$$base.pdf"; \
	  elif [[ "$$base" =~ ^AMaN_Part[0-9][0-9]$$ ]]; then \
	    target="$(PDF_DIR)/02_Parts/$$base.pdf"; \
	  elif [ "$$base" = "AMaN_Two" ]; then \
	    target="$(TWO_PDF)"; \
	  else \
	    target="$(ONE_PDF)"; \
	  fi; \
	fi; \
	"$(MAKE)" --no-print-directory --silent __run TARGET_NAME="vscode" TARGETS="$$target"

clean:
	@find "$(ROOT)" -type f \( \
	  -name '*.aux' -o -name '*.bbl' -o -name '*.bcf' -o -name '*.blg' \
	  -o -name '*.fdb_latexmk' -o -name '*.fls' -o -name '*.log' \
	  -o -name '*.out' -o -name '*.run.xml' -o -name '*.toc' \
	  -o -name '*.xdv' -o -name '*.synctex.gz' -o -name 'texput.log' \
	\) -delete
	@rm -rf "$(ROOT)/.latex-build"
	@printf 'Cleaned LaTeX auxiliary files.\n'

distclean: clean
	@set -euo pipefail; \
	for pdf in $(ALL_PDF) $(LEGACY_ROOT_PDF); do \
	  rm -f "$(ROOT)/$$pdf"; \
	done; \
	find "$(ROOT)/$(ENTRY_DIR)" -type f -name '*.pdf' -delete
	@printf 'Removed generated PDFs.\n'
