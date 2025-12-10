# 1. scraping functions -----

#' List pagination pages from author archive
#'
#' Scrapes a webpage and extracts all links containing "page" parameter
#' for pagination on ilsussidiario.net author pages.
#'
#' @param x URL of the author's archive page
#' @return Character vector of page URLs including the base URL
#' @keywords internal
#' @importFrom rvest read_html html_elements html_attr
lista_pagine <- function(x) {
  links <- rvest::read_html(x) |>
    rvest::html_elements("a") |>
    rvest::html_attr("href")
  index <- grepl(pattern = "page", links)
  pagine <- unique(c(x, links[index]))
  return(pagine)
}

#' Collect article links from a single page
#'
#' Extracts article links from a paginated author archive page.
#'
#' @param x URL of a page to scrape
#' @param autlink Author archive base URL used to identify article position
#' @return Character vector of article URLs
#' @keywords internal
#' @importFrom rvest read_html html_elements html_attr
colleziona <- function(x, autlink) {
  links <- rvest::read_html(x) |>
    rvest::html_elements("a") |>
    rvest::html_attr("href") |>
    as.data.frame(nm = "nome")
  links <- links[which(links$nome == autlink) + 1, ]
  links <- links[!grepl("page", links)]
  return(links)
}

#' Collect all articles from an author on il sussidiario
#'
#' Scrapes the ilsussidiario.net author archive to collect all article URLs.
#' This function handles pagination automatically.
#'
#' @param autore URL of the author's archive page on ilsussidiario.net
#' @return Character vector of article URLs
#' @export
#' @examples
#' \dontrun{
#' autlink <- "https://www.ilsussidiario.net/autori/giampaolo-montaletti/"
#' articoli <- sussidiario(autore = autlink)
#' }
sussidiario <- function(autore) {
  articoli <- unlist(lapply(lista_pagine(autore), colleziona, autlink = autore))
  articoli <- articoli[which(articoli != autore)]
  return(articoli)
}
