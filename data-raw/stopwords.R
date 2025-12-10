# 1. Generate miestop.rda -----
# Run this script to regenerate the stopwords data

library(stopwords)

miestop <- unique(c(
  stopwords::stopwords("it", source = "snowball"),
  stopwords::stopwords("it", source = "stopwords-iso"),
  "milione",
  "punto",
  "dovere",
  "mila",
  "solo",
  "dare",
  "rispetto",
  "parte",
  "tratta",
  "dato",
  "dati",
  "resta",
  "trimestre",
  "mese",
  "numero",
  "media",
  "punti",
  "unita",
  "rapporto",
  "italia",
  "lapresse",
  "su il",
  "in il",
  "a il",
  "di il",
  "stare",
  "vedere",
  "restare",

  "potere"
))

usethis::use_data(miestop, overwrite = TRUE)
