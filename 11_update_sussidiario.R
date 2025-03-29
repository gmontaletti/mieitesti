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

mieitesti <- rbindlist(list(mieitesti, temp), fill = T)

mieitesti[, data := as.IDate(as.numeric(data))]

saveRDS(mieitesti, "data/mieitesti.rds")

cat(knitr::kable(
paste(mieitesti$titolo, "\n
      ", mieitesti$text, "\n
      ", mieitesti$data)
            )
, file = "testi/articoli.md")


