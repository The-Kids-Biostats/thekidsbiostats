#' Insert Callout via RStudio Addin
#'
#' Launches a Shiny app as an RStudio addin to insert a Quarto callout at the cursor position.
#' The user selects a callout type from a dropdown, sees a preview color, and inserts formatted
#' callout text into the current script.
#'
#' @return A Shiny application that runs within RStudio.
#'
#' @import shiny shinyFiles
#' @export
#'
#' @import shiny
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   insert_callout()
#' }
#' }
insert_callout <- function() {
  color_map <- c(
    "note"      = "#a1b7d4",
    "tip"       = "#80D1CE",
    "important" = "#FAB580",
    "warning"   = "#F8DA9A"
  )

  callout_button <- function(id, label, color) {
    shiny::actionButton(
      inputId = id,
      label = label,
      class = "btn-callout",
      style = paste0("background-color:", color, ";")
    )
  }

  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML(".btn-callout { width: 100%; font-weight: bold; margin-bottom: 10px; font-size: 16px; border: none; }"))
    ),
    shiny::titlePanel("Insert Callout"),
    shiny::fluidRow(
      shiny::column(12,
        callout_button("note",      "Note",      color_map["note"]),
        callout_button("warning",   "Warning",   color_map["warning"]),
        callout_button("important", "Important", color_map["important"]),
        callout_button("tip",       "Tip",       color_map["tip"])
      )
    )
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$note, {
      rstudioapi::insertText("::: {.callout-note}\n<your text>\n:::\n")
      shiny::stopApp()
    })
    shiny::observeEvent(input$warning, {
      rstudioapi::insertText("::: {.callout-warning}\n<your text>\n:::\n")
      shiny::stopApp()
    })
    shiny::observeEvent(input$important, {
      rstudioapi::insertText("::: {.callout-important}\n<your text>\n:::\n")
      shiny::stopApp()
    })
    shiny::observeEvent(input$tip, {
      rstudioapi::insertText("::: {.callout-tip}\n<your text>\n:::\n")
      shiny::stopApp()
    })
  }

  viewer <- shiny::dialogViewer("Insert Callout", width = 250, height = 250)
  shiny::runGadget(ui, server, viewer = viewer)
}

#' Insert Callout via RStudio Addin
#'
#' Inserts a Quarto callout block with placeholder text directly at the cursor.
#'
#' @return None. Inserts text into the active RStudio document.
#' @export
#'
#' @examples
#' \dontrun{
#' insert_callout()
#' }
insert_callout_2 <- function() {
  if (rstudioapi::isAvailable()) {
    rstudioapi::insertText(
      "::: {.callout-tip}\n#options: tip, note, warning, important\n<your text>\n:::\n"
    )
  } else {
    warning("RStudio API is not available.")
  }
}

#' Insert Margin Block at Cursor
#'
#' Inserts a Quarto column-margin block with placeholder text directly at the cursor.
#'
#' @return None. Inserts text into the active RStudio document.
#' @export
#'
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   insert_margin()
#' }
#' }
insert_margin <- function() {
  if (rstudioapi::isAvailable()) {
    rstudioapi::insertText(
      "::: {.column-margin}\n<your comment>\n:::\n"
    )
  } else {
    warning("RStudio API is not available.")
  }
}

#' Shiny Addin: Create New Project
#'
#' Launches a Shiny app to create a project with folders, report, and control over session state.
#'
#' @export
create_project_addin <- function() {

  ui <- shiny::fluidPage(
    shiny::titlePanel("Create a New Project"),

    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::textInput("project_name", "Project Name:", ""),
        shiny::actionButton("browse", "Browse Parent Directory"),
        shiny::textOutput("selected_dir"),

        shiny::checkboxGroupInput("folders", "Folders to Include:",
          choices = c("data-raw", "data", "admin", "docs", "reports"),
          selected = c("data-raw", "data", "admin", "docs", "reports")),

        shiny::checkboxInput("create_report", "Create report in reports folder?", FALSE),
        shiny::conditionalPanel(
          condition = "input.create_report == true",
          shiny::selectInput("ext_name", "Report Type:",
            choices = list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats")),
            selected = "html")
        ),

        shiny::checkboxInput("open_project", "Open new project", TRUE),
        shiny::actionButton("create", "Create Project", class = "btn-primary")
      ),

      shiny::mainPanel(
        shiny::verbatimTextOutput("status")
      )
    )
  )

  server <- function(input, output, session) {
    project_path <- shiny::reactiveVal(NULL)

    shiny::observeEvent(input$browse, {
      selected <- rstudioapi::selectDirectory("Choose folder")
      if (!is.null(selected)) project_path(selected)
    })

    output$selected_dir <- shiny::renderText({
      req(project_path())
      paste("Selected Directory:", project_path())
    })

    shiny::observeEvent(input$create, {
      req(project_path(), input$project_name)

      tryCatch({
        create_project(
          path = project_path(),
          project_name = input$project_name,
          folders = input$folders,
          create_report = isTRUE(input$create_report),
          ext_name = input$ext_name,
          open_project = isTRUE(input$open_project)
        )

        output$status <- shiny::renderText("\u2705 Project created successfully.")
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog("Error", e$message, easyClose = TRUE))
      })
      shiny::stopApp()
    })
  }

  shiny::shinyApp(ui, server)
}


