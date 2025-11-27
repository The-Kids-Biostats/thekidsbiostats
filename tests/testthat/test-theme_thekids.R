library(testthat)

test_that("thekids_theme returns expected list structure", {
  result <- thekids_theme()
  expect_type(result, "list")
  expect_s3_class(result[[1]], "theme")
  expect_true(length(result) == 3)
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

test_that("viridis handles discrete and continuous scales", {
  result_d <- thekids_theme(scale_colour_type = "discrete", scale_fill_type = "discrete")
  expect_true(inherits(result_d[[2]], "ScaleDiscrete"))
  expect_true(inherits(result_d[[3]], "ScaleDiscrete"))

  result_c <- thekids_theme(scale_colour_type = "continuous", scale_fill_type = "continuous")
  expect_true(inherits(result_c[[2]], "ScaleContinuous"))
  expect_true(inherits(result_c[[3]], "ScaleContinuous"))
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

test_that("argument aliasing triggers standardise_args path", {

  # Use the alias 'color_theme' instead of 'colour_theme'
  theme_res <- thekids_theme(color_theme = "thekids")

  # Should return a list with ggplot theme + colour + fill functions
  expect_type(theme_res, "list")
  expect_s3_class(theme_res[[1]], "theme")

  # The colour scale function should be a ggproto object
  expect_s3_class(theme_res[[2]], "ScaleDiscrete") # scale_color_thekids returns discrete scale
})
