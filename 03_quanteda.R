# renv::install("unDocUMeantIt/sylly.it")
# renv::install("unDocUMeantIt/koRpus.lang.it")
# renv::install("spacyr")
# renv::install("tidytext")
# install("tm.plugin.koRpus")
# renv::install("quanteda/quanteda.textmodels")

library(renv)
renv::status()
renv::snapshot()
# renv::init()
library(ggplot2)
library(quanteda)
require(quanteda.textstats)
require(quanteda.textmodels)
require(quanteda.textplots)
require(quanteda.corpora)
# require(quanteda.dictionaries)
# require(spacyr)
require(seededlda)
require(lubridate)
require(tidytext)
require(data.table)

source("R/stopwords.R")

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

df$doc_id <- make.names(substring(df$titolo, 1, 20), unique = TRUE)
df$text <- apostrofo(df$text)
df$titolo <- apostrofo(df$titolo)
# df$testo <- tolower(df$testo)
# df$titolo <- tolower(df$titolo)

### corpus da df ----
mio <- corpus(df
               , docid_field = "doc_id"
               , text_field = "text"
               , list("data", "titolo"))

mio
mio |> summary()

#  statistiche corpus ----

textstat_summary(mio) %>%
  ggplot(aes(x = document, y = tokens, group = 1)) +
  geom_line(col = palette()[1]) +
  geom_point(col = palette()[2]) +
  scale_x_discrete (labels = NULL) +
  labs(x = "", y = "Tokens")


tokeninfo <- summary(mio)
tokeninfo$Year <- docvars(mio, "data")
with(tokeninfo, plot(data, Tokens, type = "b", pch = 19, cex = .7))
with(tokeninfo, plot(data, Types, type = "b", pch = 19, cex = .7))

ggplot(tokeninfo) +
  geom_line(aes(x = data, y= Tokens), col = "red") +
  geom_line(aes(x = data, y= Types), col = "green") +
  theme_minimal()

# longest
tokeninfo[which.max(tokeninfo$Tokens), ]

mio |> corpus_reshape(to = "sentences") |> length()


#  tokens -----

toc <- tokens(mio
              , remove_punct = T
              , remove_symbols = T
              , remove_numbers = T
              , remove_separators = T
) |>
  tokens_remove(pattern = miestop, padding = TRUE)

types(toc) |> length()

# topics classificazione ----

dfmat <- dfm(toc) %>%
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

# tmod_lda <- textmodel_lda(dfmat, k = 5)
#
# terms(tmod_lda, 9)

dict_topic <- dictionary(list(
  matching = c("mercat*", "denaro", "banc*", "stock*", "industr*", "pil", "salar*", "pover*")
, politica = c("parlament*", "govern*", "partit*", "parlamentar*", "politic*", "legislator*", "region*")
, ALMP  = c("formazio*", "programm*", "garanz*", "cpi", "agenz*", "support*", "gol", "orientament*")
, offerta = c("occupa*", "disoccupa*", "inattiv*", "classe et*", "forze", "lavor*", "ricerca lavor*", "offer*")
, domanda = c("competenz*", "skil*", "bisogn*", "domand*", "settor*", "impres*", "dator*")
))

# dictionary(file = "emp_dictionary.yml")
print(dict_topic)

tmod_slda <- textmodel_seededlda(dfmat, dictionary = dict_topic)

tmod_slda
terms(tmod_slda, 10)

docvars(mio, "gruppo") <- topics(tmod_slda)

mio |> summary()

# re-toc ----

toc <- tokens(mio
              , remove_punct = T
              , remove_symbols = T
              , remove_numbers = T
              , remove_separators = T
) |>
  tokens_remove(pattern = miestop, padding = TRUE)
toc


# keyness ----

dfmat <- dfm(toc, remove_padding = TRUE)

tstat_key <- textstat_keyness(dfmat, target = year(dfmat$data) > 2023)
textplot_keyness(tstat_key)

tstat_key <- textstat_keyness(dfmat, target = dfmat$gruppo == "ALMP")
textplot_keyness(tstat_key)

# cluster ----

tstat_dist <- as.dist(textstat_dist(dfmat))
clust <- hclust(tstat_dist)
plot(clust, xlab = "Distance", ylab = NULL)



#  wordcloud ----
set.seed(100)

dfmat_wcloud <- corpus_subset(mio, gruppo ==  "ALMP") |>
  tokens(remove_punct = TRUE) |>
  tokens_remove(pattern = stopwords('it')) |>
  dfm() |>
  dfm_trim(min_termfreq = 10, verbose = FALSE)
textplot_wordcloud(dfmat_wcloud, min_size = 1 , max_size = 10)


# lexical dispersion ----

toks_corpus_inaugural_subset <-
  corpus_subset(mio, gruppo == "ALMP") |>
  tokens()
kwic(toks_corpus_inaugural_subset, pattern = c("salari", "politiche") ) |>
  textplot_xray()
