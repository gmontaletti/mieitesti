# librerie ----
# install("quanteda")
library(data.table)
# library(tm)
# library(lubridate)
# library(magrittr)
# library(stopwords)
# library(wordcloud)
# library(wordcloud2)
# library(ggplot2)
library(quanteda)


Sys.setlocale(category = "LC_ALL", locale = "it_IT.UTF-8")
testi <- readRDS("data/mieitesti.rds")

miostring <- function (x, width = NULL, ...) {
  string <- paste(x, collapse = " ")
  if (missing(width) || is.null(width) || width == 0)
    return(string)
  if (width < 0)
    stop("'width' must be positive")
  if (nchar(string, type = "w") > width) {
    width <- max(6, width)
    string <- paste0(strtrim(string, width - 4), "....")
  }
  string
}

delista <- function(x) {
 y <- miostring(unlist(x))
 return(y)
}

text <-  sapply(testi, delista)

text <- tolower(text)

docs <- tm::Corpus(tm::VectorSource(text))

mdoc <- corpus(docs)


miestop <- c("’"
             , "dati"
             , "istat"
             , "pubblicato"
             , "dato"
             , "mese"
             , "tratta"
             )



  summary(mdoc)

  summary(docs)

  docs <- docs %>%
    tm_map(content_transformer(tolower)) %>%
    tm_map(removeWords, c(stopwords::stopwords("it", "stopwords-iso")
                          , stopwords::stopwords("en", "stopwords-iso")
                          , miestop)) %>%
    tm_map(removePunctuation) %>%
    tm_map(removeNumbers)

  dtm <- TermDocumentMatrix(docs)
  matrix <- as.matrix(dtm)
  words <- sort(rowSums(matrix),decreasing=TRUE)
  df <- data.frame(word = names(words),freq=words)

  wordcloud(words = df$word
            , freq = df$freq, min.freq = 1
            , max.words=200
            , random.order=FALSE
            , rot.per=0.35
            , colors=brewer.pal(8, "Dark2"))

  wordcloud2(data=df, size=1.6, color='random-dark')

setDT(df)

df[, rel_freq := freq/sum(freq)]
toplot <- df[order(-freq)][1:10]

ggplot(toplot) +
  aes(x = reorder(word, rel_freq), y = rel_freq) +
  geom_col() +
  theme_minimal() +
  coord_flip()

cat(unlist(testi[1])) |> knitr::kable()
