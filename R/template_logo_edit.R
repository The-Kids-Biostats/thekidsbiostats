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

  # ---- UI ----
  ui <- shiny::fluidPage(
    shinyjs::useShinyjs(),
    shiny::titlePanel("Customise Project Template Formatting"),

    shiny::fluidRow(
      shiny::column(12,
        shiny::uiOutput("folder_ui"),
        shiny::hr(),
        shiny::tabsetPanel(
          id = "tabs",
          type = "pills",

          # ---- Logo Tab ----
          shiny::tabPanel("Logo",
            shiny::h4("Current logo selection"),
            shiny::imageOutput("logo_preview"),
            shiny::fluidRow(
              shiny::column(6, shiny::numericInput("logo_width", "Width (px)", value = 150, min = 10)),
              shiny::column(6, shiny::numericInput("logo_height", "Height (px)", value = 150, min = 10))
            ),
            shiny::fileInput("logo", "Upload logo (PNG or JPG only)", accept = c(".png", ".jpg", ".jpeg")),
            shiny::textInput("newname", "Save uploaded file as", value = "", placeholder = "Select a file first"),
            shiny::actionButton("apply_logo", "Update Logo"),
            shiny::actionButton("revert_logo", "Revert to Default"),
            shiny::verbatimTextOutput("qmd_preview_logo"),
            shiny::verbatimTextOutput("status_logo")
          ),

          # ---- Header Tab ----
          shiny::tabPanel("Header",
            colourpicker::colourInput("banner_colour", "Banner colour", value = NULL),
            shiny::actionButton("apply_header", "Update Banner Colour"),
            shiny::actionButton("revert_header", "Revert Banner Colour"),
            shiny::verbatimTextOutput("qmd_preview_header")
          ),

          # ---- Styles Tab ----
          shiny::tabPanel("Styles",
            lapply(c("note","tip","warning","important"), function(t) {
              colourpicker::colourInput(paste0("col_", t),
                                        paste0("Callout ", t, " colour"),
                                        value = NULL)
            }),
            shiny::actionButton("apply_styles", "Update Styles"),
            shiny::actionButton("revert_styles", "Revert Styles")
          )
        )
      )
    )
  )

  # ---- Server ----
  server <- function(input, output, session) {
    folder <- shiny::reactiveVal(NULL)
    defaults <- shiny::reactiveVal(NULL)
    logo_file <- shiny::reactiveVal(NULL)

    # ---- Helpers ----
    parse_qmd_logo <- function(qmd_path) {
      qmd <- readLines(qmd_path, warn = FALSE)
      logo_line <- grep("logo:", qmd, value = TRUE)
      if (length(logo_line)) gsub(".*logo:\\s*", "", logo_line[1]) else "thekids.png"
    }

    parse_qmd_banner_colour <- function(qmd_path) {
      qmd <- readLines(qmd_path, warn = FALSE)
      line <- grep("^\\s*title-block-banner\\s*:\\s*", qmd, value = TRUE)
      if (length(line)) sub("^\\s*title-block-banner\\s*:\\s*", "", line[1]) else NULL
    }

    parse_css_colors <- function(css_path) {
      css <- readLines(css_path, warn = FALSE)
      types <- c("note","tip","warning","important")
      out <- setNames(vector("list", length(types)), types)
      for (t in types) {
        pattern <- paste0("\\.callout-", t, "\\s*\\{[^}]*background-color:\\s*([^;]+);")
        m <- regmatches(css, regexec(pattern, css))
        val <- unlist(lapply(m, function(x) if(length(x) >= 2) x[2]))
        out[[t]] <- ifelse(length(val) > 0, val[1], NA)
      }
      out
    }

    read_defaults <- function(folder_html) {
      qmd_path <- file.path(folder_html, "template.qmd")
      css_path <- file.path(folder_html, "styles.css")
      qmd_orig <- file.path(folder_html, "template.qmd.orig")
      css_orig <- file.path(folder_html, "styles.css.orig")
      if (!fs::file_exists(qmd_orig)) fs::file_copy(qmd_path, qmd_orig)
      if (!fs::file_exists(css_orig)) fs::file_copy(css_path, css_orig)
      list(
        logo = parse_qmd_logo(qmd_path),
        banner_colour = parse_qmd_banner_colour(qmd_path),
        callout_colours = parse_css_colors(css_path),
        qmd_path = qmd_path,
        css_path = css_path
      )
    }

    update_ui_from_defaults <- function(d) {
      shiny::updateTextInput(session, "newname", value = d$logo)
      colourpicker::updateColourInput(session, "banner_colour", value = d$banner_colour)
      for (t in names(d$callout_colours)) {
        colourpicker::updateColourInput(session, paste0("col_", t), value = d$callout_colours[[t]])
      }
      logo_file(d$logo)
    }

    update_logo <- function(infile, newname, folder_html) {
      dest_html <- file.path(folder_html, newname)
      fs::file_copy(infile, dest_html, overwrite = TRUE)
      folder_parent <- fs::path_norm(fs::path(folder_html, ".."))
      dest_parent <- file.path(folder_parent, newname)
      fs::file_copy(infile, dest_parent, overwrite = TRUE)
      # Update template.qmd
      qmd <- readLines(file.path(folder_html, "template.qmd"), warn = FALSE)
      qmd_new <- gsub("logo:\\s*.*", paste0("logo: ", newname), qmd)
      writeLines(qmd_new, file.path(folder_html, "template.qmd"))
      # Update styles.css
      css <- readLines(file.path(folder_html, "styles.css"), warn = FALSE)
      css_new <- gsub("url\\s*\\(\\s*[^)]+\\)", paste0("url(", newname, ")"), css)
      writeLines(css_new, file.path(folder_html, "styles.css"))
      # Save meta
      meta <- list(logo = newname, modified_time = format(Sys.time(), tz = Sys.timezone(), usetz = TRUE))
      writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE),
                 file.path(folder_html, META_FILENAME))
    }

    logo_preview_path <- shiny::reactive({
      if (!is.null(input$logo)) {
        # uploaded file takes precedence
        input$logo$datapath
      } else if (!is.null(logo_file())) {
        file.path(folder(), logo_file())
      } else {
        NULL
      }
    })

    update_colors <- function(folder_html, banner_colour = NULL, callout_colours = NULL) {
      if (!is.null(banner_colour)) {
        qmd <- readLines(file.path(folder_html, "template.qmd"), warn = FALSE)
        qmd_new <- gsub("title-block-banner:\\s*.*", paste0("title-block-banner: ", banner_colour), qmd)
        writeLines(qmd_new, file.path(folder_html, "template.qmd"))
      }
      if (!is.null(callout_colours)) {
        css <- readLines(file.path(folder_html, "styles.css"), warn = FALSE)
        for (type in names(callout_colours)) {
          pattern <- paste0("(\\.callout-", type, "\\s*\\{[^}]*background-color:\\s*)([^;]+)")
          css <- gsub(pattern, paste0("\\1", callout_colours[[type]]), css)
        }
        writeLines(css, file.path(folder_html, "styles.css"))
      }
    }

    revert_defaults <- function(folder_html) {
      fs::file_copy(file.path(folder_html, "template.qmd.orig"), file.path(folder_html, "template.qmd"), overwrite = TRUE)
      fs::file_copy(file.path(folder_html, "styles.css.orig"), file.path(folder_html, "styles.css"), overwrite = TRUE)
      defaults(read_defaults(folder_html))
      logo_file(defaults()$logo)
      update_ui_from_defaults(defaults())
    }

    # ---- Folder Selection ----
    shiny::observe({
      default_folder <- file.path(getwd(), "reports", "_extensions", "html")
      if (fs::dir_exists(default_folder)) {
        folder(default_folder)
        defaults(read_defaults(default_folder))
        update_ui_from_defaults(defaults())
      }
      output$folder_ui <- shiny::renderUI({
        shiny::tagList(
          shiny::actionButton("browse_folder", "Select project _extensions/html folder"),
          shiny::verbatimTextOutput("folder_path_display")
        )
      })
    })

    shiny::observeEvent(input$browse_folder, {
      f <- rstudioapi::selectDirectory()
      if (!is.null(f) && fs::dir_exists(f)) {
        folder(f)
        defaults(read_defaults(f))
        update_ui_from_defaults(defaults())
        shiny::showNotification(paste("Folder set to:", f), type = "message")
      } else shiny::showNotification("No folder selected or folder does not exist", type = "error")
    })

    output$folder_path_display <- shiny::renderText({ folder() })

    # ---- Logo Preview Reactive ----
    shiny::observe({
      req(folder(), logo_file())
      output$logo_preview <- shiny::renderImage({
        req(logo_preview_path())
        list(
          src = logo_preview_path(),
          width = 150,  # fixed small preview width
          height = NULL # maintain aspect ratio
        )
      }, deleteFile = FALSE)
    })

    # Enable filename input and update current selection
    shiny::observeEvent(input$logo, {
      req(input$logo)
      # Update the reactive logo file to the uploaded file temporarily
      logo_file(input$logo$name)
      # Set the 'newname' input to the uploaded filename
      shiny::updateTextInput(session, "newname", value = input$logo$name)
    })

    # ---- Logo Upload/Apply ----
    shiny::observeEvent(input$apply_logo, {
      req(input$logo)
      newname <- input$newname
      if (newname == "") newname <- input$logo$name
      update_logo(input$logo$datapath, newname, folder())
      logo_file(newname)
      output$status_logo <- shiny::renderText({ paste("Logo updated:", newname) })
    })

    shiny::observeEvent(input$revert_logo, {
      revert_defaults(folder())
      output$status_logo <- shiny::renderText({ "Logo reverted to default" })
    })

    # ---- Header Apply/Revert ----
    shiny::observeEvent(input$apply_header, {
      req(folder(), input$banner_colour)
      update_colors(folder(), banner_colour = input$banner_colour)
      output$qmd_preview_header <- shiny::renderText({ head(readLines(file.path(folder(), "template.qmd")), 20) })
    })

    shiny::observeEvent(input$revert_header, {
      req(folder())
      revert_defaults(folder())
      colourpicker::updateColourInput(session, "banner_colour", value = defaults()$banner_colour)
      output$qmd_preview_header <- shiny::renderText({ head(readLines(file.path(folder(), "template.qmd")), 20) })
    })

    # ---- Styles Apply/Revert ----
    shiny::observeEvent(input$apply_styles, {
      req(folder())
      callouts <- lapply(c("note","tip","warning","important"), function(t) input[[paste0("col_", t)]])
      names(callouts) <- c("note","tip","warning","important")
      update_colors(folder(), callout_colours = callouts)
    })

    shiny::observeEvent(input$revert_styles, {
      req(folder())
      revert_defaults(folder())
      for (t in names(defaults()$callout_colours)) {
        colourpicker::updateColourInput(session, paste0("col_", t), value = defaults()$callout_colours[[t]])
      }
    })
  }

  shiny::runApp(list(ui = ui, server = server), launch.browser = rstudioapi::viewer)
}
