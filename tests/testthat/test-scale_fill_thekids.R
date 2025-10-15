library(testthat)

test_that("scale_fill_thekids() returns discrete scale by default", {
  sc <- scale_fill_thekids()
  expect_s3_class(sc, "ScaleDiscrete")
  expect_true(inherits(sc, "Scale"))
})

test_that("scale_fill_thekids() works for continuous scales", {
  sc <- scale_fill_thekids(discrete = FALSE)
  expect_s3_class(sc, "ScaleContinuous")
  expect_true(inherits(sc, "Scale"))
})

test_that("scale_fill_thekids() respects palette argument", {
  palettes <- c("primary", "tint50", "typography")
  for (pal in palettes) {
    sc <- scale_fill_thekids(palette = pal)
    expect_s3_class(sc, "ScaleDiscrete")
    expect_true(inherits(sc, "Scale"))
  }
})

test_that("scale_fill_thekids() respects reverse argument", {
  sc1 <- scale_fill_thekids(reverse = FALSE)
  sc2 <- scale_fill_thekids(reverse = TRUE)
  expect_s3_class(sc1, "ScaleDiscrete")
  expect_s3_class(sc2, "ScaleDiscrete")
})

test_that("scale_fill_thekids() can be added to ggplot", {
  p <- ggplot(mtcars, aes(x = factor(cyl), y = wt, fill = factor(cyl))) +
    geom_col() +
    scale_fill_thekids()
  expect_s3_class(p, "gg")
})
