# 1. package data documentation -----

#' Italian stopwords for text analysis
#'
#' A character vector of Italian stopwords combining snowball and
#' stopwords-iso sources, plus domain-specific terms for economic
#' and labor market analysis.
#'
#' @format Character vector with stopwords
#' @source Compiled from stopwords package (snowball, stopwords-iso)
#'   plus manual additions for economic/labor market domain
#' @examples
#' head(miestop, 20)
#' length(miestop)
"miestop"

#' Employment topic dictionary for seeded LDA
#'
#' A named list of character vectors for topic classification
#' of employment-related texts using quanteda/seededlda.
#' Terms use wildcard patterns compatible with quanteda dictionary format.
#'
#' @format Named list with 5 elements:
#' \describe{
#'   \item{match}{Market and economic terms (e.g., mercat*, salar*, pil)}
#'   \item{politica}{Political terms (e.g., govern*, parlament*, politic*)}
#'   \item{pal}{Active labor market policies (e.g., formazio*, programm*, gol)}
#'   \item{offerta}{Labor supply terms (e.g., occupa*, disoccupa*, lavor*)}
#'   \item{domanda}{Labor demand terms (e.g., competenz*, domand*, settor*)}
#' }
#' @examples
#' names(emp_dictionary)
#' emp_dictionary$match
#'
#' # Use with quanteda
#' \dontrun{
#' library(quanteda)
#' dict <- dictionary(emp_dictionary)
#' }
"emp_dictionary"
