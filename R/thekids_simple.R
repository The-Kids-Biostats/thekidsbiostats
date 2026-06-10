#' Format a Statistical Test Object as a Publication-Ready Flextable
#'
#' @description
#' `thekids_simple()` takes the output of a common R hypothesis-test function
#' and returns a formatted \pkg{flextable} table suitable for inclusion in Word
#' documents, HTML reports, or PowerPoint slides via \pkg{officer}.
#'
#' The function inspects the class and \code{$method} field of the supplied
#' object to automatically route to the correct formatting handler. All tables
#' share a consistent two-row header (spanning title + column labels), a
#' \pkg{booktabs}-style theme, and an italicised footer containing test-specific
#' notes (e.g. variance equality, correction status, alternative hypothesis).
#'
#' @details
#' ## Supported test objects
#'
#' | Class | R function | Test |
#' |-------|-----------|------|
#' | `htest` | `t.test(x ~ g)` | Welch or Student two-sample t-test |
#' | `htest` | `t.test(x, mu = )` | One-sample t-test |
#' | `htest` | `wilcox.test()` | Wilcoxon rank-sum / Mann-Whitney U |
#' | `htest` | `chisq.test()` | Pearson chi-squared (with or without Yates' correction) |
#' | `htest` | `fisher.test()` | Fisher's exact test |
#' | `htest` | `cor.test()` | Pearson, Spearman, or Kendall correlation |
#' | `aov` | `aov()` | One-way ANOVA (raw `aov` object) |
#' | `anova` | `summary(aov())` | One-way ANOVA (summarised object) |
#'
#' ## Output format by test
#'
#' * **Two-sample t-test** — group means, t statistic with df, mean difference
#'   with CI, and p-value. Footer notes whether `var.equal = TRUE/FALSE`.
#' * **One-sample t-test** — sample mean, t statistic with df, CI for the mean,
#'   and p-value. Footer states the null hypothesis value (mu).
#' * **Wilcoxon / Mann-Whitney** — W statistic, optional Hodges-Lehmann estimate
#'   with CI (only when `conf.int = TRUE` was passed to `wilcox.test()`),
#'   and p-value. Footer explains both W and the HL estimator.
#' * **Chi-squared** — chi-squared statistic with df and p-value. Footer
#'   reports Yates' correction status, distinguishing 2x2 from larger tables.
#' * **Fisher's exact** — odds ratio and CI on a single row (when available),
#'   and p-value. Footer states the alternative hypothesis.
#' * **Correlation** — correlation coefficient (r / rho / tau depending on
#'   method) with CI (Pearson only), t statistic with df (Pearson / Spearman),
#'   and p-value. Footer states the alternative hypothesis.
#' * **One-way ANOVA** — three-column table (Source | Statistic | Value) with
#'   df, Sum of Squares, Mean Square, F statistic, and p-value for each source
#'   term. The source name appears only on the first row of each term group.
#'
#' ## p-value formatting
#' All p-values are formatted to four significant figures via
#' \code{formatC(..., format = "g")}. Values below 0.001 are reported as
#' \code{< .001}.
#'
#' ## Dependencies
#' Requires \pkg{flextable}, \pkg{tibble}, and \pkg{tools} (base). These must
#' be attached or the package must list them under \code{Imports}.
#'
#' @param test_obj A statistical test object. Accepted classes are \code{htest}
#'   (returned by \code{\link[stats]{t.test}}, \code{\link[stats]{wilcox.test}},
#'   \code{\link[stats]{chisq.test}}, \code{\link[stats]{fisher.test}}, and
#'   \code{\link[stats]{cor.test}}), \code{aov} (returned by
#'   \code{\link[stats]{aov}}), or the \code{anova} summary list returned by
#'   calling \code{summary()} on an \code{aov} object. Passing any other object
#'   class will raise an informative error.
#'
#' @return A \code{\link[flextable]{flextable}} object. This can be printed
#'   directly in an R Markdown / Quarto document, passed to
#'   \code{flextable::save_as_docx()} for Word export, or embedded in a
#'   \pkg{officer} document.
#'
#' @seealso
#' \code{\link[flextable]{flextable}},
#' \code{\link[stats]{t.test}},
#' \code{\link[stats]{wilcox.test}},
#' \code{\link[stats]{chisq.test}},
#' \code{\link[stats]{fisher.test}},
#' \code{\link[stats]{cor.test}},
#' \code{\link[stats]{aov}}
#'
#' @importFrom flextable flextable set_header_labels add_header_row bold italic
#' @importFrom flextable align add_footer_lines theme_booktabs autofit
#' @importFrom tibble tibble
#' @importFrom tools toTitleCase
#'
#' @examples
#' \dontrun{
#' # Two-sample Welch t-test (default)
#' thekids_simple(t.test(mpg ~ am, data = mtcars))
#'
#' # Two-sample Student t-test (equal variances assumed)
#' thekids_simple(t.test(mpg ~ am, data = mtcars, var.equal = TRUE))
#'
#' # One-sample t-test against a known null value
#' thekids_simple(t.test(mtcars$mpg, mu = 20))
#'
#' # Wilcoxon rank-sum test without CI
#' thekids_simple(wilcox.test(mpg ~ am, data = mtcars))
#'
#' # Wilcoxon rank-sum test with Hodges-Lehmann estimate and CI
#' thekids_simple(wilcox.test(mpg ~ am, data = mtcars, conf.int = TRUE))
#'
#' # Chi-squared test on a 2x2 table (Yates' correction applied by default)
#' thekids_simple(chisq.test(table(mtcars$am, mtcars$vs)))
#'
#' # Chi-squared test with Yates' correction explicitly disabled
#' thekids_simple(chisq.test(table(mtcars$am, mtcars$vs), correct = FALSE))
#'
#' # Chi-squared test on a table larger than 2x2 (correction not applicable)
#' thekids_simple(chisq.test(table(mtcars$am, mtcars$cyl)))
#'
#' # Fisher's exact test
#' thekids_simple(fisher.test(table(mtcars$am, mtcars$vs)))
#'
#' # Pearson correlation (includes CI by default)
#' thekids_simple(cor.test(mtcars$mpg, mtcars$wt))
#'
#' # Spearman correlation
#' thekids_simple(cor.test(mtcars$mpg, mtcars$wt, method = "spearman"))
#'
#' # Kendall correlation
#' thekids_simple(cor.test(mtcars$mpg, mtcars$wt, method = "kendall"))
#'
#' # One-way ANOVA — pass the raw aov object
#' thekids_simple(aov(mpg ~ factor(cyl), data = mtcars))
#'
#' # One-way ANOVA — pass the summarised object
#' thekids_simple(summary(aov(mpg ~ factor(cyl), data = mtcars)))
#' }
#'
#' @export
#'

