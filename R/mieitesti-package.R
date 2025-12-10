#' mieitesti: Italian News Article Collection and Text Analysis
#'
#' Tools for collecting and analyzing Italian news articles from
#' 'il sussidiario' and ISTAT RSS feeds.
#'
#' @section Core Functions:
#' \itemize{
#'   \item \code{\link{sussidiario}} - Collect all articles from an author
#'   \item \code{\link{leggi_pagina}} - Parse a single article page
#'   \item \code{\link{pag_as_frame}} - Convert article list to data.table
#'   \item \code{\link{sintesi}} - Extract ISTAT article summaries
#' }
#'
#' @section Text Utilities:
#' \itemize{
#'   \item \code{\link{apostrofo}} - Normalize Italian apostrophes
#' }
#'
#' @section Data:
#' \itemize{
#'   \item \code{\link{miestop}} - Italian stopwords character vector
#'   \item \code{\link{emp_dictionary}} - Employment topic dictionary
#' }
#'
#' @author Giampaolo Montaletti \email{giampaolo.montaletti@@gmail.com}
#'
#' @docType package
#' @name mieitesti-package
#' @aliases mieitesti
"_PACKAGE"
