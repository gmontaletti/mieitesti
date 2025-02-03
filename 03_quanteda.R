# renv::install("quanteda/quanteda.dictionaries")
library(renv)
renv::status()
renv::snapshot()
# renv::init()
library(quanteda)
require(quanteda.textstats)
require(quanteda.textplots)
require(quanteda.corpora)
# require(quanteda.dictionaries)
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


mioc <- corpus(df
               , docid_field = "codice"
               , text_field = tolower("testo")
               , list("data", "titolo"))

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

# tokens()
# toks_immig <- tokens(mioc)
toks <- tokens(mioc)

#  tokens -----

toks <- tokens(mioc, remove_punct = TRUE
                       , remove_numbers = TRUE
                       , remove_symbols = TRUE
                       , remove_url = TRUE
                       , remove_separators = TRUE
                       , remove_hyphens = TRUE
                       , split_hyphens = TRUE
                       , padding = FALSE
               , include_docvars = FALSE)

print(toks)
stopwords::stopwords_getsources()

stopwords("it", source = "snowball")

toks <- tokens_remove(toks, pattern = stopwords("it", source = "snowball"), padding = TRUE)

fcmat <- fcm(toks, context = "window", tri = FALSE)

feat <- colSums(fcmat) |>
  sort(decreasing = TRUE) |>
  head(30) |>
  names()

fcm_select(fcmat, pattern = feat) |>
  textplot_network(min_freq = 0.5)




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
