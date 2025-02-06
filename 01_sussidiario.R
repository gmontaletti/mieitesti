# renv::install("tidyRSS")
library(renv)
library(rvest)
library(data.table)
library(tidyRSS)

#  funzioni ----
source("R/funzioni.R")


#  esegui ----
autlink <- "https://www.ilsussidiario.net/autori/giampaolo-montaletti/"
pagine <- lista_pagine(autlink)
colleziona(pagine[1])
articoli <- sussidiario(pagine[1])

articoli <- sussidiario(autore = autlink)
articoli
mieitesti <-parallel::mclapply(articoli, leggi_pagine)

saveRDS(mieitesti, "data/mieitesti.rds")
