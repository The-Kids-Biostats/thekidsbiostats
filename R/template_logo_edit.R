# R/logo_editor.R

#' Launch Template Logo Editor (Shiny) — package-local addin
#'
#' Replace the logo inside inst/ext_qmd/_extensions/html or create a modified zip.
#' Writes logo_meta.json with timestamp. After save, opens destination folder in OS file explorer
#' or RStudio Files pane so user can navigate to the saved logo.
#'
#' @param project_root Path to the root of the R project
#' @return A Shiny application that runs within RStudio.
#'
#' @export

template_logo_edit <- function() {
  META_FILENAME <- "logo_meta.json"

  ui <- shiny::fluidPage(
    shinyjs::useShinyjs(),
    shiny::titlePanel("Update Project Template Logo"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::uiOutput("folder_ui"),
        shiny::fileInput("logo", "Upload logo (PNG or JPG only)", accept = c(".png", ".jpg", ".jpeg")),
        shiny::textInput("newname", "Save uploaded file as", value = "", placeholder = "Select a file first"),
        shiny::actionButton("apply", "Update Logo"),
        shiny::hr(),
        shiny::verbatimTextOutput("status")
      ),
      shiny::mainPanel(
        shiny::h4("Preview (start of template.qmd)"),
        shiny::verbatimTextOutput("qmd_preview")
      )
    )
  )

  server <- function(input, output, session) {
    mods <- shiny::reactiveVal(NULL)
    ext_folder <- shiny::reactiveVal(NULL)

    shinyjs::disable("newname")

    # Determine initial folder
    default_folder <- file.path(getwd(), "reports", "_extensions", "html")
    if (fs::dir_exists(default_folder)) {
      ext_folder(default_folder)
      output$folder_ui <- shiny::renderUI({
        shiny::verbatimTextOutput("folder_path_display")
      })
      output$folder_path_display <- shiny::renderText({ ext_folder() })
    } else {
      output$folder_ui <- shiny::renderUI({
        shiny::tagList(
          shiny::actionButton("browse_folder", "Select project _extensions/html folder"),
          shiny::verbatimTextOutput("folder_path_display")
        )
      })
    }

    # Browse for folder
    shiny::observeEvent(input$browse_folder, {
      folder <- rstudioapi::selectDirectory()
      if (!is.null(folder) && fs::dir_exists(folder)) {
        ext_folder(folder)
        shiny::showNotification(paste("Folder set to:", folder), type = "message")
      } else {
        shiny::showNotification("No folder selected or folder does not exist", type = "error")
      }
    })

    # Enable filename input and populate when file uploaded
    shiny::observeEvent(input$logo, {
      shinyjs::enable("newname")
      shiny::updateTextInput(session, "newname", value = input$logo$name)
    })

    # Display folder path
    output$folder_path_display <- shiny::renderText({ ext_folder() })

    # Apply logo update
    shiny::observeEvent(input$apply, {
      shiny::req(input$logo)
      folder_html <- ext_folder()
      if (is.null(folder_html)) {
        shiny::showNotification("No folder selected", type = "error")
        return()
      }

      ext <- tools::file_ext(input$logo$name)
      if (!ext %in% c("png", "jpg", "jpeg")) {
        shiny::showNotification("Invalid file type. Only PNG or JPG allowed.", type = "error")
        return()
      }

      newname <- gsub("\\s+", "_", basename(input$newname))
      if (newname == "") newname <- input$logo$name

      infile <- input$logo$datapath

      # Copy to html folder
      dest_html <- file.path(folder_html, newname)
      fs::file_copy(infile, dest_html, overwrite = TRUE)

      # Copy to parent _extensions folder (for Quarto render)
      folder_parent <- fs::path_norm(fs::path(folder_html, ".."))
      dest_parent <- file.path(folder_parent, newname)
      fs::file_copy(infile, dest_parent, overwrite = TRUE)

      # Update template.qmd in html folder
      qmd_path <- file.path(folder_html, "template.qmd")
      if (!fs::file_exists(qmd_path)) stop("template.qmd not found in selected folder.")
      qmd <- readLines(qmd_path, warn = FALSE)
      qmd_new <- gsub("thekids.png", newname, qmd, fixed = TRUE)
      writeLines(qmd_new, qmd_path)

      # Update styles.css background-image
      # Update styles.css background-image
      css_path <- file.path(folder_html, "styles.css")
      if (fs::file_exists(css_path)) {
        css <- readLines(css_path, warn = FALSE)
        css_new <- gsub("url\\s*\\(\\s*thekids\\.png\\s*\\)", paste0("url(", newname, ")"), css)
        writeLines(css_new, css_path)
      }

      # Save metadata with local timezone
      meta <- list(logo = newname, modified_time = format(Sys.time(), tz = Sys.timezone(), usetz = TRUE))
      meta_path <- file.path(folder_html, META_FILENAME)
      writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE), meta_path)

      mods(list(qmd_preview = paste(head(qmd_new, 200), collapse = "\n"),
                last_saved_logo = dest_html))

      output$qmd_preview <- shiny::renderText({ mods()$qmd_preview })
      output$status <- shiny::renderText({
        paste0("Logo successfully updated to: ", mods()$last_saved_logo,
               "\nHeader in template.qmd and styles.css updated accordingly.")
      })
    })
  }

  shiny::runApp(list(ui = ui, server = server), launch.browser = rstudioapi::viewer)
}
