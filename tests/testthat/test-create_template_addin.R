library(testthat)
library(shiny)
library(shinyjs)

# Render the app's UI to an HTML string via its http handler
render_app_html <- function(app) {
  req <- list(PATH_INFO = "/", REQUEST_METHOD = "GET", HEADERS = c(), rook.errors = NULL)
  res <- app$httpHandler(req)
  if (is.character(res$content)) res$content else rawToChar(res$content)
}

test_that("create_template_addin returns a shiny app object", {
  app <- create_template_addin()
  expect_s3_class(app, "shiny.appobj")
  expect_true(is.function(app$httpHandler))
  expect_true(is.function(app$serverFuncSource))
})

test_that("UI contains expected inputs and buttons", {
  html <- render_app_html(create_template_addin())

  expect_true(grepl("Report File Name", html))
  expect_true(grepl("Format", html))
  expect_true(grepl("Select Destination Folder", html))
  expect_true(grepl("Report Header Options", html))
  expect_true(grepl("Create Report", html))
})

test_that("Advanced section is initially hidden", {
  html <- render_app_html(create_template_addin())
  expect_true(grepl("display: none", html))  # advanced_ui div hidden
})
