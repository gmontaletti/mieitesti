# mieitesti 0.1.1

* Fixed `pag_as_frame()` bug: changed `byrow=FALSE` to `byrow=TRUE` to correctly assign columns
* Added input validation in `pag_as_frame()` to filter NULL and malformed entries
* Added tests for column assignment and malformed input handling

# mieitesti 0.1.0

* Initial release
* Core scraping functions: `sussidiario()`, `leggi_pagina()`, `pag_as_frame()`
* ISTAT RSS support: `sintesi()`, `istat_feeds()`
* Text utilities: `apostrofo()`
* Package data: `miestop` (Italian stopwords), `emp_dictionary` (topic dictionary)
* Vignettes for text analysis and ISTAT feeds workflows
