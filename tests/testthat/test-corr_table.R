library(testthat)

# Basic functionality
# i)
test_that("returns a flextable by default", {
  tbl <- corr_table(x = dat$x, y = dat$y)

  expect_s3_class(tbl, "flextable")
})

# ii)
test_that("works with x/y names and data argument", {
  tbl <- corr_table(x = "x", y = "y", data = dat)

  expect_s3_class(tbl, "flextable")
})

# iii)
test_that("works with formula interface", {
  tbl <- corr_table(formula = ~ x + y, data = dat)

  expect_s3_class(tbl, "flextable")
})

# iv)
test_that("formula interface errors without data", {
  expect_error(
    corr_table(formula = x ~ y),
    "Provide data with formula"
  )
})

# v)
test_that("supports pearson, spearman, kendall methods", {
  expect_s3_class(
    corr_table(x = dat$x, y = dat$y, method = "pearson"),
    "flextable"
  )

  expect_s3_class(
    corr_table(x = dat$x, y = dat$y, method = "spearman"),
    "flextable"
  )

  expect_s3_class(
    corr_table(x = dat$x, y = dat$y, method = "kendall"),
    "flextable"
  )
})

# vi)
test_that("invalid method errors", {
  expect_error(
    corr_table(x = dat$x, y = dat$y, method = "nonsense"),
    "should be one of"
  )
})

# vii)
test_that("alternative argument is respected", {
  tbl <- corr_table(
    x = dat$x,
    y = dat$y,
    alternative = "greater"
  )

  expect_s3_class(tbl, "flextable")
})

# Ensure table elements are as expected
## i)
test_that("confidence interval column is present", {
  res <- corr_table(
    x = dat$x,
    y = dat$y,
    conf.level = 0.9
  )

  # Extract caption text to ensure CI label exists indirectly
  caption <- paste0(100*0.9, "% CI") %in% res$body$col_keys
  expect_true(caption)
})

# Plot elements
## i)
test_that("return_plot = TRUE returns a named list", {
  out <- corr_table(
    x = dat$x,
    y = dat$y,
    return_plot = TRUE
  )

  expect_type(out, "list")
  expect_named(out, c("table", "plot", "test", "tidy"))
})

test_that("plot element is a ggplot", {
  out <- corr_table(
    x = dat$x,
    y = dat$y,
    return_plot = TRUE
  )

  expect_s3_class(out$plot, "ggplot")
})

test_that("test element is htest", {
  out <- corr_table(
    x = dat$x,
    y = dat$y,
    return_plot = TRUE
  )

  expect_s3_class(out$test, "htest")
})

test_that("tidy element is a data.frame", {
  out <- corr_table(
    x = dat$x,
    y = dat$y,
    return_plot = TRUE
  )

  expect_s3_class(out$tidy, "data.frame")
})

# Plot options
## i)
test_that("add_smooth = FALSE removes smoother layer", {
  out <- corr_table(
    x = dat$x,
    y = dat$y,
    add_smooth = FALSE,
    return_plot = TRUE
  )

  layer_classes <- vapply(out$plot$layers, function(l) class(l$geom)[1], character(1))
  expect_false("GeomSmooth" %in% layer_classes)
})


# Rounding is as expected
test_that("round_digits affects output numerics", {
  out1 <- corr_table(
    x = dat$x,
    y = dat$y,
    round_digits = 1,
    return_plot = TRUE
  )

  out3 <- corr_table(
    x = dat$x,
    y = dat$y,
    round_digits = 3,
    return_plot = TRUE
  )

  expect_false(identical(out1$tidy, out3$tidy))
})
