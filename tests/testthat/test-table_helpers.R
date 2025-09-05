library(testthat)


test_that("table_theme requires a flextable", {
  expect_error(table_theme(head(mtcars),
                           header_bg = c(odd = "red", even = "blue"),
                           footer_bg = c(odd = "red", even = "blue"),
                           body_bg   = c(odd = "red", even = "blue")))
})


test_that("table_theme applies alternating header/body backgrounds", {
  ft <- flextable::flextable(head(mtcars, 10))
  styled_ft <- table_theme(ft,
                           header_bg = c(odd = "red", even = "blue"),
                           footer_bg = c(odd = "red", even = "blue"),
                           body_bg   = c(odd = "green", even = "yellow"))

  expect_s3_class(styled_ft, "flextable")  # still a flextable?

  expect_equal(nrow(styled_ft$body$dataset), 10)  # check number of rows unchanged

  body_styles <- styled_ft$body$styles
  bgs <- body_styles$cells$background.color$data
  odd_bgs <- unique(bgs[seq_len(nrow(styled_ft$body$dataset)) %% 2 == 1])
  even_bgs <- unique(bgs[seq_len(nrow(styled_ft$body$dataset)) %% 2 == 0])
})


test_that("table_highlight errors for invalid highlight argument", {
  ft <- flextable::flextable(head(mtcars, 10))

  expect_error(table_highlight(ft, "CoolGrey", highlight = -1),
               "`highlight` must be a vector of positive integers")
  expect_error(table_highlight(ft, "CoolGrey", highlight = 1.5),
               "`highlight` must be a vector of positive integers")
  expect_error(table_highlight(ft, "CoolGrey", highlight = 11),
               "beyond the number of rows")
})


test_that("table_highlight applies row highlighting", {
  ft <- flextable::flextable(head(mtcars, 10))

  highlight_rows <- c(2, 4)
  styled_ft <- table_highlight(ft, "CoolGrey", highlight = highlight_rows)

  expect_s3_class(styled_ft, "flextable")

  body_styles <- styled_ft$body$styles
  bg_colours <- body_styles$cells$background.color$data
  for (ii in seq(nrow(bg_colours))){  # for each row, test backgrounds are correct
    row_cols <- bg_colours[ii, ]
    if (ii %in% highlight_rows) {
      expect_true(all(row_cols == thekidsbiostats::thekids_palettes$tint50[['CoolGrey']]))
    } else {
      expect_false(any(row_cols == thekidsbiostats::thekids_palettes$tint50[['CoolGrey']]))
    }
  }
})


test_that("table_zebra and table_non_zebra return flextables", {
  ft <- flextable::flextable(head(mtcars, 10))

  zebra <- table_zebra(ft, "CoolGrey")
  non_zebra <- table_non_zebra(ft, "CoolGrey")

  expect_s3_class(zebra, "flextable")
  expect_s3_class(non_zebra, "flextable")
})


test_that("table_highlight errors for invalid colour", {
  ft <- flextable(head(mtcars, 10))
  expect_error(
    table_highlight(ft, colour = "notacolour", highlight = 1),
    "Invalid colour"
  )
})


test_that("table_highlight works with NULL highlight", {
  ft <- flextable(head(mtcars, 10))
  styled_ft <- table_highlight(ft, colour = "CoolGrey", highlight = NULL)

  # no row should have the highlight colour
  body_styles <- styled_ft$body$styles
  bg_colours <- body_styles$cells$background.color$data
  expect_true(any(is.na(bg_colours)))
})




test_that("table_coerce input is unchanged if already flextable", {
  ft <- flextable::flextable(head(mtcars))
  out <- table_coerce(ft, date_fix = TRUE)
  expect_s3_class(out, "flextable")
  expect_identical(out, ft)
})


test_that("table_coerce handles gtsummary input", {
  skip_if_not_installed("gtsummary")
  gtsummary_tbl <- gtsummary::tbl_summary(mtcars, by = cyl)
  out <- table_coerce(gtsummary_tbl, date_fix = TRUE)
  expect_s3_class(out, "flextable")
})


test_that("table_coerce handles gt_tbl input", {
  skip_if_not_installed("gt")
  gt_tbl <- gt::gt(head(mtcars))
  out <- table_coerce(gt_tbl, date_fix = TRUE)
  expect_s3_class(out, "flextable")
})


