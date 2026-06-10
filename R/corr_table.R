#' Formulate Formatted Correlation Table
#'
#' This function calculates the correlation between two continuous variables and formats the outputs, utilising pre-existing functionalities of the package.
#'
#' @param x,y Numeric vectors of data values. `x` and `y` must have the same length.
#' @param data Operational matrix or dataframe containing the variables in `formula`.
#' @param method Character string. Correlation coefficient to be calculated. Must be one of `"pearson"`, `"kendall"`, or `"spearman"`.
#' @param conf.level Numeric. Confidence level for the calculated confidence interval. Default 0.95.
#' @param alternative Character string. Alternative hypothesis. Must be one of `"two.sided"`, `"less"`, `"greater"`.
#' @param title Character string. Table title.
#' @param plot_title Character string. Plot title.
#' @param add_smooth Logical. Should a smoothed line of best fit be presented on the plot? Default is `TRUE`.
#' @param return_plot Logical. Should a plot be returned? Default is `FALSE`.
#' @param round_digits Numeric. Number of digits to round outputs to.
#' @param formula Optional. Formula object to pass to `stats::cor.test`.
#' @param point_alpha Numeric. Alpha to apply to points in plot.
#' @param ... Miscellaneous arguments that can be passed to `stats::cor.test`.
#'
#' @note
#' If a Google font has not been loaded with the package, `thekids_theme` will load this function on your behalf.
#'
#' Supported Google Fonts are those that exist in `sysfonts::font_families_google()`.
#'
#' @return data.frame if `return_plot=FALSE`, or a list of `return_plot=TRUE`.
#'
#' @examples
#' # Directly supply vectors
#' corr_table(mtcars$mpg,
#'            mtcars$hp)
#'
#' # Supply vector names & data
#' corr_table("mpg",
#'            "hp",
#'            data = mtcars)
#'
#' # Specify formula
#' corr_table(formula = ~ mpg + hp,
#'            data = mtcars)
#'
#' @export

corr_table <- function(
    x           = NULL,
    y           = NULL,
    data        = NULL,
    formula     = NULL,
    method      = c("pearson", "spearman", "kendall"),
    conf.level  = 0.95,
    alternative = c("two.sided", "less", "greater"),
    title       = NULL,
    plot_title  = NULL,
    add_smooth  = TRUE,
    point_alpha = 0.7,
    return_plot = FALSE,
    round_digits = 3,
    ...) {

  method      <- match.arg(method)
  alternative <- match.arg(alternative)

  if (is.null(formula) && is.null(x) && is.null(y)) {
    stop("You must provide either a formula or x and y vectors/column names.")
  }

  if (!is.null(formula) && is.null(data)) {
    stop("A data frame must be provided when using a formula.")
  }

  if (!is.null(data) && !is.null(x) && !is.null(y)) {
    if (!x %in% names(data)) stop(sprintf("Column '%s' not found in data.", x))
    if (!y %in% names(data)) stop(sprintf("Column '%s' not found in data.", y))
  }

  # 1) Extract vector names and formulas
  # Get vectors and names
  if (!is.null(formula)) {
    vars <- all.vars(formula)
    x_vec <- data[[vars[1]]]
    y_vec <- data[[vars[2]]]
    x_name <- vars[1]
    y_name <- vars[2]
  } else if (!is.null(data)) {
    x_vec <- data[[x]]
    y_vec <- data[[y]]
    x_name <- x
    y_name <- y
  } else {
    x_vec <- x
    y_vec <- y
    x_name <- deparse(substitute(x))
    y_name <- deparse(substitute(y))
  }

  if (length(x_vec) != length(y_vec)) {
    stop("x and y must be of the same length.")
  }

  # 2) Run correlation test
  ct   <- run_cor_test(x_vec = x_vec,
                       y_vec = y_vec,
                       data = data,
                       formula = formula,
                       alternative = alternative,
                       method = method,
                       conf.level = conf.level,
                       ...)

  # 3) Clean correlation test output
  res <- broom::tidy(ct)

  ci_col <- NULL

  if (all(c("conf.low", "conf.high") %in% names(res))) {
    ci_col <- sprintf("%.0f%% CI", conf.level * 100)

    res[[ci_col]] <- sprintf("(%s, %s)",
                             thekidsbiostats::round_vec(res$conf.low,
                                                        round_digits),
                             thekidsbiostats::round_vec(res$conf.high,
                                                        round_digits))

    res <- res[, !names(res) %in% c("conf.low", "conf.high")]
  }


  # 4) Rename columns
  nice_names <- c(estimate  = "Estimate",
                  statistic = "Test Statistic",
                  parameter = "df",
                  p.value   = "p-value")

  common <- intersect(names(res),
                      c(names(nice_names)))
  cols_keep <- c(common, ci_col)
  cols_keep <<- cols_keep[!is.null(cols_keep)]

  res_clean <- res |>
    dplyr::select(dplyr::all_of(cols_keep)) |>
    dplyr::rename_with(.cols = dplyr::all_of(common),
                       .fn = ~ unname(nice_names[common])) |>
    dplyr::mutate(dplyr::across(dplyr::all_of(c("Estimate", "Test Statistic")),
                                ~thekidsbiostats::round_vec(.,
                                                            round_digits)),
                  dplyr::across(dplyr::all_of("p-value"),
                                ~gtsummary::style_pvalue(.)))


  # 6) Make table
  tbl <- res_clean


  if (!isTRUE(return_plot)){
    return(tbl)
  } else {

    method_title <- if (method == "pearson") "Pearson correlation" else
      stringr::str_to_sentence(paste(method, "rank correlation"))
    title <- title %||% sprintf("%s between %s and %s", method_title, x_name, y_name)
    plot_title <- plot_title %||% title

    ## Plot subtitle (rho and p-value)
    subtitle_txt <- sprintf("rho = %s, p = %s",
                            thekidsbiostats::round_vec(unname(ct$estimate), round_digits),
                            gtsummary::style_pvalue(ct$p.value))

    # Create plot
    p <- ggplot2::ggplot(,
                         ggplot2::aes(x = x,
                                      y = y)) +
      ggplot2::geom_point(alpha = point_alpha) +
      ggplot2::labs(title = plot_title,
                    subtitle = subtitle_txt,
                    x = x_name,
                    y = y_name)

    if (add_smooth) {
      p <- p +
        ggplot2::geom_smooth(method = "lm",
                             se = TRUE)
    }

    return(list(table = tbl,
                plot = p,
                test = ct))
  }

}
