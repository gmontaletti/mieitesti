# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Text collection and analysis project for archiving articles from "il sussidiario" (Italian news publication) focused on labor market and employment topics. Author: Giampaolo Montaletti.

## Common Commands

```bash
# Activate renv environment (auto-runs via .Rprofile)
source("renv/activate.R")

# Full article collection from scratch
Rscript 01_sussidiario.R

# Incremental update via RSS (preferred for updates)
Rscript 11_update_sussidiario.R

# Text analysis pipeline
Rscript 02_wclouds.R      # Word clouds
Rscript 03_quanteda.R     # Full quanteda analysis
Rscript 04_semantic_network.R  # Lemmatization (requires TreeTagger)

# ISTAT RSS aggregation
Rscript 12_istat_rss.R
```

## Architecture

### Data Flow
```
01_sussidiario.R → data/mieitesti.rds → [02, 03, 04 analysis scripts]
                                      ↓
11_update_sussidiario.R ←─────────────┘ (incremental updates)
                      ↓
             testi/articoli.md (markdown export)
```

### Script Numbering Convention
- `01-09`: Core data collection
- `11-19`: Update/maintenance scripts
- `02-04`: Analysis scripts (word clouds, quanteda, semantic networks)

### Key Files
- `data/mieitesti.rds`: Main article database (data.table: data, titolo, text, item_link)
- `R/funzioni.R`: Web scraping utilities (lista_pagine, colleziona, sussidiario, leggi_pagina)
- `R/stopwords.R`: Italian stopwords configuration
- `emp_dictionary.yml`: Topic dictionary for seededlda (match, politica, pal, offerta, domanda)

### External Dependencies
- TreeTagger: Required for `04_semantic_network.R` lemmatization (expects installation at `/home/monty/tt`)
- spacyr/spaCy: Optional NLP (commented in `03_quanteda.R`)

## Code Style

- R section comments: `# 1. section name -----`
- Locale: Italian (it_IT.UTF-8)
- Data format: data.table for efficiency
- Dependencies managed via renv
