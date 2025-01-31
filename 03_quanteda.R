library(quanteda)

Sys.setlocale(category = "LC_ALL", locale = "it_IT.UTF-8")


mieitesti <- readRDS("data/mieitesti.rds")

df <- data.frame(matrix(unlist(mieitesti), nrow=length(mieitesti), byrow=TRUE))
names(df) <- c("data", "titolo", "testo")
# setDT(df)


df$data <- as.Date(as.numeric(df$data))
str(df)
df <- df[df$data >= as.Date("2021-01-10"), ]

mioc <- corpus(df
               , docid_field = "titolo"
               , text_field = "testo"
               , list("data"))

summary(mioc)

mioc
tokeninfo <- summary(mioc)
tokeninfo$Year <- docvars(mioc, "data")
with(tokeninfo, plot(data, Tokens, type = "b", pch = 19, cex = .7))

# longest
tokeninfo[which.max(tokeninfo$Tokens), ]



# explore quanteda base....

