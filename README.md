# mieitesti

<!-- badges: start -->
[![R-CMD-check](https://github.com/gmontaletti/mieitesti/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/gmontaletti/mieitesti/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Tools for collecting and analyzing Italian news articles from 'il sussidiario'
and ISTAT RSS feeds.

## Installation

Install from GitHub:
```r
# install.packages("devtools")
devtools::install_github("gmontaletti/mieitesti")
```

## Usage

### Collecting articles from il sussidiario

```r
library(mieitesti)

autlink <- "https://www.ilsussidiario.net/autori/giampaolo-montaletti/"
articoli <- sussidiario(autore = autlink)
mt <- parallel::mclapply(articoli, leggi_pagina)
df <- pag_as_frame(mt)
```

### Text preprocessing

```r
# Normalize Italian apostrophes for better tokenization
df$text <- apostrofo(df$text)

# Use Italian stopwords
library(quanteda)
toks <- tokens(corpus(df, text_field = "text")) |>
  tokens_remove(miestop)
```

### ISTAT RSS feeds

```r
library(tidyRSS)
library(data.table)

# Get feed URLs
feeds <- istat_feeds()

# Collect data
istat <- rbindlist(lapply(feeds, tidyfeed), fill = TRUE) |>
  unique(by = "item_link")

# Extract article summary and documents
docs <- sintesi(1, istat)
```

### Topic modeling

```r
library(quanteda)
library(seededlda)

# Use the employment dictionary for seeded LDA
dict <- dictionary(emp_dictionary)
```

## Citation

```
@software{montaletti2025mieitesti,
  author = {Montaletti, Giampaolo},
  title = {mieitesti: Italian News Article Collection and Text Analysis Tools},
  year = {2025},
  url = {https://github.com/gmontaletti/mieitesti}
}
```

## Author

Giampaolo Montaletti ([giampaolo.montaletti@gmail.com](mailto:giampaolo.montaletti@gmail.com))

ORCID: [0009-0002-5327-1122](https://orcid.org/0009-0002-5327-1122)

## License

MIT
