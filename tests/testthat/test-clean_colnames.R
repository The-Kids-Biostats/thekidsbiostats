library(testthat)
library(dplyr)

### update_colnames() tests
test_that("columns are renamed and labels are applied", {

  data <- data.frame(
    a = 1:3,
    b = 4:6
  )

  # Test a tibble dictionary
  dict1 <- tribble(
    ~old, ~new, ~label,
    "a", "alpha", "First variable",
    "b", "beta", "Second variable"
  )

  out1 <- update_columns(data=data, dict1)

  expect_named(out1, c("alpha", "beta"))
  expect_equal(attr(out1$alpha, "label"), "First variable")
  expect_equal(attr(out1$beta, "label"), "Second variable")


  # Test a data.frame dictionary
  dict2 <- data.frame(
    old = c("a", "b"),
    new = c("alpha", "beta"),
    label    = c("First variable", "Second variable")
  )

  out2 <- update_columns(data, dict2)

  expect_named(out2, c("alpha", "beta"))
  expect_equal(attr(out2$alpha, "label"), "First variable")
  expect_equal(attr(out2$beta, "label"), "Second variable")

})


test_that("custom dictionary column names work", {

  data <- data.frame(x = 1, y = 2)

  dict <- data.frame(
    oldnames = c("x", "y"),
    newnames = c("X", "Y"),
    labs = c("X label", "Y label")
  )

  out <- update_columns(
    data,
    dict,
    old   = "oldnames",
    new   = "newnames",
    label = "labs"
  )

  expect_named(out, c("X", "Y"))
  expect_equal(attr(out$X, "label"), "X label")
  expect_equal(attr(out$Y, "label"), "Y label")
})


test_that("dictionary rows for missing columns are ignored", {

  data <- data.frame(a = c(1, 2, 3))

  dict <- data.frame(
    old = c("a", "b"),
    new = c("alpha", "beta"),
    label    = c("A label", "B label")
  )

  out <- update_columns(data, dict)

  expect_named(out, "alpha")
  expect_equal(attr(out$alpha, "label"), "A label")
})


test_that("columns already named correctly are not renamed", {

  data <- data.frame(alpha = c(1, 2, 3), b=c(4, 5, 6))

  dict <- data.frame(
    old = c("alpha", "b"),
    new = c("alpha", "beta"),
    label = c("Already correct", "Needs renaming")
  )

  out <- update_columns(data, dict)

  expect_named(out, c("alpha", "beta"))
  expect_equal(attr(out$alpha, "label"), "Already correct")
})


test_that("duplicate $old entries error", {

  data <- data.frame(a = c(1, 2, 3), b=c(4, 5, 6))

  dict <- data.frame(
    old = c("a", "a"),
    new = c("x", "y"),
    label = c("one", "two")
  )

  expect_error(
    update_columns(data, dict),
    "Duplicate `old` entries"
  )
})


test_that("duplicate $new entries error", {

  data <- data.frame(a = c(1, 2, 3), b=c(4, 5, 6))

  dict <- data.frame(
    old = c("a", "b"),
    new = c("x", "x"),
    label    = c("one", "two")
  )

  expect_error(
    update_columns(data, dict),
    "Duplicate `new` entries"
  )
})


test_that("missing dictionary columns error", {

  data <- data.frame(a = 1)

  dict <- data.frame(
    old = "a",
    new = "alpha"
  )

  expect_error(
    update_columns(data, dict),
    "dict does not contain all of the required columns"
  )
})


test_that("data must be data.frame-like or file path", {

  data <- c(a = 1)

  dict <- data.frame(
    old = "a",
    new = "alpha",
    label = "A"
  )

  expect_error(
    update_columns(data, dict = dict),
    "`data` must be a data.frame-like object"
  )
})


test_that("dict must be data.frame-like or file path", {

  data <- data.frame(a = 1)

  expect_error(
    update_columns(data, dict = 123),
    "`dict` must be a data.frame-like object or a file path"
  )
})


test_that("NA labels are skipped", {

  data <- data.frame(a = c(1, 2, 3), b=c(4, 5, 6))

  dict <- data.frame(
    old = c('a', 'b'),
    new = c("alpha", "beta"),
    label = c(NA_character_, "is labelled")
  )

  out <- update_columns(data, dict)

  expect_true(is.null(attr(out$alpha, "label")))
  expect_equal(attr(out$beta, "label"), "is labelled")
})


test_that("reorder argument works as expected", {
  data <- data.frame(a = c(1, 2, 3), b = c(4, 5, 6), c = c(7, 8, 9))

  dict <- data.frame(
    old = c("c", "a"), # `b` missing from dictionary
    new = c("gamma", "alpha"),
    label = c("C", "A")
  )

  # Default: no reorder
  out <- update_columns(data, dict)
  expect_named(out, c("alpha", "b", "gamma"))  # original order preserved

  # Reorder = TRUE
  out2 <- update_columns(data, dict, reorder = TRUE)
  expect_named(out2, c("gamma", "alpha", "b"))

})


