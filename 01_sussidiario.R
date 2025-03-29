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
articoli <- sussidiario(autore = autlink)
articoli
mt <-parallel::mclapply(articoli, leggi_pagina)



#
mt <- data.frame(matrix(unlist(mt), nrow=length(mt), byrow=TRUE))
names(mt) <- c("data", "titolo", "text", "item_link")
setDT(mt)

saveRDS(mt, "data/mieitesti.rds")


# lavoro <- tidyfeed("https://www.ilsussidiario.net/feed/history/5100/lavoro/")
# rif_lav <- "https://www.ilsussidiario.net/feed/history/8220/riforma-lavoro/" %>% tidyfeed()
# form_lav <- "https://www.ilsussidiario.net/feed/history/8217/formazione-lavoro/" %>%  tidyfeed()
# gio_lav <- "https://www.ilsussidiario.net/feed/history/8222/giovani-famiglia-e-lavoro/" %>%  tidyfeed()
# cl <- "https://www.ilsussidiario.net/feed/history/7279/comunione-e-liberazione/" %>% tidyfeed()
