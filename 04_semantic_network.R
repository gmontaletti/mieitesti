library(renv)
renv::status()
renv::snapshot()
# renv::init()
# library(ggplot2)
library(quanteda)
# require(quanteda.textstats)
require(quanteda.textplots)
# require(quanteda.corpora)
# require(quanteda.dictionaries)
# require(spacyr)
# require(seededlda)
# require(lubridate)
# require(tidytext)
require(data.table)

Sys.setlocale(category = "LC_ALL", locale = "it_IT.UTF-8")
quanteda_options(language_stemmer ="italian")

apostrofo <- function (x) {
  stringr::str_replace_all(x, "[\'’](?!\\s)", "' ")
}

# corpus ----
### genera df da lista ----

mieitesti <- readRDS("data/mieitesti.rds")
df <- data.frame(matrix(unlist(mieitesti), nrow=length(mieitesti), byrow=TRUE))
names(df) <- c("data", "titolo", "text")

df$data <- as.Date(as.numeric(df$data))
df <- df[df$data >= as.Date("2021-01-10"), ]

df$doc_id <- make.names(paste(substring(df$titolo, 1, 11), df$data))
df$text <- apostrofo(df$text)
df$titolo <- apostrofo(df$titolo)

# lemmizza con koRpus ----

detach("package:quanteda")
library(koRpus.lang.it)

tagged.sep <- treetag(
  df$text,
  format = "obj",                 # oggetto interno, e non file esterno
  lang="it",
  doc_id = "mio",                 # identificativo
  sentc.end = c(".", "!", "?"),   # confini delle frasi
  treetagger="manual",            # indicare le successive opzioni
  TT.options=list(
    path="/home/monty/tt",         # percorso di sistema
    preset="it"
  )
)

head(tagged.sep@tokens)

ttmio <- taggedText(tagged.sep)

setDT(ttmio)
ttmio[, .N, wclass]
ttmio <- ttmio[wclass %in% c("noun", "verb", "adverb", "name", "adjective") &
                 !lemma %in% c("@card@",  "<unknown>") ]

ttmio[, .N, lemma][order(-N)][1:20]


detach("package:koRpus.lang.it")
# detach("package:tm.plugin.koRpus")
detach("package:koRpus")


## stopwors ----

library(quanteda)
quanteda_options(language_stemmer ="italian")



tok <- list(ttmio$lemma) |> tokens()

source("R/stopwords.R")

#  fcm ----



toks <- tokens(tok, remove_punct = TRUE
               , remove_numbers = TRUE
               , remove_symbols = TRUE
               , remove_url = TRUE
               , remove_separators = TRUE
               , remove_hyphens = TRUE
               , split_hyphens = TRUE
               , padding = TRUE
               , include_docvars = TRUE)

toks <- toks |>
  tokens_remove(pattern = miestop, padding = TRUE)

fcmat <- fcm(toks, context = "window", tri = FALSE)

colSums(fcmat) |>
  sort(decreasing = TRUE) |>
  head(40) |>
  names()

fcm_select(fcmat, pattern = colSums(fcmat) |>
             sort(decreasing = TRUE) |>
             head(30) |>
             names()) |>
  textplot_network(min_freq = 5)


