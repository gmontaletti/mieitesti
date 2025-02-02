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
  stringr::str_replace_all(x, "[\'\’](?!\\s)", "' ")
}

# genera corpus da lista ----

mieitesti <- readRDS("data/mieitesti.rds")
df <- data.frame(matrix(unlist(mieitesti), nrow=length(mieitesti), byrow=TRUE))
names(df) <- c("data", "titolo", "testo")
df$codice <- make.names(paste(substring(df$titolo, 1, 11), df$data))
df$testo <- paste(df$titolo, df$testo)
df$testo <- apostrofo(df$testo)
df$data <- as.Date(as.numeric(df$data))
df <- df[df$data >= as.Date("2021-01-10"), ]

mioc <- corpus(df
               , docid_field = "codice"
               , text_field = "testo"
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

corp_sent_long <- corpus_subset(corp_sent, ntoken(corp_sent) >= 10)
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
                       , padding = TRUE
                       )
print(toks)

toks <- tokens_remove(toks, pattern = stopwords("it"), padding = TRUE)


options(width = 110)

kw_lavor <- kwic(toks, pattern =  "lavor*")
head(kw_lavor, 10)

kw_law2 <- kwic(toks
                  , pattern = c("lavor*", "disoc*"))
head(kw_law2, 10)


toks_nostop <- tokens_select(toks, pattern = stopwords("it"), selection = "remove")
print(toks_nostop)

toks_nostop_pad <- tokens_remove(toks, pattern = stopwords("en"), padding = TRUE)
print(toks_nostop_pad)

textstat_collocations(toks_nostop, size = 2, min_count = 5)



dict_newsmap <- dictionary(file = "data/newsmap.csv")