test_that("errors on unsupported dictionary file extension", {
  data <- data.frame(A = 1)
  tmp <- tempfile(fileext = ".pdf")
  writeLines("not a dict", tmp)

  expect_error(
    update_columns(data, dict = tmp),
    "File extension not supported"
  )
})


test_that("errors when loaded dict is not data.frame-like", {
  data <- data.frame(A = 1)

  tmp <- tempfile(fileext = ".rds")
  saveRDS(1:5, tmp)  # NOT a data.frame

  expect_error(
    update_columns(data, dict = tmp),
    "Dictionary loaded from file is not data.frame-like"
  )
})


test_that("reads dictionary from csv file", {
  data <- data.frame(a = 1)

  dict <- data.frame(
    old = "a",
    new = "b",
    label = "My label",
    stringsAsFactors = FALSE
  )

  tmp <- tempfile(fileext = ".csv")
  write.csv(dict, tmp, row.names = FALSE)

  out <- update_columns(data, dict = tmp)

  expect_named(out, "b")
  expect_equal(attr(out$b, "label"), "My label")
})


test_that("reads dictionary from rds file", {
  data <- data.frame(a = 1)

  dict <- data.frame(
    old = "a",
    new = "b",
    label = "Label",
    stringsAsFactors = FALSE
  )

  tmp <- tempfile(fileext = ".rds")
  saveRDS(dict, tmp)

  out <- update_columns(data, dict = tmp)

  expect_named(out, "b")
  expect_equal(attr(out$b, "label"), "Label")
})


test_that("reads dictionary from xlsx file", {
  skip_if_not_installed("openxlsx")

  data <- data.frame(a = 1)

  dict <- data.frame(
    old = "a",
    new = "b",
    label = "Label"
  )

  tmp <- tempfile(fileext = ".xlsx")
  openxlsx::write.xlsx(dict, tmp)

  out <- update_columns(data, dict = tmp)

  expect_named(out, "b")
  expect_equal(attr(out$b, "label"), "Label")

})


### make_column_dict() tests
test_that("returns a character string", {

  data <- data.frame(a = 1, b = 2)

  out <- make_column_dict(data, quiet = TRUE)

  expect_type(out, "character")
  expect_length(out, 1)
})


test_that("output contains a tribble dictionary template", {

  data <- data.frame(a = 1, b = 2)

  out <- make_column_dict(data, quiet = TRUE)

  expect_match(out, "tribble\\(")
  expect_match(out, "~old, ~new, ~label")
  expect_match(out, "'a'")
  expect_match(out, "'b'")
})


test_that("auto_clean = FALSE leaves new names empty", {

  data <- data.frame(`My Column` = 1, check.names = FALSE)

  out <- make_column_dict(data, auto_clean = FALSE, quiet = TRUE)

  expect_match(out, "'My Column', '',")
})


test_that("auto_clean = TRUE uses janitor::clean_names", {

  skip_if_not_installed("janitor")

  data <- data.frame(`My Column` = 1, check.names=FALSE)

  out <- make_column_dict(data, auto_clean = TRUE, quiet = TRUE)

  expect_match(out, "'My Column', 'my_column'")
})


test_that("quiet controls console output", {

  data <- data.frame(A = 1)

  expect_output(
    make_column_dict(data, quiet = FALSE),
    "tribble"
  )

  expect_silent(
    make_column_dict(data, quiet = TRUE)
  )
})


test_that("writes CSV file when file is specified", {

  data <- data.frame(A = 1, B = 2)
  tmp <- tempfile(fileext = ".csv")

  make_column_dict(data, file = tmp, quiet = TRUE)

  expect_true(file.exists(tmp))

  written <- read.csv(tmp, stringsAsFactors = FALSE)

  expect_equal(names(written), c("old", "new", "label"))
  expect_equal(written$old, c("A", "B"))
})


test_that("writes RDS file when requested", {

  data <- data.frame(A = 1)
  tmp <- tempfile(fileext = ".rds")

  make_column_dict(data, file = tmp, quiet = TRUE)

  expect_true(file.exists(tmp))

  written <- readRDS(tmp)

  expect_equal(written$old, "A")
})


test_that("writes Excel file when requested", {

  skip_if_not_installed("openxlsx")

  data <- data.frame(A = 1)
  tmp <- tempfile(fileext = ".xlsx")

  make_column_dict(data, file = tmp, quiet = TRUE)

  expect_true(file.exists(tmp))

  written <- openxlsx::read.xlsx(tmp)

  expect_equal(written$old, "A")

})


test_that("unsupported file extension errors", {

  data <- data.frame(a = 1)
  tmp <- tempfile(fileext = ".json")

  expect_error(
    make_column_dict(data, file = tmp, quiet = TRUE),
    "Unsupported file extension"
  )
})


test_that("data must be a data.frame", {

  expect_error(
    make_column_dict(1),
    "`data` must be a data.frame"
  )
})


test_that("return value is invisible", {

  data <- data.frame(A = 1)

  out <- withVisible(make_column_dict(data, quiet = TRUE))

  expect_false(out$visible)
  expect_type(out$value, "character")
})