test_that("table_coerce handles data.frame input", {
  df <- head(mtcars)
  out <- table_coerce(df, date_fix = TRUE)
  expect_s3_class(out, "flextable")
})


test_that("table_coerce errors on non-html knitr_kable", {
  skip_if_not_installed("knitr")
  kb <- knitr::kable(head(mtcars), format = "latex")
  expect_error(table_coerce(kb, date_fix = TRUE),
               "Please ensure `format='html'` is specified")
})


test_that("table_coerce errors on non-html knitr_kable: latex outputs", {
  skip_if_not_installed("knitr")
  kb <- knitr::kable(head(mtcars), format = "latex")
  expect_error(table_coerce(kb, date_fix = TRUE),
               "Please ensure `format='html'` is specified")
})


test_that("table_coerce errors on non-html knitr_kable: listed outputs", {
  skip_if_not_installed("knitr")
  kb <- knitr::kable(head(mtcars), format = "pipe")
  expect_error(table_coerce(kb, date_fix = TRUE),
               "Please ensure `format='html'` is specified")
})


test_that("table_coerce warns of row names detected in column", {
  skip_if_not_installed("knitr")
  kb <- knitr::kable(head(mtcars), format = "html")
  expect_warning(table_coerce(kb, date_fix = TRUE),
                 "Row names have been detected")
})


test_that("table_coerce handles valid html knitr_kable", {
  skip_if_not_installed("knitr")
  kb <- knitr::kable(tibble::rownames_to_column(head(mtcars)), format = "html")
  out <- table_coerce(kb, date_fix = TRUE)
  expect_s3_class(out, "flextable")
})




test_that("kable_colnames errors on non-data.frame input", {
  expect_error(kable_colnames(matrix(1:4, ncol = 2)),
               "`fix_empty_colnames\\(\\)` expects a data frame")
})


test_that("kable_colnames replaces all missing names", {
  df <- data.frame(a = 1:3, b = 4:6)
  names(df) <- NULL

  expect_warning(
    out <- kable_colnames(df, prefix = "col"),
    "All column names were missing and have been replaced"
  )

  expect_equal(names(out), c("col1", "col2"))
})


test_that("kable_colnames replaces some empty names", {
  df <- data.frame(a = 1:3, b = 4:6, c = 7:9)
  names(df) <- c("first", "", "third")

  expect_warning(
    out <- kable_colnames(df, prefix = "col"),
    "Row names have been detected"
  )

  # first and third unchanged, middle renamed to col[#]
  expect_equal(names(out)[c(1, 3)], c("first", "third"))
  expect_match(names(out)[2], "^col[0-9]+")
})


test_that("kable_colnames leaves valid names alone", {
  df <- data.frame(a = 1:3, b = 4:6)
  expect_silent(out <- kable_colnames(df))
  expect_identical(out, df)
})




test_that("get_num_body_rows works with flextable", {
  ft <- flextable::flextable(head(mtcars, n = 10))
  out <- get_num_body_rows(ft)
  expect_equal(out, 10)
})


test_that("get_num_body_rows works with gtsummary", {
  skip_if_not_installed("gtsummary")

  columns <- c('mpg', 'cyl', 'disp', 'hp', 'drat', 'wt', 'qsec', 'vs', 'am')
  gtsummary_tbl <- gtsummary::tbl_summary(mtcars[columns], by = cyl)
  out <- get_num_body_rows(gtsummary_tbl)

  # tbl_summary (with by=`col`) has one less row than the number of columns in the input
  expect_true(out == length(columns) - 1)
})


test_that("get_num_body_rows works with gt_tbl", {
  skip_if_not_installed("gt")
  gt_tbl <- gt::gt(head(mtcars, 10))
  out <- get_num_body_rows(gt_tbl)
  expect_equal(out, 10)
})


test_that("get_num_body_rows works with data.frame", {
  df <- head(mtcars, 10)
  out <- get_num_body_rows(df)
  expect_equal(out, 10)
})


test_that("get_num_body_rows works with tibble", {
  tb <- tibble::as_tibble(head(mtcars, 10))
  out <- get_num_body_rows(tb)
  expect_equal(out, 10)
})


test_that("get_num_body_rows works with knitr_kable (html)", {
  skip_if_not_installed("knitr")
  kb <- knitr::kable(tibble::rownames_to_column(head(mtcars, 10)), format = "html")
  out <- get_num_body_rows(kb)
  expect_equal(out, 10)
})
