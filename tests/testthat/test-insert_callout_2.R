library(testthat)
library(mockery)

test_that("insert_callout_2 inserts callout text when RStudio API is available", {
  # Mock rstudioapi::isAvailable() to return TRUE
  # and rstudioapi::insertText() to capture input
  inserted <- NULL
  stub(insert_callout_2, "rstudioapi::isAvailable", function() TRUE)
  stub(insert_callout_2, "rstudioapi::insertText", function(x) inserted <<- x)

  insert_callout_2()

  expect_true(grepl("::: \\{\\.callout-tip", inserted))
  expect_true(grepl("collapse=", inserted))
  expect_true(grepl("tip \\(teal\\)", inserted))
  expect_true(grepl("note \\(azure blue\\)", inserted))
  expect_true(grepl("caution \\(pumpkin\\)", inserted))
  expect_true(grepl("warning \\(saffron\\)", inserted))
  expect_true(grepl("important \\(red\\)", inserted))
  expect_true(grepl("## <title>", inserted))
})

test_that("insert_callout_2 warns when RStudio API is unavailable", {
  stub(insert_callout_2, "rstudioapi::isAvailable", function() FALSE)

  expect_warning(insert_callout_2(), "RStudio API is not available")
})
