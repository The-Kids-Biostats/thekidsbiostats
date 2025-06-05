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
        shiny::br(),
        shiny::checkboxGroupInput("folders", "Folders to Include:",
          choices = c("data-raw", "data", "admin", "docs", "reports"),
          selected = c("data-raw", "data", "admin", "docs", "reports")
        ),
        shiny::fluidRow(
          shiny::column(
            width = 8,
            shiny::textInput(
              "custom_folders",
              "Custom Folders",
              placeholder = "comma-separated folders"
            )
          ),
          shiny::column(
            width = 2,
            style = "margin-top: 25px;",  # aligns button with text input
            shiny::actionButton("add_custom_folder", "Add", class='btn-primary')
          )
        ),
        shiny::checkboxInput("create_report", "Create report in reports folder?", FALSE),
        shiny::conditionalPanel(
          condition = "input.create_report == true",
          shiny::selectInput("ext_name", "Report Type:",
            choices = list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats")),
            selected = "html")
        ),

        shiny::actionButton("create", "Create Project", class = "btn-primary")
      ),

      shiny::mainPanel(
        shiny::fluidRow(
          shiny::column(
            width = 9,
            shiny::wellPanel(
              shiny::tags$h4("Project Directory Structure"),
              shiny::textOutput("selected_dir"),
              shinyTree::shinyTree("tree", checkbox = FALSE)
            )
          )
        ),
        shiny::verbatimTextOutput("status")
      )
    )
  )

  server <- function(input, output, session) {
    project_path <- shiny::reactiveVal(NULL)

    options(all_folders = c("data-raw", "data", "admin", "docs", "reports"))

    shiny::observeEvent(input$browse, {
      selected <- rstudioapi::selectDirectory("Choose folder")
      if (!is.null(selected)) project_path(selected)
    })

    output$selected_dir <- shiny::renderText({
      req(project_path())
      paste(" ", project_path())
    })

    shiny::observeEvent(input$add_custom_folder, {
      new_folder <- trimws(input$custom_folders)

      if (nzchar(new_folder)) {
        current_choices <- isolate(input$folders)
        all_choices <- isolate(getOption("all_folders", c("data-raw", "data", "admin", "docs", "reports")))

        if (!(new_folder %in% all_choices)) {
          updated_choices <- c(all_choices, new_folder)
          options(all_folders = updated_choices)  # Save new state

          shiny::updateCheckboxGroupInput(
            inputId = "folders",
            choices = updated_choices,
            selected = c(current_choices, new_folder)
          )
        }
      }
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
          open_project = FALSE #isTRUE(input$open_project)
        )

        output$status <- shiny::renderText("✅ Project created successfully.")

        shiny::showModal(shiny::modalDialog(
          title = "✅ Project Successfully Created",
          "Would you like to open the project now?",
          footer = shiny::tagList(
            shiny::actionButton("cancel_open", "Close", class = "btn btn-danger"),
            shiny::actionButton("confirm_open", "Open Project", class = "btn-primary")
          )
        ))

      }, error = function(e) {
        shiny::showModal(shiny::modalDialog("Error", e$message, easyClose = TRUE))
        print("Fail")
      })



    })

    output$tree <- shinyTree::renderTree({
      included_folders <- input$folders

      tree <- list()

      proj_name <- if (nzchar(input$project_name)) input$project_name else "[project-name]"
      stats::setNames(list(structure(tree, stopened = TRUE)), paste0(proj_name, "/"))

      # Add folders conditionally
      for (folder in included_folders) {
        if (folder == "reports") {
          if (input$create_report) {
            report_file <- "report.qmd"
            tree[[paste0(folder, "/")]] <- structure(
              stats::setNames(list(structure("", sticon = "file")), report_file),
              stopened = TRUE
            )
          } else {
            tree[[paste0(folder, "/")]] <- structure("", stopened = TRUE)
          }
        } else {
          tree[[paste0(folder, "/")]] <- structure("", stopened = TRUE)
        }
      }

      # Nest under the main project directory
      stats::setNames(list(structure(tree, stopened = TRUE)), paste0(input$project_name, "/"))
    })


    shiny::observeEvent(input$confirm_open, {
      shiny::removeModal()

      rproj_file <- file.path(project_path(),input$project_name, paste0(input$project_name, ".Rproj"))

      if (file.exists(rproj_file) && rstudioapi::isAvailable()) {
        rstudioapi::openProject(path = rproj_file, newSession = TRUE)
      } else {
        output$status <- renderText("⚠️ Could not open project (file missing or RStudio API unavailable).")
      }

      shiny::stopApp()
    })

    observeEvent(input$cancel_open, {
      shiny::removeModal()
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
      shiny::sidebarPanel(width=8,
        shiny::textInput("file_name", "Report File Name:", value = "report", width = "50%"),
        shiny::selectInput("ext_name", "Report Type:",
          choices = list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats")),
          selected = "html", width = "50%"),
        shiny::actionButton("browse", "Browse Output Folder"),
        shiny::textOutput("selected_dir"),
        shiny::br(),
        shiny::actionButton("create", "Create Template", class = "btn-primary")
      ),
      shiny::mainPanel(width=4,
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
#' a preformatted tabset from an external Quarto file. It also optionally previews the
#' output.
#'
#' @return Inserts code into the active RStudio document and copies a child QMD file.
#' @export
#'
#' @import shiny rstudioapi fs glue
insert_model_tabset <- function() {
  ui <- shiny::fluidPage(
    shiny::titlePanel("Insert Model Output Tabs"),

    shiny::textInput("modobj", "Model object name", value = "mod"),

    checkboxInput("preview", "Preview tabset below", value = FALSE),

    actionButton("insert", "Insert into document"),
    br(), br(),

    conditionalPanel(
      condition = "input.preview == true",
      tabsetPanel(
        tabPanel("Desc stats", tableOutput("desc")),
        tabPanel("Desc plot", plotOutput("desc_plot")),
        tabPanel("Model diag", plotOutput("diag_plot")),
        tabPanel("Model output", tableOutput("mod_output"))
      )
    )
  )

  server <- function(input, output, session) {
    # Safe accessor
    get_mod_component <- function(name) {
      req(input$modobj)
      if (!exists(input$modobj, envir = .GlobalEnv)) return(NULL)
      mod <- get(input$modobj, envir = .GlobalEnv)
      if (!name %in% names(mod)) return(NULL)
      mod[[name]]
    }

    output$desc <- renderTable({
      get_mod_component("mod_desc")
    })

    output$desc_plot <- renderPlot({
      get_mod_component("mod_desc_plot")
    })

    output$diag_plot <- renderPlot({
      get_mod_component("mod_diag")
    })

    output$mod_output <- renderTable({
      get_mod_component("mod_output")
    })

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

  viewer <- shiny::dialogViewer("Insert Model Tabs", width = 700, height = 700)
  shiny::runGadget(shinyApp(ui, server), viewer = viewer)
}
