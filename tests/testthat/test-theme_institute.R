library(testthat)

test_that("theme_institute() can be used with ggplot2 objects", {
  expect_warning(
    th <- theme_institute(),
    "deprecated"
  )

  p <- ggplot2::ggplot(ggplot2::mpg, ggplot2::aes(displ, hwy)) +
    ggplot2::geom_point() + th

  expect_s3_class(p, "gg")
})

test_that("theme_institute() triggers deprecation warning and returns correct objects", {
  # Capture deprecation warning
  result <- withCallingHandlers(
    theme_institute(),
    warning = function(w) {
      expect_match(conditionMessage(w), "deprecated")
      invokeRestart("muffleWarning")
    }
  )

  # result is a list of length 3
  expect_type(result, "list")
  expect_length(result, 3)

  # The first element is a ggplot2 theme
  expect_s3_class(result[[1]], "theme")

  # The second and third elements are ggplot2 scales
  expect_s3_class(result[[2]], c("ScaleDiscrete", "ScaleContinuous"))
  expect_s3_class(result[[3]], c("ScaleDiscrete", "ScaleContinuous"))
})

test_that("theme_institute() handles continuous and discrete scales", {
  result_disc <- withCallingHandlers(theme_institute(scale_colour_type = "discrete",
                                                     scale_fill_type = "discrete"),
                                     warning = function(w) invokeRestart("muffleWarning"))

  result_cont <- withCallingHandlers(theme_institute(scale_colour_type = "continuous",
                                                     scale_fill_type = "continuous"),
                                     warning = function(w) invokeRestart("muffleWarning"))

  expect_s3_class(result_disc[[2]], c("ScaleDiscrete","ScaleContinuous"))
  expect_s3_class(result_disc[[3]], c("ScaleDiscrete","ScaleContinuous"))

  expect_s3_class(result_cont[[2]], c("ScaleDiscrete","ScaleContinuous"))
  expect_s3_class(result_cont[[3]], c("ScaleDiscrete","ScaleContinuous"))
})

test_that("theme_institute() handles reversed palettes", {
  result <- withCallingHandlers(theme_institute(rev_colour = TRUE, rev_fill = TRUE),
                                warning = function(w) invokeRestart("muffleWarning"))
  expect_s3_class(result[[2]], c("ScaleDiscrete","ScaleContinuous"))
  expect_s3_class(result[[3]], c("ScaleDiscrete","ScaleContinuous"))
})

test_that("theme_institute() sets OS-specific fonts", {
  result <- withCallingHandlers(theme_institute(),
                                warning = function(w) invokeRestart("muffleWarning"))
  theme1 <- result[[1]]
  families <- unlist(theme1$plot.title$family)
  expect_true(any(grepl("Barlow", families)))
})
