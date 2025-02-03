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

leggi_pagine <- function(x) {
  # esempio x = articoli[10]
  Sys.setlocale(category = "LC_ALL", locale = "it_IT.UTF-8")

  miapag <- read_html(x)

  textlinks <- miapag |>
    html_nodes("a") |>
    html_text()

  # mylinks <- miapag |>
  #   html_nodes("a") |>
  #   html_attr("href")

  # links <- data.frame(testo = textlinks, link = mylinks)
  # links2 <- links[nchar(trimws(links$testo)) > 0, ]

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

  calendario <- stringr::str_split_1(calendario, " ")

  data <- lubridate::ymd(paste(c(calendario[4], calendario[3], calendario[2]), collapse = "-"))

  for (i in cklink) {
    testi <- testi[!agrepl(i, testi)]
  }

  if (sum(agrepl("— — — —", testi)) >= 1) {testi <- testi[-(which(agrepl("— — — —", testi)):length(testi))]} else {
    testi <- testi[-(which(agrepl("il Quotidiano Approfondito con le ultime news online", testi)):length(testi))]
  }

  testi <- testi[!grepl("Pixabay", testi)]

  titolo <- testi[1]
  titolo <- trimws(stringr::str_split_1(titolo, "/"))
  titolo <- titolo[length(titolo)]

  testi  <- testi[-1]
  testo <- miostring(testi)
  # cat(testo)

  esporta <- list(data, titolo, testo)

  return(esporta)
}