thekids_simple <- function(test_obj) {

  # ── Route to the appropriate handler ───────────────────────────────────────
  if (inherits(test_obj, "aov") || inherits(test_obj, "anova") ||
      (is.list(test_obj) && inherits(test_obj[[1]], "anova"))) {
    return(.tks_anova(test_obj))
  }

  if (!inherits(test_obj, "htest")) {
    stop("Unsupported object type. Supply an htest object (t.test, wilcox.test, ",
         "chisq.test, fisher.test, cor.test) or an aov / summary(aov) object.")
  }

  method <- test_obj$method

  if (grepl("t-test", method, ignore.case = TRUE)) {
    # Distinguish one-sample vs two-sample by number of estimates
    if (length(test_obj$estimate) == 1) {
      return(.tks_ttest_one(test_obj))
    } else {
      return(.tks_ttest_two(test_obj))
    }
  }

  if (grepl("wilcoxon|mann-whitney", method, ignore.case = TRUE)) {
    return(.tks_wilcox(test_obj))
  }

  if (grepl("chi-squared", method, ignore.case = TRUE)) {
    return(.tks_chisq(test_obj))
  }

  if (grepl("fisher", method, ignore.case = TRUE)) {
    return(.tks_fisher(test_obj))
  }

  if (grepl("correlation", method, ignore.case = TRUE)) {
    return(.tks_cor(test_obj))
  }

  stop("Test not yet supported: ", method)
}


