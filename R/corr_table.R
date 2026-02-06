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
#' @return A list of ggplot2 theme elements and scale adjustments.
#'
#' @examples
#' corr_table(mtcars$mpg,
#'            mtcars$hp)
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

  # Calculate correlation coefficient based specification
  if (!is.null(formula)) {
    if (is.null(data)) stop("Provide data with formula")
    ct <- cor.test(formula,
                   data = data,
                   method = method,
                   conf.level = conf.level,
                   alternative = alternative, ...)
    vars <- all.vars(formula)
    x_name <- vars[1]; y_name <- vars[2]
    x_vec <- data[[x_name]]; y_vec <- data[[y_name]]
  } else {
    x_vec <- if (is.null(data)) x else data[[x]]
    y_vec <- if (is.null(data)) y else data[[y]]
    x_name <- if (is.null(data)) deparse(substitute(x)) else x
    y_name <- if (is.null(data)) deparse(substitute(y)) else y
    ct <- cor.test(x_vec, y_vec,
                   method = method,
                   conf.level = conf.level,
                   alternative = alternative, ...)
  }

  # Clean cor.test output
  res <- broom::tidy(ct)

  # CI if present
  if (all(c("conf.low", "conf.high") %in% names(res))) {
    ci_col <- sprintf("%.0f%% CI", conf.level * 100)

    res <- res |>
      dplyr::mutate(!!ci_col := sprintf("(%s, %s)",
                                        thekidsbiostats::round_vec(conf.low, round_digits),
                                        thekidsbiostats::round_vec(conf.high, round_digits))) |>
      dplyr::select(-conf.low, -conf.high)
  }

  nice_names <- c(
    estimate  = "Estimate",
    statistic = "Test statistic",
    parameter = "df",
    p.value   = "p-value"
  )

  ci_name <- sprintf("%.0f%% CI", conf.level * 100)
  if (ci_name %in% names(res)) nice_names[ci_name] <- ci_name

  common <- intersect(names(res), names(nice_names))

  res_clean <- res |>
    dplyr::select(dplyr::all_of(common)) |>
    dplyr::rename_with(.cols = dplyr::all_of(common),
                       .fn = ~ unname(nice_names[common]))

  method_title <- if (method == "pearson") "Pearson correlation" else
    stringr::str_to_sentence(paste(method, "rank correlation"))
  title <- title %||% sprintf("%s between %s and %s", method_title, x_name, y_name)
  plot_title <- plot_title %||% title

  # Formulate Table
  tbl <- res_clean |>
    dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~thekidsbiostats::round_vec(., round_digits))) |>
    thekidsbiostats::thekids_table() |>
    flextable::set_caption(caption = title)


  if (!isTRUE(return_plot)){
    return(tbl)
  } else {
    # Create plot
    ## Plot subtitle (rho and p-value)
    subtitle_txt <- sprintf("rho = %s, p = %s",
                            thekidsbiostats::round_vec(unname(ct$estimate), round_digits),
                            gtsummary::style_pvalue(ct$p.value))

    # Create plot
    p <- ggplot2::ggplot(data.frame(x = x_vec, y = y_vec),
                         ggplot2::aes(x = x, y = y)) +
      ggplot2::geom_point(alpha = point_alpha) +
      ggplot2::labs(
        title = plot_title,
        subtitle = subtitle_txt,
        x = x_name,
        y = y_name
      ) +
      thekidsbiostats::theme_thekids()

    if (add_smooth) {
      p <- p + ggplot2::geom_smooth(method = "lm",
                                    se = TRUE)
    }

    return(list(table = tbl,
                plot = p,
                test = ct,
                tidy = res))
  }

}