#' Shiny Addin: Create Report Template
#'
#' Launches a Shiny app to generate a report template in a user-selected folder.
#'
#' @export
create_template_addin <- function() {

  ui <- shiny::fluidPage(
    shiny::titlePanel("Create Report Template"),

    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::textInput("file_name", "Report File Name:", value = "report"),
        shiny::selectInput("ext_name", "Report Type:",
          choices = list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats")),
          selected = "html"),
        shiny::actionButton("browse", "Browse Output Folder"),
        shiny::textOutput("selected_dir"),
        shiny::actionButton("create", "Create Template", class = "btn-success")
      ),
      shiny::mainPanel(
        shiny::verbatimTextOutput("status")
      )
    )
  )

  server <- function(input, output, session) {
    output_path <- shiny::reactiveVal(NULL)

    shiny::observeEvent(input$browse, {
      selected <- rstudioapi::selectDirectory("Choose target directory")
      if (!is.null(selected)) output_path(selected)
    })

    output$selected_dir <- shiny::renderText({
      req(output_path())
      paste("Selected Directory:", output_path())
    })

    shiny::observeEvent(input$create, {
      req(input$file_name, output_path())

      tryCatch({
        create_template(
          file_name = input$file_name,
          directory = output_path(),
          ext_name = input$ext_name,
          open_file = TRUE
        )
        output$status <- shiny::renderText("\u2705 Report template created successfully.")
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog("Error", e$message, easyClose = TRUE))
      })
      shiny::stopApp()
    })
  }

  shiny::shinyApp(ui, server)
}


#' RStudio Addin: Insert child Quarto tabset for model output
#'
#' This Shiny gadget inserts a `model_name <- "mod"` line and a child chunk to include
#' a preformatted tabset from an external Quarto file. It also copies the child file
#' to the same directory as the currently open document.
#'
#' @return Inserts code into the active RStudio document and copies a child QMD file.
#' @export
#'
#' @import shiny rstudioapi fs glue
insert_model_tabset <- function() {
  ui <- shiny::fluidPage(
    shiny::titlePanel("Insert Model Output Tabs"),

    shiny::textInput("modobj", "Model object name", value = "mod"),

    shiny::actionButton("insert", "Insert into document")
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$insert, {
      model_name_line <- glue::glue('```{{r}}\nmodel_name <- "{input$modobj}"\n```')
      child_chunk <- '{{< include model-tabs-lm.qmd >}}'

      # Get active document path and directory
      doc_path <- rstudioapi::getActiveDocumentContext()$path
      if (doc_path == "") {
        shiny::showNotification("No active file open in RStudio", type = "error")
        return()
      }

      doc_dir <- fs::path_dir(doc_path)
      target_path <- fs::path(doc_dir, "model-tabs-lm.qmd")

      # Copy template child file
      template_path <- system.file("quarto_templates/model-tabs-lm.qmd", package = "thekidsbiostats")
      if (!fs::file_exists(template_path)) {
        shiny::showNotification("Child template file not found in package.", type = "error")
        return()
      }
      fs::file_copy(template_path, target_path, overwrite = FALSE)

      # Insert model_name assignment and child chunk
      insertion_text <- glue::glue("{model_name_line}\n\n{child_chunk}\n")
      rstudioapi::insertText(insertion_text)

      stopApp()
    })
  }

  viewer <- shiny::dialogViewer("Insert Model Tabs", width = 500, height = 250)
  shiny::runGadget(shinyApp(ui, server), viewer = viewer)
}
