library(testthat)

test_that("Returns a factor with correct levels in order given", {
  x <- 1:10
  out <- fct_case_when(
    x %% 2 == 0 ~ "even",
    TRUE ~ "odd"
  )
  expect_s3_class(out, "factor")
  expect_equal(levels(out), c("even", "odd"))
})

test_that("values are assigned correctly based on conditions", {
  x <- 1:5
  out <- fct_case_when(
    x %% 2 == 0 ~ "even",
    TRUE ~ "odd"
  )
  expect_equal(as.character(out), c("odd", "even", "odd", "even", "odd"))
})

test_that("handles multiple conditions and preserves order of RHS", {
  x <- 1:15
  out <- fct_case_when(
    x %% 15 == 0 ~ "fizzbuzz",
    x %% 3 == 0 ~ "fizz",
    x %% 5 == 0 ~ "buzz",
    TRUE ~ "other"
  )
  expect_equal(levels(out), c("fizzbuzz", "fizz", "buzz", "other"))
})

test_that("NA values in conditions are preserved", {
  x <- c(1, 2, NA, 5)
  out <- fct_case_when(
    x == 1 ~ "one",
    x == 2 ~ "two",
    TRUE ~ "other"
  )
  expect_true(is.na(out[3]))
})

test_that("error when RHS types are inconsistent", {
  x <- 1:3
  expect_error(
    fct_case_when(
      x == 1 ~ "one",
      TRUE ~ 2
    )
  )
})
