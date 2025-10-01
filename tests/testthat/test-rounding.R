library(testthat)

# round_vec tests
test_that("round_vec rounds numeric vector and keeps trailing zeroes", {
  x <- c(1.234, 5.6)
  out <- round_vec(x, 2)
  expect_type(out, "character")
  expect_equal(out, c("1.23", "5.60"))
})

test_that("round_vec works with zero digits", {
  x <- c(1.2, 3.7)
  out <- round_vec(x, 0)
  expect_equal(out, c("1", "4"))
})

test_that("round_vec handles negative numbers", {
  x <- c(-1.234, -5.678)
  out <- round_vec(x, 2)
  expect_equal(out, c("-1.23", "-5.68"))
})

test_that("round_vec handles NA values", {
  x <- c(1.23, NA, 4.56)
  out <- round_vec(x, 2)
  expect_equal(out, c("1.23", NA, "4.56"))
})

# round_df tests
test_that("round_df rounds numeric columns without converting to character", {
  df <- tibble(a = c(1.234, 5.6), b = c("x", "y"))
  out <- round_df(df, 2)
  expect_s3_class(out, "tbl_df")
  expect_true(is.numeric(out$a))
  expect_equal(out$a, c(1.23, 5.60))
})

test_that("round_df rounds numeric columns and converts to character when con_char = TRUE", {
  df <- tibble(a = c(1.234, 5.6), b = c("x", "y"))
  out <- round_df(df, 2, con_char = TRUE)
  expect_s3_class(out, "tbl_df")
  expect_true(is.character(out$a))
  expect_equal(out$a, c("1.23", "5.60"))
})

test_that("round_df handles zero digits correctly", {
  df <- tibble(a = c(1.2, 3.7))
  out <- round_df(df, 0)
  expect_equal(out$a, c(1, 4))
})

test_that("round_df does not affect non-numeric columns", {
  df <- tibble(a = c(1.23, 4.56), b = c("apple", "banana"))
  out <- round_df(df, 1)
  expect_equal(out$b, c("apple", "banana"))
})
