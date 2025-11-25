library(testthat)
library(mockery)
library(shiny)
library(shinyjs)

test_that("create_template_addin returns a shiny gadget object", {
  stub(create_template_addin, "shiny::runGadget", function(ui, server, viewer) list(ui = ui, server = server, viewer = viewer))

  app <- create_template_addin()
  expect_type(app, "list")
  expect_true(all(c("ui", "server", "viewer") %in% names(app)))
})

test_that("UI contains expected inputs and buttons", {
  stub(create_template_addin, "shiny::runGadget", function(ui, server, viewer) list(ui = ui, server = server, viewer = viewer))
  app <- create_template_addin()

  tags <- htmltools::renderTags(app$ui)$html
  expect_true(grepl("Report File Name", tags))
  expect_true(grepl("Format", tags))
  expect_true(grepl("Select Folder", tags))
  expect_true(grepl("Modify Report Header", tags))
  expect_true(grepl("Create Report", tags))
})

test_that("Advanced section is initially hidden", {
  stub(create_template_addin, "shiny::runGadget", function(ui, server, viewer) list(ui = ui, server = server, viewer = viewer))
  app <- create_template_addin()

  tags <- htmltools::renderTags(app$ui)$html
  expect_true(grepl("display: none", tags))  # advanced_ui div hidden
})

test_that("External functions can be stubbed without opening the gadget", {
  selected_dir <- NULL

  # Stub the functions used inside the server
  stub(create_template_addin, "rstudioapi::selectDirectory", function(...) selected_dir <<- "mock/dir")
  stub(create_template_addin, "create_template", function(...) TRUE)
  stub(create_template_addin, "shiny::showModal", function(...) NULL)
  stub(create_template_addin, "shiny::stopApp", function(...) NULL)

  # Stub runGadget to just return ui/server/viewer
  stub(create_template_addin, "shiny::runGadget", function(ui, server, viewer) {
    list(ui = ui, server = server, viewer = viewer)
  })

  app <- create_template_addin()

  expect_type(app, "list")
  expect_true(all(c("ui", "server", "viewer") %in% names(app)))
})
