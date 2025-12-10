# 1. ISTAT RSS functions -----

#' Extract summary from ISTAT article page
#'
#' Fetches an ISTAT webpage and extracts the article summary, including
#' any linked PDF and Excel documents.
#'
#' @param x Row index in the istat data frame
#' @param istat Data frame from tidyRSS with ISTAT feed data, must contain
#'   columns: item_link, item_pub_date, item_title, item_description
#' @return Invisibly returns a character vector of document URLs (PDF/XLS).
#'   Prints the article summary to console.
#' @export
#' @importFrom rvest read_html html_elements html_nodes html_text2 html_attr
#' @examples
#' \dontrun{
#' library(tidyRSS)
#' istat <- tidyfeed("https://www.istat.it/feed")
#' docs <- sintesi(1, istat)
#' }
sintesi <- function(x, istat) {
  miapag <- rvest::read_html(istat$item_link[x])
  testo <- miapag |>
    rvest::html_elements(".guid-article") |>
    rvest::html_text2()

  message(paste(
    istat$item_pub_date[x],
    " - ",
    istat$item_title[x],
    ". ",
    istat$item_description[x],
    ". ",
    gsub("\\r|\\n", " ", testo)
  ))

  mylinks <- miapag |>
    rvest::html_nodes("a") |>
    rvest::html_attr("href")

  documenti <- c(mylinks[grepl("pdf", mylinks)], mylinks[grepl("xls", mylinks)])

  if (length(documenti) > 0) {
    message("Documents found:")
    message(paste(documenti, collapse = "\n"))
  }

  invisible(documenti)
}

#' Default ISTAT RSS feed URLs
#'
#' Returns a character vector of common ISTAT RSS feed URLs for labor
#' market and economic statistics.
#'
#' @return Character vector of RSS feed URLs
#' @export
#' @examples
#' feeds <- istat_feeds()
#' # Use with tidyRSS::tidyfeed()
istat_feeds <- function() {
  c(
    "https://www.istat.it/feed",
    "https://www.istat.it/tema/lavoro-e-retribuzioni/feed",
    "https://www.istat.it/documenti/comunicato-stampa/feed",
    "https://www.istat.it/documenti/tavole-di-dati/feed",
    "https://www.istat.it/documenti/audizioni/feed"
  )
}
