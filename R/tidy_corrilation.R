##table

library(dplyr)
library(thekidsbiostats)

Corr_table <- function(
    x,
    y,
    data,
    method      = c("pearson", "spearman", "kendall"),
    conf.level  = 0.95,
    alternative = c("two.sided", "less", "greater"),
    title       = NULL,
    plot_title  = NULL,
    add_smooth  = TRUE,
    point_alpha = 0.7,
    return_plot = FALSE,
    ...
) {
  method      <- match.arg(method)
  alternative <- match.arg(alternative)

  ct <- stats::cor.test(
    x           = data[[x]],
    y           = data[[y]],
    method      = method,
    conf.level  = conf.level,
    alternative = alternative,
    ...
  )

  res <- broom::tidy(ct)

  # CI if present
  if (all(c("conf.low", "conf.high") %in% names(res))) {
    ci_col <- sprintf("%.0f%% CI", conf.level * 100)

    res <- res |>
      dplyr::mutate(
        !!ci_col := dplyr::if_else(
          !is.na(conf.low) & !is.na(conf.high),
          sprintf("(%.3f, %.3f)", conf.low, conf.high),
          NA_character_
        )
      ) |>
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
    dplyr::rename_with(.cols = common, .fn = ~ unname(nice_names[common]))

  method_title <- switch(
    method,
    pearson  = "Pearson correlation",
    spearman = "Spearman rank correlation",
    kendall  = "Kendall rank correlation"
  )

  if (is.null(title)) {
    title <- sprintf("%s between %s and %s", method_title, x, y)
  }
  if (is.null(plot_title)) {
    plot_title <- title
  }

  tbl <- res_clean |>
    gt::gt() |>
    gt::fmt_number(columns = tidyselect::where(is.numeric), decimals = 3) |>
    gt::tab_header(title = title)

  if (!isTRUE(return_plot)) return(tbl)

  # Plot subtitle (rho and p-value)
  est <- unname(ct$estimate)
  pval <- ct$p.value
  subtitle_txt <- sprintf("rho = %.3f, p = %.3f", est, pval)

  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data[[x]], y = .data[[y]])) +
    ggplot2::geom_point(alpha = point_alpha) +
    ggplot2::labs(
      title = plot_title,
      subtitle = subtitle_txt,
      x = x,
      y = y
    ) +
    ggplot2::theme_minimal()

  if (add_smooth) {
    p <- p + ggplot2::geom_smooth(method = "lm", se = TRUE)
  }

  list(table = tbl, plot = p, test = ct, tidy = res)
}

###Plot and table
out <- Corr_table(
  x           = "",
  y           = "",
  data        =
  method      = "",
  alternative = "",
  return_plot = TRUE
)
out$table
out$plot
