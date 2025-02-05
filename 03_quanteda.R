# renv::install("unDocUMeantIt/sylly.it")
# renv::install("unDocUMeantIt/koRpus.lang.it")
# renv::install("spacyr")
# renv::install("tidytext")
# install("tm.plugin.koRpus")

library(renv)
renv::status()
renv::snapshot()
# renv::init()
library(ggplot2)
library(quanteda)
require(quanteda.textstats)
require(quanteda.textplots)
require(quanteda.corpora)
# require(quanteda.dictionaries)
# require(spacyr)
require(seededlda)
require(lubridate)
require(tidytext)
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

# longest
tokeninfo[which.max(tokeninfo$Tokens), ]

ndoc(mio)
corp_sent <- mio |> corpus_reshape(to = "sentences")
print(corp_sent)
ndoc(corp_sent)
corp_sent |> summary()
corp_sent_long <- corpus_subset(corp_sent, ntoken(corp_sent) >= 50)
ndoc(corp_sent_long)


#  tokens -----

## stacyr lemmizzazione ----

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

# key ness ----

# corp_news <- download("data_corpus_guardian")
# summary(corp_news)

toc <- tokens(mio
              , remove_punct = T
              , remove_symbols = T
              , remove_numbers = T
              , remove_separators = T
              ) |>
  tokens_remove(pattern = miestop, padding = TRUE)

dfmat <- dfm(toc, remove_padding = TRUE)

tstat_key <- textstat_keyness(dfmat,
                              target = year(dfmat$data) > 2023)
textplot_keyness(tstat_key)

# cluster ----

tstat_dist <- as.dist(textstat_dist(dfmat))
clust <- hclust(tstat_dist)
plot(clust, xlab = "Distance", ylab = NULL)

# topics classificazione ----

dfmat_news <- dfm(toc) %>%
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

tmod_lda <- textmodel_lda(dfmat_news, k = 5)

terms(tmod_lda, 9)


# download.file("https://raw.githubusercontent.com/koheiw/seededlda/refs/heads/master/vignettes/pkgdown/dictionary.yml"
#               , destfile = "dictionary.yml")

dict_topic <- dictionary(file = "emp_dictionary.yml")
print(dict_topic)

tmod_slda <- textmodel_seededlda(dfmat_news, dictionary = dict_topic)

tmod_slda
terms(tmod_slda, 10)
cla_docs <- as.data.frame(topics(tmod_slda))

#  add to corpus

merge(df, topics(topics(tmod_slda)))




#  wordcloud ----

dfmat_wcloud <- corpus_subset(mio, year(data) >=  2022) |>
  tokens(remove_punct = TRUE) |>
  tokens_remove(pattern = stopwords('it')) |>
  dfm() |>
  dfm_trim(min_termfreq = 30, verbose = FALSE)

set.seed(100)
textplot_wordcloud(dfmat_wcloud, min_size = 1 , max_size = 10)


# lexical dispersion ----


toks_corpus_inaugural_subset <-
  corpus_subset(mio, year(data) >=  2022) |>
  tokens()
kwic(toks_corpus_inaugural_subset, pattern = c("salari", "politiche") ) |>
  textplot_xray()
kwic(toks_corpus_inaugural_subset, pattern = c("salari", "politiche") ) |>
  textplot_xray(scale = "absolute")
kwic(toks_corpus_inaugural_subset, pattern = c("occupazione", "salari", "politiche") ) |>
  textplot_xray()




# kwic ----

kw_lavor <- kwic(toc, pattern =  "lavor*")
head(kw_lavor, 10)

kw_law2 <- kwic(toc
                  , pattern = c("lavor*", "disoc*"))
head(kw_law2, 10)


toks <- tokens_select(toc, pattern = stopwords("it", source = "snowball"), selection = "remove")
collocazione <- textstat_collocations(toks, size = 2, min_count = 5)

dmat_c <- dfm(toks, tolower = TRUE, remove_padding = TRUE)

dmat_c %>% textstat_frequency()

dfcm <- fcm(toks, context = "document", count = "frequency")

dfcm %>% textplot_network(min_freq = 300, edge_alpha = 0.5, edge_color = "grey")


#  frequency plot ----


# library("quanteda.textstats")
tstat_freq_inaug <- textstat_frequency(dfmat, n = 50)

ggplot(tstat_freq_inaug, aes(x = frequency, y = reorder(feature, frequency))) +
  geom_point() +
  labs(x = "Frequency", y = "Feature")


# Create document-level variable with year and president
# Get frequency grouped by president

freq_grouped <- textstat_frequency(,groups = President)

# Filter the term "american"
freq_american <- subset(freq_grouped, freq_grouped$feature %in% "american")

ggplot(freq_american, aes(x = frequency, y = group)) +
  geom_point() +
  scale_x_continuous(limits = c(0, 14), breaks = c(seq(0, 14, 2))) +
  labs(x = "Frequency", y = NULL,
       title = 'Frequency of "american"')

