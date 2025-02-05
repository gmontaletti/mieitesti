library(stopwords)

# stopwords::stopwords_getsources()

miestop <- unique(
  c(stopwords("it", source = "snowball")
    , stopwords("it", source = "stopwords-iso")

    , "milione"
    , "punto"
    , "dovere"
    , "mila"
    , "solo"
    , "dare"
    , "rispetto"
    , "parte"
    , "tratta"
    , "dato"
    , "dati"
    , "resta"
    , "trimestre"
    , "mese"
    , "numero"
    , "media"
    , "punti"
    , "unità"
    , "rapporto"
    , "italia"
    , "lapresse"
    , "su il"
    , "in il"
    , "a il"
    , "di il"
    , "stare"
    , "vedere"
    , "restare"
    , "potere"
  ))