# ── Shared helpers ─────────────────────────────────────────────────────────────

# Format p-value: show exact to 4 sig figs, flag < .001
.fmt_p <- function(p) {
  if (is.na(p))   return("NA")
  if (p < 0.001)  return("< .001")
  formatC(p, format = "g", digits = 4)
}

# Build and theme a two-column flextable
.make_ft <- function(tbl, span_label, footer_note = NULL) {
  ft <- flextable(tbl) |>
    set_header_labels(Statistic = "Statistic", Value = "Value") |>
    add_header_row(values = span_label, colwidths = 2) |>
    bold(part = "header") |>
    italic(i = 1, part = "header") |>
    align(i = 1, align = "center", part = "header") |>
    theme_booktabs() |>
    autofit()

  if (!is.null(footer_note)) {
    ft <- ft |>
      add_footer_lines(footer_note) |>
      italic(part = "footer")
  }
  ft
}


# ── Two-sample t-test ──────────────────────────────────────────────────────────
.tks_ttest_two <- function(test_obj) {

  var_name <- if (grepl("\\$", test_obj$data.name)) {
    sub(".*\\$([^ ]+) by.*", "\\1", test_obj$data.name)
  } else {
    sub(" by.*", "", test_obj$data.name)
  }

  group_short  <- sub("mean in group ", "", names(test_obj$estimate))
  group_labels <- paste0("Group mean: ",
                         toTitleCase(group_short),
                         " (", var_name, ")")

  t_with_df <- paste0(round(test_obj$statistic, 3),
                      " (df = ", round(test_obj$parameter, 2), ")")

  ci_level  <- attr(test_obj$conf.int, "conf.level")
  ci_pct    <- paste0(ci_level * 100, "%")
  mean_diff <- round(diff(rev(test_obj$estimate)), 2)
  ci_string <- paste0(round(mean_diff, 2),
                      " [", round(test_obj$conf.int[1], 2),
                      ", ",  round(test_obj$conf.int[2], 2), "]")
  ci_label  <- paste0("Mean diff [", ci_pct, " CI]")

  var_equal      <- !grepl("Welch", test_obj$method)
  var_equal_note <- paste0("var.equal = ", tolower(as.character(var_equal)), ".")

  tbl <- tibble(
    Statistic = c(group_labels, "Test statistic (t)", ci_label, "p-value"),
    Value     = c(round(test_obj$estimate[1], 2),
                  round(test_obj$estimate[2], 2),
                  t_with_df,
                  ci_string,
                  .fmt_p(test_obj$p.value))
  )

  .make_ft(tbl, paste0("Test: ", test_obj$method), var_equal_note)
}


# ── One-sample t-test ──────────────────────────────────────────────────────────
.tks_ttest_one <- function(test_obj) {

  var_name <- sub(".*\\$", "", trimws(test_obj$data.name))

  t_with_df <- paste0(round(test_obj$statistic, 3),
                      " (df = ", round(test_obj$parameter, 2), ")")

  ci_level  <- attr(test_obj$conf.int, "conf.level")
  ci_pct    <- paste0(ci_level * 100, "%")
  ci_string <- paste0("[", round(test_obj$conf.int[1], 2),
                      ", ",  round(test_obj$conf.int[2], 2), "]")
  ci_label  <- paste0(ci_pct, " CI for mean")

  mu_note <- paste0("Null hypothesis: true mean = ", test_obj$null.value)

  tbl <- tibble(
    Statistic = c(paste0("Sample mean (", var_name, ")"),
                  "Test statistic (t)",
                  ci_label,
                  "p-value"),
    Value     = c(round(test_obj$estimate, 2),
                  t_with_df,
                  ci_string,
                  .fmt_p(test_obj$p.value))
  )

  .make_ft(tbl, paste0("Test: ", test_obj$method), mu_note)
}


