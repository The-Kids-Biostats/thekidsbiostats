library(testthat)
library(mockery)

test_that("stops when directory does not exist or file_name is NULL", {
  tmp <- tempfile("reports")
  expect_error(create_template(file_name = "test", directory = tmp),
               "Directory does not exist")
  dir.create(tmp)
  expect_error(create_template(file_name = NULL, directory = tmp),
               "You must provide a file_name")
})

test_that("stops when ext_name is invalid", {
  tmp <- tempfile("reports")
  dir.create(tmp)
  # Mock list.files to control valid extensions
  mockery::stub(create_template, "list.files", function(...) c("html", "word"))
  expect_error(create_template(file_name = "test", directory = tmp, ext_name = "pdf"),
               "Extension not in package")
})

test_that("skips creation if file already exists", {
  tmp <- tempfile("reports")
  dir.create(tmp)

  qmd_path <- file.path(tmp, "test.qmd")
  file.create(qmd_path)

  # Stub update_qmd_template to avoid processing
  stub(create_template, "update_qmd_template", function(lines, ...) lines)

  expect_warning(
    res <- create_template(file_name = "test", directory = tmp, ext_name = "html"),
    "Report file already exists"
  )
  expect_null(res)
})
