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
#' @examples
#' if (interactive()) {
#'   insert_callout()
#' }
insert_callout <- function() {
  library(shiny)
  library(shinyFiles)

  ui <- fluidPage(
    titlePanel("Insert Callout"),

    # Selection input
    selectInput("select", "Choose a callout option:",
                choices = c("note", "tip", "important", "warning")),

    # Text input area
    textAreaInput("text_input", "Enter callout text:",
                  value = "",
                  placeholder = "Type your callout content here...",
                  width = "100%", height = "100px"),

    # Color display
    uiOutput("color_box"),

    # Action button to insert text
    actionButton("insert", "Insert at cursor")
  )

  server <- function(input, output, session) {
    # Mapping values to colors and text
    color_map <- c("note" = "#a1b7d4",
                   "tip" = "#80D1CE",
                   "important" = "#FAB580",
                   "warning" = "#F8DA9A")

    # Render color box
    output$color_box <- renderUI({
      req(input$select)  # Ensure input is valid before proceeding
      div(style = paste("background-color:", color_map[input$select],
                        "; height: 30px; width: 80px; border: 1px solid black;"))
    })

    # Insert mapped text at the cursor position in RStudio
    observeEvent(input$insert, {
      req(input$select)  # Ensure input is valid before inserting

      # Use default text if input is empty
      callout_text <- ifelse(nchar(input$text_input) > 0, input$text_input, "Your content here.")

      if (rstudioapi::isAvailable()) {
        rstudioapi::insertText(
          glue::glue("
::: {{.callout-{input$select}}}
{callout_text}
:::
")
        )
      }
    })
  }

  # Set window size using dialogViewer
  viewer <- shiny::dialogViewer("Insert Callout", width = 300, height = 250)
  shiny::runGadget(shinyApp(ui, server), viewer = viewer)
}


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
#' @examples
#' if (interactive()) {
#'   insert_callout()
#' }
insert_margin <- function() {
  ui <- fluidPage(
    titlePanel("Insert Margin Comment"),

    # Text input area
    textAreaInput("text_input", "Enter margin text:",
                  value = "",
                  placeholder = "Type your callout content here...",
                  width = "100%", height = "100px"),

    # Action button to insert text
    actionButton("insert", "Insert at cursor")
  )

  server <- function(input, output, session) {
    # Insert mapped text at the cursor position in RStudio
    observeEvent(input$insert, {
      # Use default text if input is empty
      margin_text <- ifelse(nchar(input$text_input) > 0, input$text_input, "Your content here.")

      if (rstudioapi::isAvailable()) {
        rstudioapi::insertText(
          glue::glue("
::: {{.column-margin}}
{margin_text}
:::
")
        )
      }
    })
  }

  # Set window size using dialogViewer
  viewer <- shiny::dialogViewer("Insert Callout", width = 300, height = 250)
  shiny::runGadget(shinyApp(ui, server), viewer = viewer)
}


#' Shiny Addin for Creating a Project
#'
#' This function launches a Shiny app to create a project structure interactively.
#'
#' @import shiny shinyFiles
#' @export
create_project_addin <- function() {
  library(shiny)
  library(shinyFiles)

  ui <- fluidPage(
    titlePanel("Create a New Project"),
    sidebarLayout(
      sidebarPanel(
        textInput("project_name", "Project Name:", ""),
        shinyDirButton("dir", "Choose Directory", "Please select a directory"),
        textOutput("selected_dir"),   # Displays chosen directory
        selectInput("ext_name", "Project Type:", choices = list.files(system.file("ext_proj/_extensions", package = "thekidsbiostats"))),
        checkboxInput("data_raw", "Include data_raw folder", TRUE),
        checkboxInput("data", "Include data folder", TRUE),
        checkboxInput("admin", "Include admin folder", TRUE),
        checkboxInput("reports", "Include reports folder", TRUE),
        checkboxInput("docs", "Include docs folder", TRUE),
        actionButton("create", "Create Project")
      ),
      mainPanel(
        verbatimTextOutput("status")
      )
    )
  )

  server <- function(input, output, session) {
    project_path <- reactiveVal(NULL)

    volumes = getVolumes()

    # Set up the file chooser
    shinyFiles::shinyDirChoose(input, "dir", roots = volumes,
                               filetypes = c('', 'txt', 'bigWig', "tsv", "csv", "bw"),
                               session = session)

    observe({
      req(input$dir)
      project_path(shinyFiles::parseDirPath(c(home = "~"), input$dir))
    })

    output$selected_dir <- renderText({
      req(project_path())
      paste("Selected Directory:", project_path())
    })

    observeEvent(input$create, {
      if (is.null(project_path()) || input$project_name == "") {
        showModal(modalDialog("Please select a directory and enter a project name.", easyClose = TRUE))
        return()
      }

      tryCatch({
        create_project_shiny(
          path = project_path(),
          project_name = input$project_name,
          ext_name = input$ext_name,
          data_raw = input$data_raw,
          data = input$data,
          admin = input$admin,
          reports = input$reports,
          docs = input$docs
        )
        output$status <- renderText(paste("Project created successfully at:", file.path(project_path(), input$project_name)))
      }, error = function(e) {
        showModal(modalDialog(title = "Error", e$message, easyClose = TRUE))
      })
    })
  }

  runApp(list(ui = ui, server = server), launch.browser = TRUE)
}

