# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

R package for collecting and analyzing Italian news articles from "il sussidiario" and ISTAT RSS feeds. Author: Giampaolo Montaletti.

## Common Commands

```bash
# Install package locally
R CMD INSTALL .

# Or via devtools
Rscript -e "devtools::install()"

# Generate documentation (NAMESPACE, man/)
Rscript -e "devtools::document()"

# Run tests
Rscript -e "devtools::test()"

# Full package check
Rscript -e "devtools::check()"

# Build package
R CMD build .

# Regenerate package data
Rscript data-raw/stopwords.R
Rscript data-raw/emp_dictionary.R
```

## Package Structure

```
R/
├── mieitesti-package.R  # Package documentation
├── scraping.R           # sussidiario(), lista_pagine(), colleziona()
├── parsing.R            # leggi_pagina(), pag_as_frame()
├── text-utils.R         # apostrofo(), miostring()
├── istat.R              # sintesi(), istat_feeds()
└── data.R               # Data documentation (miestop, emp_dictionary)

data/                    # Package data (.rda files)
data-raw/                # Scripts to generate data
tests/testthat/          # Unit tests
vignettes/               # Package vignettes
```

## Exported Functions

- `sussidiario(autore)` - Collect all articles from an author
- `leggi_pagina(x)` - Parse a single article page
- `pag_as_frame(lista)` - Convert article list to data.table
- `sintesi(x, istat)` - Extract ISTAT article summaries
- `istat_feeds()` - Get default ISTAT RSS feed URLs
- `apostrofo(x)` - Normalize Italian apostrophes

## Package Data

- `miestop` - Italian stopwords (685 terms)
- `emp_dictionary` - Employment topic dictionary for seeded LDA

## Code Style

- R section comments: `# 1. section name -----`
- roxygen2 documentation for all exported functions
- testthat for unit tests
