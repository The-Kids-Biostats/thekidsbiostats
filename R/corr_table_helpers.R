#' Perform correlation test
#'
#' Internal function for thekidsbiostats::corr_table
#'
#' @param x_vec First numeric vector to pass to `stats::cor.test`.
#' @param y_vec Second numeric vector to pass to `stats::cor.test`.
#' @param alternative Alternative hypothesis
#' @param method Correlation method
#' @param conf.level Confidence level
#' @param data data.frame
#' @param formula Formula object (if specified)
#' @param ... Other arguments passed to `stats::cor.test`.

#' @return List of class "`htest`".
#' @noRd
#'
run_cor_test <- function(x_vec,
                         y_vec,
                         alternative,
                         method,
                         conf.level,
                         data = NULL,
                         formula = NULL,
                         ...) {
  if (!is.null(formula)) {
    cor.test(formula,
             data = data,
             method = method,
             conf.level = conf.level,
             alternative = alternative,
             ...)
  } else {
    cor.test(x_vec,
             y_vec,
             method = method,
             conf.level = conf.level,
             alternative = alternative,
             ...)
  }
}
