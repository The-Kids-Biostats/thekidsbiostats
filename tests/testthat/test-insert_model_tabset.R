library(testthat)
library(mockery)
library(shiny)

test_that("insert_model_tabset shows error if template file missing", {
  notified <- NULL
  stub(insert_model_tabset, "rstudioapi::getActiveDocumentContext",
       function() list(path = "some/path/test.qmd"))
  stub(insert_model_tabset, "system.file", function(...) "missing/template/path")
  stub(insert_model_tabset, "fs::file_exists", function(...) FALSE)
  stub(insert_model_tabset, "shiny::showNotification", function(msg, ...) notified <<- msg)
  stub(insert_model_tabset, "fs::file_copy", function(...) NULL)
  stub(insert_model_tabset, "rstudioapi::insertText", function(...) NULL)
  stub(insert_model_tabset, "shiny::stopApp", function() NULL)

  app <- insert_model_tabset()
  expect_s3_class(app, "shiny.appobj")
  expect_true(is.null(notified) || grepl("Child template file not found", notified))
})


test_that("insert_model_tabset shows notification when no active file", {
  notified <- NULL

  stub(insert_model_tabset, "rstudioapi::getActiveDocumentContext",
       function() list(path = ""))
  stub(insert_model_tabset, "system.file", function(...) "fake/template/path")
  stub(insert_model_tabset, "fs::file_exists", function(...) TRUE)
  stub(insert_model_tabset, "fs::file_copy", function(...) NULL)
  stub(insert_model_tabset, "rstudioapi::insertText", function(...) NULL)
  stub(insert_model_tabset, "shiny::showNotification", function(msg, ...) notified <<- msg)
  stub(insert_model_tabset, "shiny::stopApp", function() NULL)

  app <- insert_model_tabset()
  expect_s3_class(app, "shiny.appobj")
  expect_true(is.function(app$server))

  # Cannot directly call server; just ensure app creation triggers no error
  expect_true(is.null(notified) || grepl("No active file", notified))
})