# ── Wilcoxon / Mann-Whitney ────────────────────────────────────────────────────
.tks_wilcox <- function(test_obj) {

  # W statistic
  w_stat <- round(test_obj$statistic, 3)

  # Hodges-Lehmann estimate and CI (present only when conf.int was requested)
  has_ci  <- !is.null(test_obj$conf.int)
  ci_rows <- if (has_ci) {
    ci_level  <- attr(test_obj$conf.int, "conf.level")
    ci_pct    <- paste0(ci_level * 100, "%")
    hl_est    <- round(test_obj$estimate, 3)
    ci_string <- paste0(round(hl_est, 2),
                        " [", round(test_obj$conf.int[1], 2),
                        ", ",  round(test_obj$conf.int[2], 2), "]")
    ci_label  <- paste0("HL estimate [", ci_pct, " CI]")
    list(stats = ci_label, vals = ci_string)
  } else NULL

  stats <- c("Test statistic (W)", if (has_ci) ci_rows$stats, "p-value")
  vals  <- c(w_stat,               if (has_ci) ci_rows$vals,  .fmt_p(test_obj$p.value))

  tbl <- tibble(Statistic = stats, Value = vals)

  alt_note <- paste0("Alternative hypothesis: ", test_obj$alternative, ".")
  hl_note  <- if (has_ci) {
    paste0("W: Wilcoxon rank-sum statistic (number of times observations in ",
           "group 1 precede observations in group 2). ",
           "HL: Hodges-Lehmann estimator (median of all pairwise differences ",
           "between groups).")
  } else {
    paste0("W: Wilcoxon rank-sum statistic (number of times observations in ",
           "group 1 precede observations in group 2).")
  }
  .make_ft(tbl, paste0("Test: ", test_obj$method), c(alt_note, hl_note))
}


# ── Chi-squared test ───────────────────────────────────────────────────────────
.tks_chisq <- function(test_obj) {

  chi_with_df <- paste0(round(test_obj$statistic, 3),
                        " (df = ", test_obj$parameter, ")")

  tbl <- tibble(
    Statistic = c("Test statistic (\u03c7\u00b2)", "p-value"),
    Value     = c(chi_with_df, .fmt_p(test_obj$p.value))
  )

  # Yates' correction is only possible for 2x2 tables. R signals it was applied
  # by writing "Yates" into $method. For larger tables R silently ignores the
  # correct argument, so we check the observed matrix dimensions first.
  is_2x2 <- !is.null(test_obj$observed) && all(dim(test_obj$observed) == 2)
  yates_note <- if (grepl("Yates", test_obj$method)) {
    "Yates' continuity correction applied (correct = TRUE)."
  } else if (is_2x2) {
    "Yates' continuity correction not applied (correct = FALSE)."
  } else {
    "Yates' continuity correction not applicable (table larger than 2\u00d72)."
  }

  .make_ft(tbl, paste0("Test: ", test_obj$method), yates_note)
}


# ── Fisher's exact test ────────────────────────────────────────────────────────
.tks_fisher <- function(test_obj) {

  has_or  <- !is.null(test_obj$estimate)
  has_ci  <- !is.null(test_obj$conf.int)

  stats <- "p-value"
  vals  <- .fmt_p(test_obj$p.value)

  if (has_or) {
    or_val <- round(test_obj$estimate, 3)

    if (has_ci) {
      ci_level  <- attr(test_obj$conf.int, "conf.level")
      ci_pct    <- paste0(ci_level * 100, "%")
      or_ci_str <- paste0(or_val,
                          " [", round(test_obj$conf.int[1], 3),
                          ", ",  round(test_obj$conf.int[2], 3), "]")
      or_label  <- paste0("OR [", ci_pct, " CI]")
    } else {
      or_ci_str <- as.character(or_val)
      or_label  <- "Odds ratio"
    }

    stats <- c(or_label, stats)
    vals  <- c(or_ci_str, vals)
  }

  alt_note <- paste0("Alternative hypothesis: ", test_obj$alternative, ".")
  tbl <- tibble(Statistic = stats, Value = vals)
  .make_ft(tbl, paste0("Test: ", test_obj$method), alt_note)
}


