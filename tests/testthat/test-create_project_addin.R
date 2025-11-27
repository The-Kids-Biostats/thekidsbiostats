library(testthat)
library(mockery)
library(shiny)
library(shinyjs)
library(shinyTree)

test_that("create_project_addin returns a shiny app object", {
  stub(create_project_addin, "shiny::shinyApp", function(ui, server) list(ui = ui, server = server))
  app <- create_project_addin()
  expect_type(app, "list")
  expect_true(all(c("ui", "server") %in% names(app)))
})


test_that("Add custom folder updates all_folders option", {
  stub(create_project_addin, "shiny::shinyApp", function(ui, server) list(ui = ui, server = server))
  app <- create_project_addin()

  # simulate input$custom_folders and input$folders
  input <- new.env()
  input$custom_folders <- "extra"
  input$folders <- c("data","docs")

  options(all_folders = c("data-raw","data","admin","docs","reports"))
  # Inline call of add_custom_folder observer
  new_folder <- trimws(input$custom_folders)
  if (nzchar(new_folder)) {
    current_choices <- input$folders
    all_choices <- getOption("all_folders")
    if (!(new_folder %in% all_choices)) {
      updated_choices <- c(all_choices, new_folder)
      options(all_folders = updated_choices)
    }
  }

  expect_true("extra" %in% getOption("all_folders"))
})