kwic(toks_corpus_inaugural_subset, pattern = c("salari", "politiche") ) |>
  textplot_xray(scale = "absolute")
kwic(toks_corpus_inaugural_subset, pattern = c("donne", "giovani", "politiche") ) |>
  textplot_xray()

# kwic ----

kw_lavor <- kwic(toc, pattern =  "lavor*")
head(kw_lavor, 10)

kw_law2 <- kwic(toc, pattern = c("lavor*", "disoc*"))
head(kw_law2, 10)


toks <- tokens_select(toc, pattern = stopwords("it", source = "snowball"), selection = "remove")
collocazione <- textstat_collocations(toks, size = 2, min_count = 5)

#  contesto ----

dmat_c <- dfm(toks, tolower = TRUE, remove_padding = TRUE)

dmat_c %>% textstat_frequency() |> head(30)

dfcm <- fcm(toks, context = "window", count = "frequency")

fcm_select(dfcm, pattern = colSums(dfcm) |>
             sort(decreasing = TRUE) |>
             head(30) |>
             names()) %>%
  textplot_network(min_freq = 3, edge_alpha = 0.5, edge_color = "grey")


#  frequency plot ----

# library("quanteda.textstats")
tstat_freq <- textstat_frequency(dfmat, n = 50)

ggplot(tstat_freq, aes(x = frequency, y = reorder(feature, frequency))) +
  geom_point() +
  labs(x = "Frequency", y = "Feature")


# Create document-level variable with year and president
# Get frequency grouped by president

freq_grouped <- textstat_frequency(dfmat, groups = gruppo)

# Filter the term "lep"
freq_american <- subset(freq_grouped, freq_grouped$feature %in% "salari")

ggplot(freq_american, aes(x = frequency, y = group)) +
  geom_point() +
  # scale_x_continuous(limits = c(0, 14), breaks = c(seq(0, 14, 2))) +
  labs(x = "Frequency", y = NULL,
       title = 'Frequency of "american"')


# serie storiche frequenze ----
freq_time <- textstat_frequency(dfmat, groups = data)
# filtra il termine "salari"

plotta_mensile <- function(x) {

freq_parola <- subset(freq_time, freq_time$feature %in% x)
setDT(freq_parola)

freq_parola[, .(N = sum(frequency)), .(data = yearmon(as.IDate(group)))] |>
   ggplot(aes(x = data, y = N)) +
  geom_line() +
  geom_smooth() +
  labs(x = "Frequency", y = NULL,
         subtitle = 'diffusione mensile'
       , title = x) +
  theme_minimal()

}

plotta_mensile("sussidi")


#  altri textmodels ----

??quanteda.textmodels

seq(-1.5, 1.5, .042) |> length()
tmod <- textmodel_wordscores(dfmat, y = c(seq(-1.5, 1.5, .042)))
summary(tmod)
coef(tmod)
predict(tmod)
predict(tmod, rescaling = "lbg")
predict(tmod, se.fit = TRUE, interval = "confidence", rescaling = "mv")


# lemmi tmod# lemmi -----
### stacyr lemmizzazione ----

# spacy.mio.toks <- mio %>%
#   # segmentazione
#   corpus() %>%
#   corpus_reshape("sentences") %>%
#   spacy_tokenize(remove_punct = T,
#                  remove_numbers = T,
#                  remove_symbols = T) %>%
#   as.tokens()
#
# spacy.mio.toks %>% summary() %>% head()
#
# mio.pos <- mio %>%
#   corpus() %>%
#   corpus_reshape(to = "sentences") %>%
#   spacy_parse()
#
# class(mio.pos)

# mio.pos <- as.data.frame(mio.pos)
# names(mio.pos)

# mio.lem <- mio.pos %>%
#   filter(pos != "PUNCT" ) %>%
#   as.tokens(use_lemma=T)

# segmentazione
# mioc.seg <- corpus_reshape(mio, to = "sentences")

# tokenizzazione
# tok.mioc.seg <- mioc.seg %>%
#   tokens(remove_punct = T,
#          remove_symbols = T,
#          remove_numbers = T)

### koRpus lemmizzazione  -----


### lemmi con tm e koRpus ----

# library(tm)
# library(tm.plugin.koRpus)
# set.kRp.env(lang="it",
#             TT.cmd = "manual",
#             TT.options=list(
#               path="/home/monty/tt",         # percorso di sistema
#               preset="it"
#             ))
#
# mioc <- df |> readCorpus(format = "obj")
#
# corpusTm(mioc)
# meta(corpusTm(mioc))
#
# head(taggedText(mioc))
#
#
# stok <- tokens(mio.lem)
# mia_div <- textstat_lexdiv(stok)
# plot(mia_div$TTR, type = "l", col = "blue", lwd = 2, xlab = "Documenti", ylab = "TTR")
#

# disattiviamo i pacchetti

