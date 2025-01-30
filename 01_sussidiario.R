library(rvest)

#  funzioni ----
lista_pagine <- function(x = autlink) {
  links <- read_html(x) |>
    html_elements("a") |>
    html_attr("href")
  index <- links |>
    grepl(pattern = "page")
  pagine = unique(c(autlink, links[index]))
    return(pagine)
}

colleziona <- function(x) {
links <- read_html(x) |>
  html_elements("a") |>
  html_attr("href") |>
  as.data.frame(nm = "nome")
links <- links[which(links$nome == autlink) + 1, ]
links <- links[!grepl("page", links)]
return(links)
}

sussidiario <- function(autore = autlink) {
  articoli <-  unlist(lapply(lista_pagine(autlink), colleziona))
articoli <- articoli[which(articoli != autlink)]
return(articoli)
}


leggi_pagine <- function(x) {

  miapag <- read_html(x)

  textlinks <- miapag |>
    html_nodes("a") |>
    html_text()

  mylinks <- miapag |>
    html_nodes("a") |>
    html_attr("href")

  links <- data.frame(testo = textlinks, link = mylinks)

  textlinks <- textlinks[which(nchar(textlinks) >=  1)]

  cklink <- textlinks[(which(textlinks == "Giampaolo Montaletti")+1):(which(textlinks == "Giampaolo Montaletti")+10)]

  indice <- cklink |> nchar() |> sort(decreasing = TRUE)

  posizione <- if(length(indice) >= 4) {4} else {length(indice)}

  cklink <- cklink[which(nchar(cklink) >= indice[posizione])]

  testi <- miapag |>
    html_elements("p") |>
    html_text2()

  testi <- testi[which(nchar(testi) > 0)]

  calendario <- miapag |>
    html_elements("time") |>
    html_text2()

  for (i in cklink) {
   testi <- testi[!agrepl(i, testi)]
 }

  if (sum(agrepl("— — — —", testi)) >= 1) {testi <- testi[-(which(agrepl("— — — —", testi)):length(testi))]} else {
    testi <- testi[-(which(agrepl("il Quotidiano Approfondito con le ultime news online", testi)):length(testi))]
  }

  testi <- c(testi, calendario)
  return(testi)
  }



#  esegui ----

autlink <- "https://www.ilsussidiario.net/autori/giampaolo-montaletti/"
articoli <- sussidiario(autore = autlink)
mieitesti <- lapply(articoli, leggi_pagine)

saveRDS(mieitesti, "data/mieitesti.rds")






