library(testthat)
library(dplyr)

### update_colnames() tests
test_that("update_columns() columns are renamed and labels are applied", {

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


test_that("update_columns() custom dictionary column names work", {

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


test_that("update_columns() dictionary rows for missing columns are ignored", {

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


test_that("update_columns() columns already named correctly are not renamed", {

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


test_that("update_columns() duplicate $old entries warning", {

  data <- data.frame(a = c(1, 2, 3), b=c(4, 5, 6))

  dict <- data.frame(
    old = c("a", "a"),
    new = c("x", "y"),
    label = c("one", "two")
  )

  expect_warning(
    update_columns(data, dict),
    "Duplicate `old` names"
  )
})


test_that("update_columns() ignores blank/NA duplicate $old entries", {

  data <- data.frame(a = c(1, 2, 3), b=c(4, 5, 6))

  dict <- data.frame(
    old = c("a", "b", "", NA, ""),
    new = c("v", "w", "x", "y", "z"),
    label = c("one", "two", "three", "four", "five")
  )

  expect_silent(
    update_columns(data, dict)
  )
})


test_that("update_columns() duplicate $new entries error", {

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


test_that("update_columns() missing dictionary columns error", {

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


test_that("update_columns() data must be data.frame-like or file path", {

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


test_that("update_columns() dict must be data.frame-like or file path", {

  data <- data.frame(a = 1)

  expect_error(
    update_columns(data, dict = 123),
    "`dict` must be a data.frame-like object or a file path"
  )
})


test_that("update_columns() NA labels are skipped", {

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


test_that("update_columns() reorder argument works as expected", {
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


test_that("update_columns() errors on unsupported dictionary file extension", {
  data <- data.frame(A = 1)
  tmp <- tempfile(fileext = ".pdf")
  writeLines("not a dict", tmp)

  expect_error(
    update_columns(data, dict = tmp),
    "File extension not supported"
  )
})


test_that("update_columns() errors when loaded dict is not data.frame-like", {
  data <- data.frame(A = 1)

  tmp <- tempfile(fileext = ".rds")
  saveRDS(1:5, tmp)  # NOT a data.frame

  expect_error(
    update_columns(data, dict = tmp),
    "Dictionary loaded from file is not data.frame-like"
  )
})


test_that("update_columns() reads dictionary from csv file", {
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


test_that("update_columns() reads dictionary from rds file", {
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


test_that("update_columns() reads dictionary from xlsx file", {
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

test_that("make_column_dict() returns a correctly structured data.frame", {
  data <- data.frame(
    "A" = 1:3,
    "B" = c(70, 60, 80)
  )

  # Call function
  dict <- make_column_dict(data, quiet = TRUE)

  # Check class
  expect_s3_class(dict, "data.frame")

  # Check columns exist
  expect_true(all(c("old", "new", "label") %in% colnames(dict)))

  # Check types
  expect_type(dict$old, "character")
  expect_type(dict$new, "character")
  expect_type(dict$label, "character")

  # Check number of rows
  expect_equal(nrow(dict), ncol(data))

  # Check that old names match original data
  expect_equal(dict$old, names(data))

  # Check that new names are cleaned if auto_clean = TRUE
  expect_equal(dict$new, names(janitor::clean_names(data)))

  # Labels should be empty strings
  expect_true(all(dict$label == ""))
})


test_that("auto_clean = FALSE leaves new names empty", {

  data <- data.frame(`My Column` = 1, check.names = FALSE)

  out <- make_column_dict(data, auto_clean = FALSE, quiet = TRUE)

  expect_equal(out$new, "")
})


test_that("auto_clean = TRUE uses janitor::clean_names", {

  skip_if_not_installed("janitor")

  data <- data.frame(`My Column` = 1, check.names=FALSE)

  out <- make_column_dict(data, auto_clean = TRUE, quiet = TRUE)

  expect_equal(out$new, "my_column")
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


test_that("object name is taken from a variable name", {

  df_patients <- data.frame(A = 1)

  expect_output(
    make_column_dict(df_patients, quiet = FALSE),
    "dict_patients <- tribble"
  )
})


test_that("piped or inline data does not attempt to extract a prefix", {

  expect_output(
    data.frame(A = 1) |> make_column_dict(quiet = FALSE),
    "dict <- tribble"
  )

  expect_output(
    make_column_dict(data.frame(A = 1, B = 2)[1, ], quiet = FALSE),
    "dict <- tribble"
  )
})


test_that("labels = 'keep' copies original names into the label column", {

  data <- data.frame(`My Column` = 1, B = 2, check.names = FALSE)

  out <- make_column_dict(data, labels = "keep", quiet = TRUE)

  expect_equal(out$label, c("My Column", "B"))
})


test_that("labels is given as a vector of correct length", {
  
  data <- data.frame(A = 1, B = 2)

  expect_error(
    make_column_dict(data, labels=999),
    "`labels` must be a vector of length equal"
  )

  labels = c("alpha", "beta", "gamma")

  expect_error(
    make_column_dict(data, labels=labels),
    "`labels` must be a vector of length equal"
  )
})


test_that("new_names is given as a vector of correct length", {
  
  data <- data.frame(A = 1, B = 2)

  expect_error(
    make_column_dict(data, new_names=999),
    "`new_names` must be a vector of length equal"
  )

  new_names = c("alpha", "beta", "gamma")

  expect_error(
    make_column_dict(data, new_names=new_names),
    "`new_names` must be a vector of length equal"
  )
})


test_that("make_column_dict() does not overwrite an existing file by default", {

  data <- data.frame(A = 1, B = 2)
  tmp <- tempfile(fileext = ".R")
  on.exit(unlink(tmp), add = TRUE)

  make_column_dict(data, file = tmp, quiet = TRUE)
  writeLines("# manual edit", tmp)

  expect_error(
    make_column_dict(data, file = tmp, quiet = TRUE),
    "already exists"
  )
  expect_equal(readLines(tmp, warn = FALSE), "# manual edit")

  make_column_dict(data, file = tmp, quiet = TRUE, overwrite = TRUE)
  expect_false(identical(readLines(tmp, warn = FALSE), "# manual edit"))
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


test_that("writes .R file when requested", {

  data <- data.frame(A = 1)
  tmp <- tempfile(fileext = ".R")

  make_column_dict(data, file = tmp, quiet = TRUE)

  expect_true(file.exists(tmp))

  expect_error(
    source(tmp),
    NA
  )
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
  expect_s3_class(out$value, "data.frame")
})



test_that("relabel_columns() applies labels to matching columns without renaming", {

  data <- data.frame(alpha = 1:3, beta = 4:6)

  dict <- data.frame(
    new = c("alpha", "beta"),
    label = c("First variable", "Second variable")
  )

  out <- relabel_columns(data, dict)

  expect_named(out, c("alpha", "beta"))
  expect_equal(attr(out$alpha, "label"), "First variable")
  expect_equal(attr(out$beta, "label"), "Second variable")

})

test_that("relabel_columns() uses the names and label arguments", {

  data <- data.frame(alpha = 1:3)

  dict <- data.frame(
    current = "alpha",
    description = "First variable"
  )

  out <- relabel_columns(data, dict, names = "current", label = "description")

  expect_equal(attr(out$alpha, "label"), "First variable")

})

test_that("relabel_columns() works after update_columns()", {

  data <- data.frame(a = 1:3, b = 4:6)

  dict <- data.frame(
    old = c("a", "b"),
    new = c("alpha", "beta"),
    label = c("First variable", "Second variable")
  )

  out <- data |> 
    update_columns(dict) |>
    mutate(alpha = as.integer(alpha)) |>
    relabel_columns(dict)

  expect_named(out, c("alpha", "beta"))
  expect_equal(attr(out$alpha, "label"), "First variable")
  expect_equal(attr(out$beta, "label"), "Second variable")

})

test_that("relabel_columns() leaves unlisted columns unchanged", {

  data <- data.frame(alpha = 1:3, gamma = 7:9)

  dict <- data.frame(
    new = "alpha",
    label = "First variable"
  )

  out <- relabel_columns(data, dict)

  expect_null(attr(out$gamma, "label"))

})

test_that("relabel_columns() skips NA labels and applies empty labels", {

  data <- data.frame(alpha = 1:3, beta = 4:6)

  dict <- data.frame(
    new = c("alpha", "beta"),
    label = c(NA, "")
  )

  out <- relabel_columns(data, dict)

  expect_null(attr(out$alpha, "label"))
  expect_equal(attr(out$beta, "label"), "")

})

test_that("relabel_columns() warns on dictionary entries not found in data", {

  data <- data.frame(alpha = 1:3)

  dict <- data.frame(
    new = c("alpha", "missing_col"),
    label = c("First variable", "Missing")
  )

  expect_warning(relabel_columns(data, dict), "missing_col")

})

test_that("relabel_columns() errors on duplicate dictionary entries", {

  data <- data.frame(alpha = 1:3)

  dict <- data.frame(
    new = c("alpha", "alpha"),
    label = c("First", "Second")
  )

  expect_error(relabel_columns(data, dict), "Duplicate")

})

test_that("relabel_columns() errors when dictionary columns are missing", {

  data <- data.frame(alpha = 1:3)

  dict <- data.frame(old = "alpha", label = "First variable")

  expect_error(relabel_columns(data, dict), "required columns")

})

test_that("relabel_columns() errors on non-data.frame inputs", {

  dict <- data.frame(new = "alpha", label = "First variable")

  expect_error(relabel_columns(list(alpha = 1:3), dict), "`data` must be")
  expect_error(relabel_columns(data.frame(alpha = 1:3), c("alpha")), "`dict` must be")

})

test_that("relabel_columns() ignores NA entries in the names column", {

  data <- data.frame(alpha = 1:3)

  dict <- data.frame(
    new = c("alpha", NA),
    label = c("First variable", "Ignored")
  )

  expect_no_warning(out <- relabel_columns(data, dict))
  expect_equal(attr(out$alpha, "label"), "First variable")

})

test_that("relabel_columns() overwrites existing labels", {

  data <- data.frame(alpha = 1:3)
  attr(data$alpha, "label") <- "Old label"

  dict <- data.frame(new = "alpha", label = "New label")

  out <- relabel_columns(data, dict)

  expect_equal(attr(out$alpha, "label"), "New label")

})

test_that("relabel_columns() does not change column values or names", {

  data <- data.frame(alpha = 1:3, beta = c("x", "y", "z"))

  dict <- data.frame(new = c("alpha", "beta"), label = c("A", "B"))

  out <- relabel_columns(data, dict)

  expect_named(out, names(data))
  expect_identical(as.vector(out$alpha), data$alpha)
  expect_identical(as.vector(out$beta), data$beta)

})
