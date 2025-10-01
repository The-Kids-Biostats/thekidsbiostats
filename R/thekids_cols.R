#' @title Function to extract The Kids colours as hex codes
#'
#' @param ... Character names of thekids_colours
#'
#' @export
thekids_cols <- function(...) {

  cols <- c(...)

  if (is.null(cols))
    return (thekidsbiostats::thekids_colours)

  thekidsbiostats::thekids_colours[cols]

}