# ── Correlation test ───────────────────────────────────────────────────────────
.tks_cor <- function(test_obj) {

  # Variable names
  var_names <- trimws(unlist(strsplit(test_obj$data.name, " and ")))
  var_names <- sub(".*\\$", "", var_names)   # drop "df$" prefix if present
  var_label <- paste(var_names, collapse = " & ")

  # Correlation coefficient label depends on method
  method_short <- sub(".*?(Pearson|Spearman|Kendall).*", "\\1", test_obj$method)
  coef_symbol  <- switch(method_short,
                         Pearson  = "r",
                         Spearman = "\u03c1",   # ρ
                         Kendall  = "\u03c4",   # τ
                         "r")
  coef_label   <- paste0(method_short, "'s ", coef_symbol,
                         " (", var_label, ")")

  stats <- c(coef_label, "p-value")
  vals  <- c(round(test_obj$estimate, 3), .fmt_p(test_obj$p.value))

  # CI (present for Pearson by default)
  if (!is.null(test_obj$conf.int)) {
    ci_level  <- attr(test_obj$conf.int, "conf.level")
    ci_pct    <- paste0(ci_level * 100, "%")
    ci_string <- paste0("[", round(test_obj$conf.int[1], 3),
                        ", ",  round(test_obj$conf.int[2], 3), "]")
    ci_label  <- paste0(ci_pct, " CI")
    # Insert after coefficient row
    stats <- append(stats, ci_label, after = 1)
    vals  <- append(vals,  ci_string, after = 1)
  }

  # df for Pearson / t-statistic row
  if (!is.null(test_obj$parameter)) {
    t_str  <- paste0(round(test_obj$statistic, 3),
                     " (df = ", round(test_obj$parameter, 2), ")")
    stats  <- append(stats, "Test statistic (t)", after = length(stats) - 1)
    vals   <- append(vals,  t_str,                after = length(vals)  - 1)
  }

  alt_note <- paste0("Alternative hypothesis: ", test_obj$alternative, ".")
  tbl <- tibble(Statistic = stats, Value = vals)
  .make_ft(tbl, paste0("Test: ", test_obj$method), alt_note)
}


# ── One-way ANOVA ──────────────────────────────────────────────────────────────
.tks_anova <- function(test_obj) {

  # Normalise: accept aov object or summary(aov(...)) list
  smry <- if (inherits(test_obj, "aov")) {
    summary(test_obj)[[1]]
  } else if (is.list(test_obj) && inherits(test_obj[[1]], "anova")) {
    test_obj[[1]]
  } else {
    as.data.frame(test_obj)
  }

  # Row names: trim whitespace (R adds trailing spaces)
  row_nms <- trimws(rownames(smry))

  # Pull ANOVA table values
  df_vals  <- smry[["Df"]]
  ss_vals  <- round(smry[["Sum Sq"]], 3)
  ms_vals  <- round(smry[["Mean Sq"]], 3)
  f_vals   <- smry[["F value"]]
  p_vals   <- smry[["Pr(>F)"]]

  # Build three-column tidy table: Source | Statistic | Value
  # Source is filled for the first row of each term, blank for subsequent rows
  sources <- character(0)
  stats   <- character(0)
  vals    <- character(0)

  for (i in seq_along(row_nms)) {
    src        <- row_nms[i]
    has_f      <- !is.na(f_vals[i])
    n_rows     <- if (has_f) 5L else 3L   # df, SS, MS [, F, p]

    sources <- c(sources, src, rep("", n_rows - 1L))
    stats   <- c(stats, "df", "Sum of Squares", "Mean Square")
    vals    <- c(vals,
                 as.character(df_vals[i]),
                 as.character(ss_vals[i]),
                 as.character(ms_vals[i]))

    if (has_f) {
      stats <- c(stats, "F statistic", "p-value")
      vals  <- c(vals, as.character(round(f_vals[i], 3)), .fmt_p(p_vals[i]))
    }
  }

  tbl <- tibble(Source = sources, Statistic = stats, Value = vals)

  ft <- flextable(tbl) |>
    set_header_labels(Source = "Source", Statistic = "Statistic", Value = "Value") |>
    add_header_row(values = "Test: One-way ANOVA", colwidths = 3) |>
    bold(part = "header") |>
    italic(i = 1, part = "header") |>
    align(i = 1, align = "center", part = "header") |>
    theme_booktabs() |>
    autofit()

  ft
}
