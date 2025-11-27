library(testthat)
library(mockery)

test_that("project_name must be provided", {
  expect_error(create_project(""), "project_name")
  expect_error(create_project(), "project_name")
})

test_that("uses rstudioapi to select path when path is NULL", {
  mock_isAvailable <- mock(TRUE)
  mock_selectDir  <- mock(tempdir())

  stub(create_project, "rstudioapi::isAvailable", mock_isAvailable)
  stub(create_project, "rstudioapi::selectDirectory", mock_selectDir)

  proj <- create_project("testproj", path = NULL, create_rproj = FALSE, open_project = FALSE)
  expect_true(dir.exists(proj))
})

test_that("errors if no path selected", {
  mock_isAvailable <- mock(TRUE)
  mock_selectDir  <- mock(NULL)

  stub(create_project, "rstudioapi::isAvailable", mock_isAvailable)
  stub(create_project, "rstudioapi::selectDirectory", mock_selectDir)

  expect_error(create_project("testproj", path = NULL), "No directory selected")
})

test_that("creates project structure with folders and .Rproj", {
  tmp <- tempfile("projtest")
  dir.create(tmp)

  proj <- create_project("myproj",
                         path = tmp,
                         folders = c("data", "scripts"),
                         create_rproj = TRUE,
                         open_project = FALSE)

  expect_true(dir.exists(file.path(proj, "data")))
  expect_true(dir.exists(file.path(proj, "scripts")))
  expect_true(file.exists(file.path(proj, "myproj.Rproj")))
})

test_that("creates report if create_report = TRUE", {
  tmp <- tempfile("projtest")
  dir.create(tmp)

  mock_template <- mock(file.path(tmp, "myproj", "reports", "report.qmd"))
  stub(create_project, "create_template", mock_template)

  proj <- create_project("myproj",
                         path = tmp,
                         create_report = TRUE,
                         open_project = FALSE)

  expect_true(dir.exists(file.path(proj, "reports")))
  expect_called(mock_template, 1)
})

test_that("opens project when open_project = TRUE", {
  tmp <- tempfile("projtest")
  dir.create(tmp)

  mock_isAvailable <- mock(TRUE)
  mock_openProj    <- mock(TRUE)

  stub(create_project, "rstudioapi::isAvailable", mock_isAvailable)
  stub(create_project, "rstudioapi::openProject", mock_openProj)

  proj <- create_project("myproj",
                         path = tmp,
                         open_project = TRUE)

  expect_called(mock_openProj, 1)
})

test_that("errors if RStudio not available and path is NULL", {
  mock_isAvailable <- mock(FALSE)
  stub(create_project, "rstudioapi::isAvailable", mock_isAvailable)

  expect_error(
    create_project("myproj", path = NULL),
    "Please provide a path or run inside RStudio."
  )
})

test_that("creates reports folder and triggers message", {
  tmp <- tempfile("projtest")
  dir.create(tmp)

  # Mock create_template to just return a path
  mock_template <- function(directory, ext_name, open_file = FALSE, ...) {
    file.path(directory, paste0("report.", ext_name))
  }
  stub(create_project, "create_template", mock_template)

  # Remove "reports" from folders so it doesn't exist yet
  msgs <- capture_messages(
    proj <- create_project("myproj",
                           path = tmp,
                           folders = c("data-raw", "data", "admin", "docs"),  # no reports
                           create_report = TRUE,
                           open_project = FALSE,
                           ext_name = "qmd")
  )

  reports_path <- file.path(proj, "reports")
  expect_true(dir.exists(reports_path))
  expect_true(any(grepl("📂 Report folder created: reports/", msgs)))
})
