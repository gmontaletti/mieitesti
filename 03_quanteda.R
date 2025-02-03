# renv::install("seededlda")
library(renv)
library(ggplot2)
renv::status()
renv::snapshot()
# renv::init()
library(quanteda)
require(quanteda.textstats)
require(quanteda.textplots)
require(quanteda.corpora)
# require(quanteda.dictionaries)
require(seededlda)
require(lubridate)

Sys.setlocale(category = "LC_ALL", locale = "it_IT.UTF-8")
quanteda_options(language_stemmer ="italian")

apostrofo <- function (x) {
  stringr::str_replace_all(x, "[\'’](?!\\s)", "' ")
}

# genera corpus da lista ----

mieitesti <- readRDS("data/mieitesti.rds")
df <- data.frame(matrix(unlist(mieitesti), nrow=length(mieitesti), byrow=TRUE))
names(df) <- c("data", "titolo", "testo")

df$data <- as.Date(as.numeric(df$data))
df <- df[df$data >= as.Date("2021-01-10"), ]

df$codice <- make.names(paste(substring(df$titolo, 1, 11), df$data))
df$testo <- apostrofo(df$testo)
df$titolo <- apostrofo(df$titolo)
df$testo <- tolower(df$testo)
df$titolo <- tolower(df$titolo)


mioc <- corpus(df
               , docid_field = "codice"
               , text_field = tolower("testo")
               , list("data", "titolo"))

mioc
#  statistiche corpus ----

textstat_summary(mioc) %>%
  ggplot(aes(x = document, y = tokens, group = 1)) +
  geom_line(col = palette()[1]) +
  geom_point(col = palette()[2]) +
  scale_x_discrete (labels = NULL) +
  labs(x = "", y = "Tokens")

summary(mioc)


mioc
tokeninfo <- summary(mioc)
tokeninfo$Year <- docvars(mioc, "data")
with(tokeninfo, plot(data, Tokens, type = "b", pch = 19, cex = .7))

# longest
tokeninfo[which.max(tokeninfo$Tokens), ]

# explore quanteda base....
ndoc(mioc)
corp_sent <- corpus_reshape(mioc, to = "sentences")
print(corp_sent)
ndoc(corp_sent)

corp_sent_long <- corpus_subset(corp_sent, ntoken(corp_sent) >= 20)
ndoc(corp_sent_long)


#  tokens -----
stopwords::stopwords_getsources()

miestop <- unique(
  c(stopwords("it", source = "snowball")
             , stopwords("it", source = "stopwords-iso")
    , "circa"
    , "fra"
    , "anni"
    , "mila"
    , "solo"
    , "mentre"
    , "rispetto"
    , "parte"
    , "tratta"
    , "dato"
    , "dati"
    , "resta"
    , "trimestre"
    , "numero"
    , "media"
    , "punti"
    , "unità"
    , "rapporto"
    , "italia"
             )
)

stok <- tokens(mioc)
mia_div <- textstat_lexdiv(toks)
plot(mia_div$TTR, type = "l", col = "blue", lwd = 2, xlab = "Documenti", ylab = "TTR")

# cluster ----
dfmat <- dfm(stok)
dfmat <- dfm_remove(dfmat, miestop)

tstat_dist <- as.dist(textstat_dist(dfmat))
clust <- hclust(tstat_dist)
plot(clust, xlab = "Distance", ylab = NULL)


#  fcm ----
toks <- tokens(mioc, remove_punct = TRUE
               , remove_numbers = TRUE
               , remove_symbols = TRUE
               , remove_url = TRUE
               , remove_separators = TRUE
               # , remove_hyphens = TRUE
               , split_hyphens = TRUE
               , padding = TRUE
               , include_docvars = TRUE)

toks <- toks |>
  tokens_remove(pattern = miestop, padding = TRUE)

fcmat <- fcm(toks, context = "window", tri = FALSE)

feat <- colSums(fcmat) |>
  sort(decreasing = TRUE) |>
  head(30) |>
  names()

fcm_select(fcmat, pattern = feat) |>
  textplot_network(min_freq = 1)

# key ness ----

# corp_news <- download("data_corpus_guardian")
# summary(corp_news)

dfmat_news <- dfm(toks)

tstat_key <- textstat_keyness(dfmat_news,
                              target = year(dfmat_news$data) > 2023)
textplot_keyness(tstat_key)


# moods ----

# tokenize corpus
toks_news <- toks

eu <- c("salar*", "contratt*")
toks_inside <- tokens_keep(toks_news, pattern = eu, window = 10)
toks_inside <- tokens_remove(toks_inside, pattern = eu) # remove the keywords
toks_outside <- tokens_remove(toks_news, pattern = eu, window = 10)

dfmat_inside <- dfm(toks_inside)
dfmat_outside <- dfm(toks_outside)

tstat_key_inside <- textstat_keyness(rbind(dfmat_inside, dfmat_outside),
                                     target = seq_len(ndoc(dfmat_inside)))
head(tstat_key_inside, 50)

# topics claasificazione ----


dfmat_news <- dfm(toks_news) %>%
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

tmod_lda <- textmodel_lda(dfmat_news, k = 5)

terms(tmod_lda, 9)

download.file("https://raw.githubusercontent.com/koheiw/seededlda/refs/heads/master/vignettes/pkgdown/dictionary.yml"
              , destfile = "dictionary.yml")

dict_topic <- dictionary(file = "dictionary.yml")
print(dict_topic)

tmod_slda <- textmodel_seededlda(dfmat_news, dictionary = dict_topic)



# kwic ----


options(width = 110)

kw_lavor <- kwic(toks, pattern =  "lavor*")
head(kw_lavor, 10)

kw_law2 <- kwic(toks
                  , pattern = c("lavor*", "disoc*"))
head(kw_law2, 10)


toks <- tokens_select(toks, pattern = stopwords("it", source = "snowball"), selection = "remove")
collocazione <- textstat_collocations(toks_nostop, size = 2, min_count = 5)

dmat <- dfm(toks, tolower = TRUE, remove_padding = TRUE)

dmat %>% textstat_frequency()

dfcm <- fcm(toks, context = "document", count = "frequency")

dfcm %>% textplot_network(min_freq = 300, edge_alpha = 0.5, edge_color = "grey")

