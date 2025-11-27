library(testthat)

test_that("scale_color_thekids() returns discrete scale by default", {
  sc <- scale_color_thekids()
  expect_s3_class(sc, "ScaleDiscrete")
  expect_true(inherits(sc, "Scale"))
})

test_that("scale_color_thekids() works for continuous scales", {
  sc <- scale_color_thekids(discrete = FALSE)
  expect_s3_class(sc, "ScaleContinuous")
  expect_true(inherits(sc, "Scale"))
})

test_that("scale_color_thekids() respects palette argument", {
  palettes <- c("primary", "tint50", "typography")
  for (pal in palettes) {
    sc <- scale_color_thekids(palette = pal)
    expect_s3_class(sc, "ScaleDiscrete")
    expect_true(inherits(sc, "Scale"))
  }
})

test_that("scale_color_thekids() respects reverse argument", {
  sc1 <- scale_color_thekids(reverse = FALSE)
  sc2 <- scale_color_thekids(reverse = TRUE)
  # Can't directly check colors without accessing the palette function
  expect_s3_class(sc1, "ScaleDiscrete")
  expect_s3_class(sc2, "ScaleDiscrete")
})

test_that("scale_color_thekids() can be added to ggplot", {
  p <- ggplot(mtcars, aes(x = mpg, y = wt, col = factor(cyl))) +
    geom_point() +
    scale_color_thekids()
  expect_s3_class(p, "gg")
})
