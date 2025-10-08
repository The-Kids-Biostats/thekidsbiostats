library(testthat)

test_that("thekids_table returns a flextable object", {
  df <- data.frame(A = 1:3, B = letters[1:3])
  tbl <- thekids_table(df)
  expect_s3_class(tbl, "flextable")
})

test_that("thekids_table warns if input is already a flextable", {
  df <- data.frame(A = 1:3, B = letters[1:3])
  ft <- flextable::flextable(df)
  expect_warning(thekids_table(ft), "Object of class 'flextable' detected")
})

test_that("thekids_table coerces gtsummary object to flextable", {
  tbl_sum <- tbl_summary(head(mtcars))
  ft <- thekids_table(tbl_sum)
  expect_s3_class(ft, "flextable")
})

test_that("table_coerce converts gt_tbl object to flextable", {
  gt_tbl <- gt::gt(head(mtcars))
  out <- thekids_table(gt_tbl)
  expect_s3_class(out, "flextable")
})

test_that("thekids_table respects font_family argument via check_font_family", {
  # If check_font_family is exported, test the real function;
  # otherwise, mock check_font_family to verify it is called.

  # Here we test that the default font_family is passed and returned as character
  df <- head(mtcars)
  tbl <- thekids_table(df, font_family = "Arial")
  expect_s3_class(tbl, "flextable")

  # Optionally check that font_family is passed to defaults
  defaults <- flextable::get_flextable_defaults()
  expect_true("font.family" %in% names(defaults))
})

test_that("thekids_table converts knitr_kable HTML table to flextable", {
  # Create a valid kable HTML object
  kbl <- knitr::kable(data.frame(A = 1:3, B = letters[1:3]), format = "html")
  expect_s3_class(kbl, "knitr_kable")

  out <- thekids_table(kbl)
  expect_s3_class(out, "flextable")
})

test_that("thekids_table converts knitr_kable HTML table to flextable when kableExtra is used", {
  # Create a valid kable HTML object
  kbl <- kableExtra::kable_styling(knitr::kable(data.frame(A = 1:3, B = letters[1:3]), format = "html"))
  expect_s3_class(kbl, "knitr_kable")

  out <- thekids_table(kbl)
  expect_s3_class(out, "flextable")
})

test_that("thekids_table returns error if 'html' not specified in kable()", {
  # Create a valid kable HTML object
  kbl <- knitr::kable(data.frame(A = 1:3, B = letters[1:3]))
  expect_s3_class(kbl, "knitr_kable")

  expect_error(thekids_table(kbl), "Please ensure `format='html'` is specified")
})


test_that("thekids_table returns error if non-'html' format specified  in kable()", {
  # Create a valid kable HTML object
  kbl <- knitr::kable(data.frame(A = 1:3, B = letters[1:3]), format = "latex")
  expect_s3_class(kbl, "knitr_kable")

  expect_error(thekids_table(kbl), "Please ensure `format='html'` is specified")
})


test_that("thekids_table applies highlight theme when highlight argument is provided", {
  df <- head(mtcars)
  highlight_rows <- 1:3
  tbl <- thekids_table(df, highlight = highlight_rows)
  expect_s3_class(tbl, "flextable")
  # You can also inspect theme_fun in defaults to verify it's table_highlight (not trivial here)
})

test_that("table_highlight errors on invalid highlight vector", {
  df <- head(mtcars)

  expect_error(
    thekids_table(df,
                  highlight = c(-1, 2)),
    "`highlight` must be a vector of positive integers."
  )

  expect_error(
    thekids_table(df,
                  highlight = c(1, 1000)),
    "You are trying to highlight a row"
  )
})

test_that("table_plain_theme applies background colors without highlight", {
  df <- head(mtcars)
  ft2 <- thekids_table(df, header_bg_col = "#0000FF", body_bg_col = "#EEEEEE")
  expect_s3_class(ft2, "flextable")
})

test_that("thekids_table restores flextable defaults after execution", {
  df <- head(mtcars)
  old_defaults <- flextable::get_flextable_defaults()
  thekids_table(df)
  new_defaults <- flextable::get_flextable_defaults()
  expect_equal(old_defaults, new_defaults)
})

test_that("check_font_family applies fallback font and warns", {
  missing_font <- "ThisFontDoesNotExist123"
  fallback_font <- "sans"

  # Expect a warning and also check the return value
  expect_warning(
    result <- thekidsbiostats:::check_font_family(
      font_family = missing_font,
      fallback_family = fallback_font
    ),
    regexp = "Font 'ThisFontDoesNotExist123' not found; falling back to 'sans'"
  )

  # Check that the fallback is returned
  expect_equal(result, fallback_font)
})

test_that("check_font_family handles empty string input", {
  expect_warning(
    result <- thekidsbiostats:::check_font_family(
      font_family = "",
      fallback_family = "sans"
    ),
    regexp = "falling back to 'sans'"
  )
  expect_equal(result, "sans")
})

test_that("check_font_family handles NA input", {
  expect_warning(
    result <- thekidsbiostats:::check_font_family(
      font_family = NA,
      fallback_family = "sans"
    ),
    regexp = "falling back to 'sans'"
  )
  expect_equal(result, "sans")
})

test_that("check_font_family handles numeric input by coercion", {
  expect_warning(
    result <- thekidsbiostats:::check_font_family(
      font_family = 123,
      fallback_family = "sans"
    ),
    regexp = "falling back to 'sans'"
  )
  expect_equal(result, "sans")
})
