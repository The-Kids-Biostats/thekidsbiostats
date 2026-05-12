library(testthat)
library(ggplot2)
library(vdiffr)

test_that("returns correct scale when discrete is TRUE or FALSE", {
  scale_discrete <- scale_colour_thekids(discrete = TRUE)
  expect_s3_class(scale_discrete, "ScaleDiscrete")

  scale_cont <- scale_colour_thekids(discrete = FALSE)
  expect_s3_class(scale_cont, "ScaleContinuous")
})


test_that("discrete scale works in ggplot", {
  p <- ggplot(mtcars, aes(factor(cyl), colour = factor(cyl))) +
    geom_bar(linewidth=2, fill="transparent") +
    theme_thekids() +
    scale_colour_thekids(discrete = TRUE)

  expect_s3_class(p, "ggplot")
})


test_that("continuous scale works in ggplot", {
  p <- ggplot(mtcars, aes(mpg, wt, colour = mpg)) +
    geom_point(stroke=2, shape = 21, size=2) +
    theme_thekids() +
    scale_colour_thekids(discrete = FALSE)

  expect_s3_class(p, "ggplot")
})


test_that("palette is applied correctly for discrete scale", {
  pal <- thekids_pal("primary", TRUE, FALSE)
  expected <- pal(3)

  scale <- scale_colour_thekids("primary", TRUE)

  # Extract palette from scale
  actual <- scale$palette(3)

  expect_equal(actual, expected)
})

test_that("scale_colour_thekids() defaults to the primary palette", {
  expected <- thekids_pal("primary", TRUE, FALSE)(3)

  scale <- scale_colour_thekids()
  actual <- scale$palette(3)

  expect_equal(actual, expected)
})


test_that("invalid palette throws error", {
  expect_error(
    scale_colour_thekids("not_a_palette"),
    regexp = "palette"
  )
})


test_that("scale_colour_thekids() respects reverse argument", {
  sc1 <- scale_colour_thekids(reverse = FALSE)
  sc2 <- scale_colour_thekids(reverse = TRUE)

  expect_s3_class(sc1, "ScaleDiscrete")
  expect_s3_class(sc2, "ScaleDiscrete")

  expect_equal(sc1$palette(3), rev(sc2$palette(3)))

})


test_that("sequential palette names give the correct palette", {

  seq_palettes <- names(thekids_palettes$sequential)

  # expected palette

  for (pal in seq_palettes){
    pal_expected <- thekids_palettes$sequential[[pal]]
    expected_cols <- pal_expected(10)
    
    # scale-generated palette
    scale <- scale_colour_thekids(pal, discrete = TRUE)
    actual_cols <- scale$palette(10)
    
    expect_equal(actual_cols, expected_cols)
  }
  
})


test_that("divergin palette names give the correct palette", {

  div_palettes <- names(thekids_palettes$diverging)

  # expected palette

  for (pal in div_palettes){
    pal_expected <- thekids_palettes$diverging[[pal]]
    expected_cols <- pal_expected(10)
    
    # scale-generated palette
    scale <- scale_colour_thekids(pal, discrete = TRUE)
    actual_cols <- scale$palette(10)
    
    expect_equal(actual_cols, expected_cols)
  }
  
})


### Visual Tests
# test_that("discrete scale visually looks correct", {
#   p <- ggplot(mtcars, aes(factor(cyl), colour = factor(cyl))) +
#     geom_bar(linewidth=2, fill="transparent") +
#     thekids_theme() +
#     scale_colour_thekids("primary", discrete = TRUE)

#   vdiffr::expect_doppelganger("discrete primary palette", p)
# })


# test_that("continuous scale visually looks correct", {
#   p <- ggplot(mtcars, aes(mpg, wt, colour = mpg)) +
#     geom_point(shape = 21, size = 3) +
#     thekids_theme() +
#     scale_colour_thekids("primary", discrete = FALSE)

#   vdiffr::expect_doppelganger("continuous primary palette", p)
# })


# test_that("reverse palette changes appearance", {
#   p <- ggplot(mtcars, aes(factor(cyl), colour = factor(cyl))) +
#     geom_bar(linewidth=2, fill="transparent") +
#     thekids_theme() +
#     scale_colour_thekids("primary", reverse = TRUE)

#   vdiffr::expect_doppelganger("reversed palette", p)
# })
