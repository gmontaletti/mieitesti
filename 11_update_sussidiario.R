library(renv)
library(rvest)
library(data.table)
library(tidyRSS)

#  funzioni ----

source("R/funzioni.R")

df <- tidyfeed("https://www.ilsussidiario.net/feed/autore/914/giampaolo-montaletti/") |> setDT()

mieitesti <- readRDS(file = "data/mieitesti.rds")



ndf <- df[!mieitesti, on = "item_link"]

newndf <- leggi_pagina(ndf$item_link)


temp <- pag_as_frame(lista = newndf)

mieitesti <- rebind
