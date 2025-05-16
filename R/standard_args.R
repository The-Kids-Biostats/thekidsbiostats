#' Standardize Argument Names Internally
#'
#' Standardizes user-supplied argument names using a provided alias map.
#' Primarily used to support alternative spellings (e.g., 'color' vs. 'colour').
#'
#' @param args A named list of arguments, typically captured from \code{list(...)}.
#' @param alias_map A named list mapping aliases to standard names.
#'        For example: \code{list(color = "colour")}.
#'
#' @return A list with standardized argument names.
#'
#' @keywords internal
#' @noRd

standardise_args <- function(call, alias_map = c("color" = "colour", "gray" = "grey")) {
  call_list <- as.list(call)
  names(call_list) <- vapply(names(call_list), function(n) {
    for (alias in names(alias_map)) {
      n <- gsub(alias, alias_map[[alias]], n, fixed = TRUE)
    }
    n
  }, character(1))
  as.call(call_list)
}
