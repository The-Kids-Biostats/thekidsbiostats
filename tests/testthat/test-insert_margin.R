library(testthat)
library(mockery)

test_that("insert_margin inserts margin text when RStudio API is available", {
  inserted <- NULL
  stub(insert_margin, "rstudioapi::isAvailable", function() TRUE)
  stub(insert_margin, "rstudioapi::insertText", function(x) inserted <<- x)

  insert_margin()

  expect_true(grepl("\\.column-margin", inserted))
  expect_true(grepl("<your comment>", inserted))
  expect_true(grepl(":::", inserted))
})

test_that("insert_margin warns when RStudio API is unavailable", {
  stub(insert_margin, "rstudioapi::isAvailable", function() FALSE)

  expect_warning(insert_margin(), "RStudio API is not available")
})
