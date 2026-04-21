library(testthat)
library(ggplot2)

test_that("thekids_theme returns expected list structure", {
  thm <- thekids_theme()
  expect_type(thm, "list")
  expect_s3_class(thm[[1]], "theme")
  expect_length(thm, 1)
})

test_that("theme can be applied to a ggplot", {
  p <- ggplot(mtcars, aes(mpg, wt)) +
    geom_point() +
    thekids_theme(base_size=10)

  expect_s3_class(p, "ggplot")
})

test_that("font fallback triggers warning but theme retains requested family", {
  bad_font <- "FakeFontForTest"

  expect_warning(
    theme_res <- thekids_theme(base_family = bad_font),
    "Could not load Google Font"
  )

  # fallback warning is emitted, but the returned theme still uses the requested family
  expect_s3_class(theme_res[[1]], "theme")
  expect_equal(theme_res[[1]]$text$family, bad_font)
})

test_that("non-default font triggers message, even if font fails to load", {
  skip_if_not_installed("showtext")

  default_font <- "Barlow"
  non_default_font <- "Arial"  # unlikely to exist locally

  expect_message(
    theme_res <- suppressWarnings(thekids_theme(base_family = non_default_font)),
    regexp = paste0("Non-default font family \\(", non_default_font, "\\) selected")
  )

  # The returned theme should use the requested font
  expect_s3_class(theme_res[[1]], "theme")
  expect_equal(theme_res[[1]]$text$family, non_default_font)
})


test_that("theme contains expected key elements", {
  thm <- thekids_theme()[[1]]

  expect_true("plot.title" %in% names(thm))
  expect_true("axis.text" %in% names(thm))
  expect_true("strip.text" %in% names(thm))
  expect_true("legend.key.size" %in% names(thm))
  expect_true(!is.null(thm$plot.margin))
  expect_true(!is.null(thm$panel.spacing))
})



test_that("deprecated arguments trigger warnings", {
  expect_warning(
    thekids_theme(colour_theme = "x"),
    "Colour scales are now controlled"
  )

  expect_warning(
    thekids_theme(fill_theme = "x"),
    "Fill scales are now controlled"
  )

  expect_warning(
    thekids_theme(scale_colour_type = "x"),
    "Colour scales are now controlled"
  )
})


## Visual Regression Testing
test_that("deprecated arguments trigger warnings", {
  vdiffr::expect_doppelganger(
    "thekids theme basic plot",
    ggplot2::ggplot(mtcars, ggplot2::aes(mpg, wt)) +
      ggplot2::geom_point() +
      ggplot2::labs(
        title = "Plot Title",
        subtitle = "Subtitle"
      ) +
      thekids_theme()
  )
})