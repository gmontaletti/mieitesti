library(renv)
library(rvest)
library(data.table)

#  funzioni ----
source("R/funzioni.R")

#  esegui ----
autlink <- "https://www.ilsussidiario.net/autori/giampaolo-montaletti/"
articoli <- sussidiario(autore = autlink)
mieitesti <- lapply(articoli, leggi_pagine)

saveRDS(mieitesti, "data/mieitesti.rds")
