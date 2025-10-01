#' Insert Callout via RStudio Addin
#'
#' Launches a Shiny app as an RStudio addin to insert a Quarto callout at the cursor position.
#' The user selects a callout type from a dropdown, sees a preview colour, and inserts formatted
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

  default_title <- "The Kids Biostats Template"
  default_subtitle <- "A biostatistics report template"
  default_affiliation <- "The Kids Research Institute Australia, Perth, WA, Australia"
  default_name <- Sys.info()[["user"]]
  default_reproducibility <- TRUE

  # Check pattern: first two uppercase, third lowercase
  if (grepl("^[A-Z]{2}[a-z]", default_name)) {
    # Insert space between first and second characters
    default_name <- paste0(substr(default_name, 1, 1), " ", substr(default_name, 2, nchar(default_name)))
  }

  ui <- shiny::fluidPage(
    shinyjs::useShinyjs(),

    shiny::titlePanel("Create a New Project"),

    shiny::tabsetPanel(
      id="main_tabs",
      selected = "Project",
      shiny::tabPanel("Project")
    ),


    shiny::sidebarLayout(
      shiny::sidebarPanel(width = 3,
        shiny::div(id = 'project_side',
          shiny::h3("Project Customisation"),
          shiny::p("Modify the details of your project and select the folder structure and files that best suits your project."),
          shiny::textInput("project_name", "Project Name:", value="", width='90%'),
          shiny::actionButton("browse", "Select Destination Folder", class = 'btn-secondary'),
          shiny::checkboxInput("create_report", "Create report template?", value = FALSE),
          shiny::textOutput("selected_dir"),
          shiny::br(),
          shiny::checkboxGroupInput("folders", "Folders to Include:",
                                    choices = c("data-raw", "data", "admin", "docs", "reports"),
                                    selected = c("data-raw", "data", "admin", "docs", "reports")
          ),
          shiny::tags$head(
            shiny::tags$style(shiny::HTML("
              .disabled-label {
                color: #A99 !important;
                pointer-events: none;
              }
            "))
          ),

          shiny::tags$script(shiny::HTML("// Disable the 'reports' checkbox if 'create_report' selected
            Shiny.addCustomMessageHandler('lock_reports', function(message) {
              const checkboxes = document.getElementsByName('folders[]');
              for (const box of checkboxes) {
                if (box.value === 'reports') {
                  box.disabled = message.lock;

                  // Find and style the label
                  const label = box.closest('label');
                  if (label) {
                    if (message.lock) {
                      label.classList.add('disabled-label');
                    } else {
                      label.classList.remove('disabled-label');
                    }
                  }
                }
              }
            });"
          )),

          shiny::tags$style(shiny::HTML("
            .well {
              overflow-x: auto; /* or try hidden if you want to clip instead */
            }"
          )),
          shiny::fluidRow(
            shiny::column(
              width = 8,
              shiny::textInput(
                "custom_folders",
                label = shiny::tags$label("Additional Custom Folders", style = "white-space: nowrap;"),
                placeholder = "comma-separated folders"
              )
            ),
            shiny::column(
              width = 2,
              style = "margin-top: 30px;",
              shiny::actionButton("add_custom_folder", "Add", class = 'btn-secondary')
            )
          )

        ),
        shiny::div(id = 'report_side',
          shiny::h3("Report Customisation"),
          shiny::p("Initialise a template report and modify the details contained within the document."),
          shiny::fluidRow(
            shiny::column(8, style = "padding-right:5px;",
                          shiny::textInput("report_filename", "Report File Name:", value = "report")),
            shiny::column(4, style = "padding-left:5px; padding-right:5px;",
                          shiny::selectInput("ext_name", "Format:",
                                             choices = list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats")),
                                             selected = "html", width='80%'))
          ),
          #shiny::actionButton("browse_report_dir", "Folder to store report"),
          shiny::textOutput("selected_report_dir"),
          shiny::br(),
          shiny::actionLink("toggle_advanced", "\u25B6 Modify Report Header"),

          # Advanced options (initially hidden)
          shiny::div(
            id = "advanced_ui",
            style = "display: none;",
            shiny::tags$hr(),
            shiny::textInput("title", "Title", value = default_title),
            shiny::textInput("subtitle", "Subtitle", value = default_subtitle),
            shiny::textInput("author", "Author Name", value = default_name),
            shiny::textInput("affiliation", "Affiliation", value = default_affiliation),
            shiny::checkboxInput("reproducibility", "Include Reproducibility", value = default_reproducibility)
          )
        ),
        shiny::br(), shiny::br(),
        shiny::tags$div(
          id = 'create_wrap',
          title = "Please select a folder.",
          style = "display: inline-block;",
          shiny::actionButton("create", "Create Project", class = "btn-primary", disabled = "disabled")
        )
      ),
      shiny::mainPanel(width = 9,
        shiny::div(id = "project_main",
          shiny::div(style = "max-width: 65%",
            shiny::wellPanel(style='background-color: #f6f6f6; border: none; box-shadow: none;',
              shiny::tags$h4("Project Directory Structure"),
              shiny::textOutput("selected_dir"),
              shinyTree::shinyTree("tree", checkbox = FALSE)
            )
          ),
          shiny::verbatimTextOutput("status")
        ),
        shiny::div(id = "report_main",
          shiny::wellPanel(style='background-color: #f6f6f6;',
            shiny::tags$h4("Template Report Preview"),
            shiny::uiOutput("preview_html")
          )
        )
      )
    )
  )

  server <- function(input, output, session) {
    ### Project Reactives
    project_path <- shiny::reactiveVal(NULL)
    current_tab <- shiny::reactiveVal("Project")

    ### Template Reactives
    show_advanced <- shiny::reactiveVal(FALSE)
    preview_inputs <- shiny::reactiveVal(NULL)
    last_preview <- shiny::reactiveVal(NULL)
    suppress_preview <- shiny::reactiveVal(FALSE)

    debounced_title <- shiny::debounce(shiny::reactive(input$title), 1200)
    debounced_subtitle <- shiny::debounce(shiny::reactive(input$subtitle), 1200)
    debounced_author <- shiny::debounce(shiny::reactive(input$author), 750)
    debounced_affiliation <- shiny::debounce(shiny::reactive(input$affiliation), 1000)
    debounced_reproducibility <- shiny::debounce(shiny::reactive(input$reproducibility), 0)

    debounced_inputs <- shiny::reactive({
      list(
        title = debounced_title() %||% default_title,
        subtitle = debounced_subtitle() %||% default_subtitle,
        author = debounced_author() %||% default_name,
        affiliation = debounced_affiliation() %||% default_affiliation,
        include_reproducibility = debounced_reproducibility() %||% default_reproducibility
      )
    })

    options(all_folders = c("data-raw", "data", "admin", "docs", "reports"))

    # Initialise visibility
    shiny::observe({
      shinyjs::hide("report_side")
      shinyjs::hide("report_main")
    })

    # Condition the Report tab on checkbox
    shiny::observeEvent(input$create_report, {
      if (isTRUE(input$create_report)) {
        shiny::insertTab(
          inputId = "main_tabs",
          tabPanel("Report"),
          target = "Project",
          position = "after",
          select = FALSE
        )
      } else {
        # Redirect to "Project" tab before removing to avoid errors
        if (input$main_tabs == "Report") {
          shiny::updateTabsetPanel(session, "main_tabs", selected = "Project")
        }
        shiny::removeTab("main_tabs", target = "Report")
      }
    })

    # Toggle visibility based on selected tab
    shiny::observeEvent(input$main_tabs, {
      if (input$main_tabs == "Project") {
        shinyjs::show("project_side")
        shinyjs::show("project_main")
        shinyjs::hide("report_side")
        shinyjs::hide("report_main")
      } else if (input$main_tabs == "Report") {
        shinyjs::show("report_side")
        shinyjs::show("report_main")
        shinyjs::hide("project_side")
        shinyjs::hide("project_main")
      }
    })


    shiny::observeEvent(input$main_tabs, {
      current_tab(input$main_tabs)
    })


    #### Project Tab

    shiny::observeEvent(input$create_report, {
      if (isTRUE(input$create_report)) {
        # Ensure 'reports' is included in selection
        new_selection <- union(input$folders, "reports")
        shiny::updateCheckboxGroupInput(session, "folders", selected = new_selection)

        # Lock and de-highlight
        session$sendCustomMessage("lock_reports", list(lock = TRUE))
      } else {
        # Unlock and re-highlight
        session$sendCustomMessage("lock_reports", list(lock = FALSE))
      }
    })

    # Prevent manual unchecking of "reports"
    shiny::observe({
      if (isTRUE(input$create_report)) {
        if (is.null(input$folders) || !"reports" %in% input$folders) {
          shiny::updateCheckboxGroupInput(session, "folders",
                                   selected = union(input$folders, "reports"))
        }
      }
    })

    # Disable the Create Template button initially
    shinyjs::disable("create")

    shiny::observeEvent(input$browse, {
      selected <- rstudioapi::selectDirectory("Choose folder")
      if (!is.null(selected)) project_path(selected)

      if (is.null(project_path())) {
        shinyjs::disable("create")
        shinyjs::runjs('document.getElementById("create_wrap").setAttribute("title", "Please select a folder");')
      } else {  # Enable the button
        shinyjs::enable("create")
        shinyjs::runjs('document.getElementById("create_wrap").setAttribute("title", "Create project");')
      }
    })

    output$selected_dir <- shiny::renderText({
      shiny::req(project_path())
      paste(" ", project_path())
    })

    shiny::observeEvent(input$add_custom_folder, {
      new_folder <- trimws(input$custom_folders)

      if (nzchar(new_folder)) {
        current_choices <- shiny::isolate(input$folders)
        all_choices <- shiny::isolate(getOption("all_folders", c("data-raw", "data", "admin", "docs", "reports")))

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



    #### Template Tab
    shiny::observe({
      preview_inputs(list(
        title = default_title,
        subtitle = default_subtitle,
        author = default_name,
        affiliation = default_affiliation,
        include_reproducibility = default_reproducibility
      ))
    })


    shiny::observeEvent(input$toggle_advanced, {
      suppress_preview(TRUE)  # Suppress auto preview update

      show_advanced(!show_advanced())

      # Toggle visibility
      if (show_advanced()) {
        shiny::updateActionLink(session, "toggle_advanced", label = "\u25BC Modify Report Header")
        shinyjs::show("advanced_ui")
      } else {
        shiny::updateActionLink(session, "toggle_advanced", label = "\u25B6 Modify Report Header")
        shinyjs::hide("advanced_ui")
      }

      # Reset suppression AFTER a short delay (after UI settles)
      later::later(function() suppress_preview(FALSE), delay = 0.1)
    })


    generate_preview <- function(title, subtitle, author, affiliation, include_reproducibility) {
      template_path <- system.file("example_reports", "example.html", package = "thekidsbiostats")

      html_lines <- update_html_template(
        readLines(template_path, warn = FALSE),
        title = title,
        subtitle = subtitle,
        author = author,
        affiliation = affiliation,
        include_reproducibility = include_reproducibility
      )
      render_preview(html_lines)
    }

    shiny::observe({
      if (isTRUE(suppress_preview())) return()  # Don't update if suppressed

      new_inputs <- debounced_inputs()
      old_inputs <- last_preview()

      if (is.null(old_inputs) || !identical(new_inputs, old_inputs)) {
        preview_inputs(new_inputs)
        last_preview(new_inputs)
      }
    })

    output$preview_html <- shiny::renderUI({
      shiny::req(preview_inputs())
      path <- generate_preview(
        title = debounced_inputs()$title,
        subtitle = debounced_inputs()$subtitle,
        author = debounced_inputs()$author,
        affiliation = debounced_inputs()$affiliation,
        include_reproducibility = debounced_inputs()$include_reproducibility
      )

      shiny::addResourcePath("preview", dirname(path))

      shiny::tags$div(
        style = "height: calc(100vh - 210px); overflow-y: hidden; border: 1px solid #ddd; padding: 0;",
        shiny::tags$iframe(
          src = paste0("preview/", basename(path)),
          style = "width: 100%; height: 100%; border: none; pointer-events: none;"
        )
      )

    })

    # Map the resource path for your example_reports folder inside the package
    # shiny::addResourcePath(
    #   prefix = "example_reports",
    #   directoryPath = system.file("example_reports", package = "thekidsbiostats")
    # )

    output$selected_report_dir <- shiny::renderText({
      shiny::req(project_path())
      paste0("  ", project_path(), '/reports')
    })


    #### Create Project

    shiny::observeEvent(input$create, {
      shiny::req(project_path(), input$project_name, input$report_filename)

      report_filename <- ifelse(endsWith(input$report_filename, ".qmd"), sub("\\.qmd$", "", input$report_filename), input$report_filename)
      qmd_path <- file.path(project_path(), 'reports', paste0(report_filename, '.qmd'))
      print(qmd_path)
      print(report_filename)

      tryCatch({
        create_project(
          path = project_path(),
          project_name = input$project_name,
          folders = input$folders,
          ext_name = input$ext_name,
          create_report = isTRUE(input$create_report),
          # ... --> create_template()
          file_name = report_filename,
          title = input$title,
          subtitle = input$subtitle,
          author = input$author,
          affiliation = input$affiliation,
          include_reproducibility = input$reproducibility,

          open_project = FALSE
          #open_file = FALSE  # Already handled by create_project()
        )

        output$status <- shiny::renderText("\U00002705 Project created successfully.")

        shiny::showModal(shiny::modalDialog(
          title = "\U00002705 Project Successfully Created",
          "Would you like to open the project now?",
          footer = shiny::tagList(
            shiny::actionButton("cancel_open", "Close", class = "btn btn-danger"),
            shiny::actionButton("confirm_open", "Open Project", class = "btn-primary")
          )
        ))

      }, error = function(e) {
        shiny::showModal(shiny::modalDialog("Error", e$message, easyClose = TRUE))
        output$status <- shiny::renderText("\U0001F6D1 Project creation failed!")
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
            report_filename <- ifelse(!endsWith(input$report_filename, ".qmd"), paste0(input$report_filename, '.qmd'), input$report_filename)
            tree[[paste0(folder, "/")]] <- structure(
              stats::setNames(list(structure("", sticon = "file")), report_filename),
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
        output$status <- shiny::renderText("\u26A0\uFE0F Could not open project (file missing or RStudio API unavailable).")
      }

      shiny::stopApp()
    })

    shiny::observeEvent(input$cancel_open, {
      shiny::removeModal()
      shiny::stopApp()
    })

  }

  shiny::shinyApp(ui=ui, server=server)#, viewer=shiny::dialogViewer('thekidsbiostats: Create Project Addin', width=1600, height=900))
}


#' Shiny Addin: Create Report Template
#'
#' Launches a Shiny app to generate a report template in a user-selected folder.
#'
#' @export
create_template_addin <- function() {

  default_title <- "The Kids Biostats Template"
  default_subtitle <- "A biostatistics report template"
  default_affiliation <- "The Kids Research Institute Australia, Perth, WA, Australia"
  default_name <- Sys.info()[["user"]]
  default_reproducibility <- TRUE

  # Check pattern: first two uppercase, third lowercase
  if (grepl("^[A-Z]{2}[a-z]", default_name)) {
    # Insert space between first and second characters
    default_name <- paste0(substr(default_name, 1, 1), " ", substr(default_name, 2, nchar(default_name)))
  }


  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
      .container-fluid {
        max-width: 3000px;
        margin-left: auto;
        margin-right: auto;
      }
    "))
    ),

    shinyjs::useShinyjs(),  # Initialise shinyjs

    shiny::titlePanel("Create Report Template"),

    shiny::sidebarLayout(
      shiny::sidebarPanel(width=3,
        shiny::fluidRow(
          shiny::column(8, style = "padding-right:5px;",
                 shiny::textInput("file_name", "Report File Name:", value = "report")),
          shiny::column(4, style = "padding-left:5px; padding-right:5px;",
                 shiny::selectInput("ext_name", "Format:",
                                        choices = list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats")),
                                        selected = "html", width='80%'))
        ),
        shiny::actionButton("browse", "Select Folder"),
        shiny::textOutput("selected_dir"),
        shiny::br(),
        shiny::actionLink("toggle_advanced", "\u25B6 Modify Report Header"),

        # Advanced options (initially hidden)
        shiny::div(
          id = "advanced_ui",
          style = "display: none;",
          shiny::tags$hr(),
          shiny::textInput("title", "Title", value = default_title),
          shiny::textInput("subtitle", "Subtitle", value = default_subtitle),
          shiny::textInput("author", "Author Name", value = default_name),
          shiny::textInput("affiliation", "Affiliation", value = default_affiliation),
          shiny::checkboxInput("reproducibility", "Include Reproducibility", value = default_reproducibility),
          shiny::br()
        ),
        shiny::br(), shiny::br(),
        shiny::tags$div(
          id = 'create_wrap',
          title = "Please select a folder.",
          style = "display: inline-block;",
          shiny::actionButton("create", "Create Report", class = "btn-primary", disabled = "disabled")
        )
      ),
      shiny::mainPanel(width=9,
                       shiny::uiOutput("preview_html")
      )
    ),
    shiny::br(),
    shiny::verbatimTextOutput("status")
  )

  server <- function(input, output, session) {
    output_path <- shiny::reactiveVal(NULL)
    show_advanced <- shiny::reactiveVal(FALSE)
    preview_inputs <- shiny::reactiveVal(NULL)
    last_preview <- shiny::reactiveVal(NULL)
    suppress_preview <- shiny::reactiveVal(FALSE)

    debounced_title <- shiny::debounce(shiny::reactive(input$title), 1200)
    debounced_subtitle <- shiny::debounce(shiny::reactive(input$subtitle), 1200)
    debounced_author <- shiny::debounce(shiny::reactive(input$author), 750)
    debounced_affiliation <- shiny::debounce(shiny::reactive(input$affiliation), 1000)
    debounced_reproducibility <- shiny::debounce(shiny::reactive(input$reproducibility), 0)

    debounced_inputs <- shiny::reactive({
      list(
        title = debounced_title() %||% default_title,
        subtitle = debounced_subtitle() %||% default_subtitle,
        author = debounced_author() %||% default_name,
        affiliation = debounced_affiliation() %||% default_affiliation,
        include_reproducibility = debounced_reproducibility() %||% default_reproducibility
      )
    })

    shiny::observe({
      preview_inputs(list(
        title = default_title,
        subtitle = default_subtitle,
        author = default_name,
        affiliation = default_affiliation,
        include_reproducibility = default_reproducibility
      ))
    })


    generate_preview <- function(title, subtitle, author, affiliation, include_reproducibility) {
      template_path <- system.file("example_reports", "example.html", package = "thekidsbiostats")

      html_lines <- update_html_template(
        readLines(template_path, warn = FALSE),
        title = title,
        subtitle = subtitle,
        author = author,
        affiliation = affiliation,
        include_reproducibility = include_reproducibility
      )
      render_preview(html_lines)
    }

    shiny::observe({
      if (isTRUE(suppress_preview())) return()  # Don't update if suppressed

      new_inputs <- debounced_inputs()
      old_inputs <- last_preview()

      if (is.null(old_inputs) || !identical(new_inputs, old_inputs)) {
        preview_inputs(new_inputs)
        last_preview(new_inputs)
      }
    })


    output$preview_html <- shiny::renderUI({
      shiny::req(preview_inputs())
      path <- generate_preview(
        title = debounced_inputs()$title,
        subtitle = debounced_inputs()$subtitle,
        author = debounced_inputs()$author,
        affiliation = debounced_inputs()$affiliation,
        include_reproducibility = debounced_inputs()$include_reproducibility
      )

      shiny::addResourcePath("preview", dirname(path))

      shiny::tags$div(
        style = "height: calc(100vh - 140px); overflow-y: hidden; border: 1px solid #ddd; padding: 0;",
        shiny::tags$iframe(
          src = paste0("preview/", basename(path)),
          style = "width: 100%; height: 100%; border: none; pointer-events: none;"
        )
      )

    })

    default_name <- Sys.info()[["user"]]
    if (grepl("^[A-Z]{2}[a-z]", default_name)) {
      default_name <- paste0(substr(default_name, 1, 1), " ", substr(default_name, 2, nchar(default_name)))
    } else {
      default_name <- gsub("(?<=[a-z])(?=[A-Z])", " ", default_name, perl = TRUE)
    }

    # Map the resource path for your example_reports folder inside the package
    shiny::addResourcePath(
      prefix = "example_reports",
      directoryPath = system.file("example_reports", package = "thekidsbiostats")
    )

    # Disable the Create Template button initially
    shinyjs::disable("create")

    shiny::observeEvent(input$browse, {
      selected <- rstudioapi::selectDirectory("Choose target directory")
      if (!is.null(selected)) output_path(selected)

      if (!nzchar(input$file_name)) {
        shinyjs::disable("create")
        shinyjs::runjs('document.getElementById("create_wrap").setAttribute("title", "Please enter a valid file name");')
      } else if (is.null(output_path())) {
        shinyjs::disable("create")
        shinyjs::runjs('document.getElementById("create_wrap").setAttribute("title", "Please select a folder");')
      } else {  # Enable the button
        shinyjs::enable("create")
        shinyjs::runjs('document.getElementById("create_wrap").setAttribute("title", "Create template.");')
      }

    })

    output$selected_dir <- shiny::renderText({
      req(output_path())
      output_path()
    })


    shiny::observeEvent(input$toggle_advanced, {
      suppress_preview(TRUE)  # Suppress auto preview update

      show_advanced(!show_advanced())

      # Toggle visibility
      if (show_advanced()) {
        shiny::updateActionLink(session, "toggle_advanced", label = "\u25BC Modify Report Header")
        shinyjs::show("advanced_ui")
      } else {
        shiny::updateActionLink(session, "toggle_advanced", label = "\u25B6 Modify Report Header")
        shinyjs::hide("advanced_ui")
      }

      # Reset suppression AFTER a short delay (after UI settles)
      later::later(function() suppress_preview(FALSE), delay = 0.1)
    })

    shiny::observeEvent(input$create, {
      req(input$file_name, output_path())

      file_name <- ifelse(endsWith(input$file_name, ".qmd"), sub("\\.qmd$", "", input$file_name), input$file_name)
      qmd_file <- file.path(output_path(), paste0(file_name, '.qmd'))

      if (file.exists(qmd_file)) {
        output$status <- shiny::renderText(paste0("\u26A0\uFE0F Report file '", qmd_file, "' already exists. Skipping creation."))
      } else {
        tryCatch({
          create_template(
            file_name = file_name,
            directory = output_path(),
            ext_name = input$ext_name,
            title = input$title,
            subtitle = input$subtitle,
            author = input$author,
            affiliation = input$affiliation,
            include_reproducibility = input$reproducibility,
            open_file = FALSE
          )
          output$status <- shiny::renderText(paste0("\u2705 '", file_name, ".qmd' template created successfully."))

          shiny::showModal(shiny::modalDialog(
            title = shiny::tags$div(
              style = "display: flex; align-items: center; gap: 10px;",
              shiny::icon("check-circle", class = "text-success"),
              shiny::tags$span("Template Successfully Created")
            ),
            shiny::HTML(paste0(
              "<p style='margin-top: 10px; font-size: 1.1em;'>",
              "The file <span style='font-family: monospace; background-color: #f8f9fa; padding: 2px 6px; border-radius: 4px;'>",
              file_name,
              ".qmd</span> was created successfully.",
              "<br><br>",
              "</p><p>Would you like to open it now?</p>"
            )),
            easyClose = FALSE,
            footer = shiny::tagList(
              shiny::tags$div(
                style = "display: flex; justify-content: space-between; width: 100%;",
                shiny::tags$div(
                  shiny::actionButton("cancel_open", "Close", class = "btn btn-secondary"),
                  shiny::actionButton("confirm_open", "Open Template", class = "btn btn-primary")
                ),
                shiny::tags$div(
                  shiny::actionButton("exit", "Exit App", class = "btn btn-danger")
                )
              )
            )
          ))
        }, error = function(e) {
          shiny::showModal(shiny::modalDialog("Error", e$message, easyClose = TRUE))
        })
      }

    })

    shiny::observeEvent(input$confirm_open, {
      shiny::removeModal()

      file_name <- ifelse(endsWith(input$file_name, ".qmd"), sub("\\.qmd$", "", input$file_name), input$file_name)
      qmd_file <- file.path(output_path(), paste0(file_name, '.qmd'))

      if (file.exists(qmd_file) && rstudioapi::isAvailable()) {
        output$status <- shiny::renderText("\U0001F4C2 Opening template file.")
        rstudioapi::navigateToFile(qmd_file)
      }

      shiny::stopApp()
    })

    shiny::observeEvent(input$cancel_open, {
      shiny::removeModal()
    })

    shiny::observeEvent(input$exit, {
      shiny::removeModal()
      shiny::stopApp()
    })

  }

  shiny::runGadget(ui, server, viewer=shiny::dialogViewer('thekidsbiostats: Create Template Addin', width=1600, height=900))
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

  #viewer <- shiny::dialogViewer("Insert Model Tabs", width = 700, height = 700)
  shiny::shinyApp(ui = ui, server = server)
}
