# renv::install("tidyRSS")
library(renv)
library(rvest)
library(data.table)
library(tidyRSS)

#  funzioni ----
Sys.setlocale(category = "LC_ALL", locale = "it_IT.UTF-8")

istat_feeds <- c(
                   "https://www.istat.it/feed"
                 , "https://www.istat.it/tema/lavoro-e-retribuzioni/feed"
                 , "https://www.istat.it/documenti/comunicato-stampa/feed"
                 , "https://www.istat.it/documenti/tavole-di-dati/feed"
                 , "https://www.istat.it/documenti/audizioni/feed"
                 # , "https://www.istat.it/documenti/rapporti/feed"
                 )


istat <- rbindlist(lapply(istat_feeds, tidyfeed), fill = T) |> unique( by = "item_link")

istat <- istat[order(-item_pub_date)]


sintesi <- function(x) {
  # x = 4
  miapag <- rvest::read_html(istat$item_link[x])
  testo <- miapag |>
    html_elements(".guid-article") |>
    html_text2()

print(paste(
  istat$item_pub_date[x]
  , " - "
  , istat$item_title[x]
  , ". "
  , istat$item_description[x]
  , ". "
  , gsub("\\r|\\n", " ", testo)))

  mylinks <- miapag |>
    html_nodes("a") |>
    html_attr("href")

  documenti <- c(mylinks[grepl("pdf", mylinks)], mylinks[grepl("xls", mylinks)])

  print(documenti)

  # download.file(documenti[2], destfile = make.names(documenti[2]))


  }
sintesi(1) |> knitr::kable()


