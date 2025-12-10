# 1. text utility functions -----

#' Concatenate strings with optional truncation
#'
#' Concatenates a character vector into a single string with optional
#' width truncation.
#'
#' @param x Character vector to concatenate
#' @param width Maximum width for the result (NULL for no truncation)
#' @param ... Additional arguments (unused)
#' @return Single character string, truncated to width if specified
#' @keywords internal
miostring <- function(x, width = NULL, ...) {
  string <- paste(x, collapse = " ")
  if (missing(width) || is.null(width) || width == 0) {
    return(string)
  }
  if (width < 0) {
    stop("'width' must be positive")
  }
  if (nchar(string, type = "w") > width) {
    width <- max(6, width)
    string <- paste0(strtrim(string, width - 4), "....")
  }
  string
}

#' Normalize Italian apostrophes for text analysis
#'
#' Adds a space after apostrophes that are not followed by whitespace,
#' which improves tokenization of Italian text. Handles both straight
#' and curly apostrophe characters.
#'
#' @param x Character vector to process
#' @return Character vector with normalized apostrophes
#' @export
#' @importFrom stringr str_replace_all
#' @examples
#' apostrofo("l'articolo")
#' # Returns: "l' articolo"
#'
#' apostrofo("dell'economia italiana")
#' # Returns: "dell' economia italiana"
apostrofo <- function(x) {
  stringr::str_replace_all(x, "[''\u2019](?!\\s)", "' ")
}
