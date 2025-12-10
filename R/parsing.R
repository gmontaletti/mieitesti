# 1. parsing functions -----

#' Parse a single article page from il sussidiario
#'
#' Extracts date, title, text, and link from an article page on ilsussidiario.net.
#' The function handles Italian date formats and cleans the text from footer
#' elements and credits.
#'
#' @param x URL of the article to parse
#' @param author_name Name of the author to search for in page links
#'   (default: "Giampaolo Montaletti")
#' @return List with 4 elements:
#'   \itemize{
#'     \item data - Date object
#'     \item titolo - Character, article title
#'     \item testo - Character, article body text
#'     \item item_link - Character, original URL
#'   }
#' @export
#' @importFrom rvest read_html html_nodes html_elements html_text2 html_attr
#' @importFrom lubridate ymd
#' @importFrom stringr str_split_1
#' @examples
#' \dontrun{
#' article <- leggi_pagina("https://www.ilsussidiario.net/news/...")
#' }
leggi_pagina <- function(x, author_name = "Giampaolo Montaletti") {
  miapag <- rvest::read_html(x)

  textlinks <- miapag |>
    rvest::html_nodes("a") |>
    rvest::html_text()

  textlinks <- textlinks[which(nchar(textlinks) >= 1)]

  author_pos <- which(textlinks == author_name)
  if (length(author_pos) == 0) {
    warning("Author not found in page: ", x)
    cklink <- character(0)
  } else {
    cklink <- textlinks[(author_pos[1] + 1):(author_pos[1] + 10)]
    indice <- sort(nchar(cklink), decreasing = TRUE)
    posizione <- if (length(indice) >= 4) 4 else length(indice)
    cklink <- cklink[which(nchar(cklink) >= indice[posizione])]
  }

  testi <- miapag |>
    rvest::html_elements("p") |>
    rvest::html_text2()

  testi <- testi[which(nchar(testi) > 0)]

  calendario <- miapag |>
    rvest::html_elements("time") |>
    rvest::html_text2()

  calendario <- stringr::str_split_1(calendario, " ")
  data <- lubridate::ymd(paste(c(calendario[4], calendario[3], calendario[2]), collapse = "-"))

  for (i in cklink) {
    testi <- testi[!agrepl(i, testi)]
  }

  if (sum(agrepl("\u2014 \u2014 \u2014 \u2014", testi)) >= 1) {
    testi <- testi[-(which(agrepl("\u2014 \u2014 \u2014 \u2014", testi)):length(testi))]
  } else if (sum(agrepl("il Quotidiano Approfondito con le ultime news online", testi)) >= 1) {
    testi <- testi[-(which(agrepl("il Quotidiano Approfondito con le ultime news online", testi)):length(testi))]
  }

  testi <- testi[!grepl("Pixabay", testi)]

  titolo <- testi[1]
  titolo <- trimws(stringr::str_split_1(titolo, "/"))
  titolo <- titolo[length(titolo)]

  testi <- testi[-1]
  testo <- miostring(testi)

  item_link <- x
  esporta <- list(data, titolo, testo, item_link)
  return(esporta)
}

#' Convert article list to data.table
#'
#' Transforms a list of article metadata (as returned by leggi_pagina)
#' into a data.table for easier manipulation.
#'
#' @param lista List containing article data from multiple calls to leggi_pagina
#' @return A data.table with columns: data, titolo, text, item_link
#' @export
#' @importFrom data.table setDT
#' @examples
#' \dontrun{
#' mt <- lapply(articoli, leggi_pagina)
#' df <- pag_as_frame(mt)
#' }
pag_as_frame <- function(lista) {
  elementi <- c("data", "titolo", "text", "item_link")
  mt <- data.frame(matrix(unlist(lista), ncol = length(elementi), byrow = FALSE))
  names(mt) <- elementi
  data.table::setDT(mt)
  return(mt)
}
