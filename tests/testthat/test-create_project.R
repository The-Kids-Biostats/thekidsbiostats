library(testthat)
library(mockery)

test_that("project_name must be provided", {
  expect_error(create_project(""), "project_name")
  expect_error(create_project(), "project_name")
})

test_that("uses select_folder() to choose a parent folder when path is NULL", {
  mock_select <- mock(tempdir())
  stub(create_project, "interactive", TRUE)
  stub(create_project, "select_folder", mock_select)

  proj <- create_project("testproj", path = NULL, create_rproj = FALSE, open_project = FALSE)
  expect_true(dir.exists(proj))
  expect_called(mock_select, 1)
})

test_that("errors if no path selected", {
  stub(create_project, "interactive", TRUE)
  stub(create_project, "select_folder", mock(NULL))

  expect_error(create_project("testproj", path = NULL), "No directory selected")
})

test_that("errors if not interactive and path is NULL", {
  stub(create_project, "interactive", FALSE)

  expect_error(
    create_project("myproj", path = NULL),
    "Please provide a path when not running interactively."
  )
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

test_that("project_open_path() opens the .Rproj in RStudio and the folder in Positron", {
  rproj <- file.path("some", "dir", "proj.Rproj")

  withr::with_envvar(c(POSITRON = ""), {
    expect_false(is_ide("positron"))
    expect_equal(project_open_path(rproj), rproj)
  })

  withr::with_envvar(c(POSITRON = "1"), {
    expect_true(is_ide("positron"))
    expect_equal(project_open_path(rproj), file.path("some", "dir"))
  })
})

test_that("create_project() opens the project folder when run in Positron", {
  tmp <- tempfile("projtest")
  dir.create(tmp)

  mock_openProj <- mock(TRUE)
  stub(create_project, "rstudioapi::isAvailable", mock(TRUE))
  stub(create_project, "rstudioapi::openProject", mock_openProj)

  withr::with_envvar(c(POSITRON = "1"), {
    proj <- create_project("myproj", path = tmp, open_project = TRUE)
  })

  expect_called(mock_openProj, 1)
  expect_equal(normalizePath(mock_args(mock_openProj)[[1]]$path), normalizePath(proj))
})
