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

  # 1) Establish UI
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
                                        shiny::column(6,
                                                      shiny::numericInput("logo_width", "Width (px)",
                                                                          value = 150, min = 10)),
                                        shiny::column(6, shiny::numericInput("logo_height",
                                                                             "Height (px)",
                                                                             value = 150,
                                                                             min = 10))),
                                      shiny::fileInput("logo", "Upload logo (PNG or JPG only)",
                                                       accept = c(".png", ".jpg", ".jpeg")),
                                      shiny::textInput("newname",
                                                       "Save uploaded file as",
                                                       value = "",
                                                       placeholder = "Select a file first"),
                                      shiny::actionButton("apply_logo",
                                                          "Update Logo"),
                                      shiny::actionButton("revert_logo",
                                                          "Revert to Default"),
                                      shiny::verbatimTextOutput("qmd_preview_logo"),
                                      shiny::verbatimTextOutput("status_logo")),

                      # ---- Header Tab ----
                      shiny::tabPanel("Header",
                                      colourpicker::colourInput("banner_colour",
                                                                "Banner colour",
                                                                value = NULL),
                                      shiny::actionButton("apply_header",
                                                          "Update Banner Colour"),
                                      shiny::actionButton("revert_header",
                                                          "Revert Banner Colour"),
                                      shiny::verbatimTextOutput("qmd_preview_header")),

                      # ---- Styles Tab ----
                      shiny::tabPanel("Callouts",
                                      shiny::uiOutput("callout_ui"),
                                      shiny::actionButton("apply_styles",
                                                          "Update Styles"),
                                      shiny::actionButton("revert_styles",
                                                          "Revert Styles"),
                                      shiny::verbatimTextOutput("status_styles"))
                    )
                    )
      )
    )

  # 2) Establish server
  server <- function(input, output, session) {
    folder <- shiny::reactiveVal(NULL)
    defaults <- shiny::reactiveVal(NULL)
    logo_file <- shiny::reactiveVal(NULL)

    logo_preview_path <- shiny::reactive({
      if (!is.null(input$logo)) input$logo$datapath
      else if (!is.null(logo_file())) file.path(folder(), logo_file())
      else NULL
    })

    # ---- Folder UI ----
    output$folder_ui <- shiny::renderUI({
      shiny::tagList(
        shiny::actionButton("browse_folder",
                            "Select project _extensions/html folder"),
        shiny::verbatimTextOutput("folder_path_display")
      )
    })
    output$folder_path_display <- shiny::renderText({ folder() })

    # ---- Current defaults reactive ----
    current_defaults <- shiny::reactive({
      req(folder())
      read_defaults(folder(), META_FILENAME)
    })

    # ---- Observe folder selection ----
    shiny::observeEvent(input$browse_folder, {
      f <- rstudioapi::selectDirectory()
      if (!is.null(f) && fs::dir_exists(f)) {
        folder(f)
        shiny::showNotification(paste("Folder set to:", f),
                                type = "message")
      } else {
        shiny::showNotification("No folder selected or folder does not exist",
                                type = "error")
      }
    })

    # ---- UI updates whenever defaults change ----
    shiny::observe({
      req(current_defaults())
      d <- current_defaults()
      defaults(d)
      logo_file(d$logo)

      shiny::updateTextInput(session, "newname",
                             value = d$logo)
      colourpicker::updateColourInput(session,
                                      "banner_colour",
                                      value = d$banner_colour)

      # Callouts
      output$callout_ui <- shiny::renderUI({
        lapply(c("note","tip","warning","important"), function(t) {
          shiny::wellPanel(
            shiny::h4(paste("Callout", t)),
            colourpicker::colourInput(
              paste0("col_", t, "_header"),
              "Header colour",
              value = d$callout_colours[[t]]$header
            ),
            colourpicker::colourInput(
              paste0("col_", t, "_bg"),
              "Background colour",
              value = d$callout_colours[[t]]$background
            )
          )
        })
      })
    })

    # ---- Enable/disable Callouts "Update" and "Revert" buttons ----
    shiny::observe({
      req(folder())

      current_callouts <- lapply(c("note","tip","warning","important"), function(t) {
        list(
          background = input[[paste0("col_", t, "_bg")]],
          header     = input[[paste0("col_", t, "_header")]]
        )
      })
      names(current_callouts) <- c("note","tip","warning","important")

      defaults_callouts <- current_defaults()$callout_colours

      changed <- sapply(names(current_callouts), function(t) {
        !identical(current_callouts[[t]]$background, defaults_callouts[[t]]$background) ||
          !identical(current_callouts[[t]]$header, defaults_callouts[[t]]$header)
      })

      if (any(changed)) {
        shinyjs::enable("apply_styles")
        shinyjs::enable("revert_styles")
      } else {
        shinyjs::disable("apply_styles")
      }
    })

    # Conditionally grey out update banner buttons
    shiny::observe({
      req(current_defaults(), folder())

      # JSON default
      default_banner <- current_defaults()$banner_colour
      # Actual banner in template.qmd
      template_banner <- parse_qmd_banner_colour(file.path(folder(), "template.qmd"))
      # What the user currently sees/input
      selected <- input$banner_colour

      # Initialize input if NULL
      if (is.null(selected) && !is.null(template_banner)) {
        colourpicker::updateColourInput(session, "banner_colour", value = template_banner)
        selected <- template_banner
      }

      # Apply button: differs from template.qmd
      shinyjs::toggleState("apply_header", !identical(selected, template_banner))

    })

    # ---- Enable/disable "save as" and "update logo" based on upload ----
    shiny::observe({
      if (!is.null(input$logo)) {
        shiny::updateTextInput(session,
                               "newname",
                               value = input$logo$name)
        shinyjs::enable("newname")
        shinyjs::enable("apply_logo")
      } else {
        shiny::updateTextInput(session,
                               "newname",
                               value = "")
        shinyjs::disable("newname")
        shinyjs::disable("apply_logo")
      }
    })

    # ---- Logo Preview ----
    output$logo_preview <- shiny::renderImage({
      req(folder(), logo_file())

      # Always parse the active logo from styles.css
      css_path <- file.path(folder(),
                            "styles.css")
      css_lines <- readLines(css_path,
                             warn = FALSE)
      logo_name <- css_lines %>%
        grep("background-image",
             .,
             value = TRUE) %>%
        sub('.*url\\(([^)]+)\\).*', '\\1', .)

      logo_path <- file.path(folder(),
                             logo_name)
      list(src = logo_path,
           width = input$logo_width,
           height = input$logo_height)
    }, deleteFile = FALSE)

    # ---- Logo Apply/Revert ----
    shiny::observeEvent(input$apply_logo, {
      req(input$logo)
      newname <- ifelse(input$newname == "", input$logo$name, input$newname)
      update_logo(input$logo$datapath,
                  newname,
                  folder(),
                  META_FILENAME)
      logo_file(newname)
      output$status_logo <- shiny::renderText({ paste("Logo updated:", newname) })
    })
    shiny::observeEvent(input$revert_logo, {
      req(folder())
      revert_defaults(folder(),
                      META_FILENAME,
                      session,
                      logo_file)

      # Reset file upload and 'save as' input
      shinyjs::reset("logo")                    # clears uploaded file
      shiny::updateTextInput(session, "newname", value = "")
      shinyjs::disable("newname")               # disable until user uploads a new file
      shinyjs::disable("apply_logo")            # grey out update button


      output$status_logo <- shiny::renderText({ "Reverted to defaults from JSON" })
    })

    # ---- Header Apply/Revert ----
    shiny::observeEvent(input$apply_header, {
      req(folder(), input$banner_colour)
      update_colors(folder(), banner_colour = input$banner_colour)
      output$qmd_preview_header <- shiny::renderText({
        "Banner colour successfully changed!"
      })
    })
    shiny::observeEvent(input$revert_header, {
      req(folder())
      revert_defaults(folder(),
                      META_FILENAME,
                      session,
                      logo_file)
      output$qmd_preview_header <- shiny::renderText({
        "Banner colour successfully reverted to default!"
      })
    })

    # ---- Styles Apply/Revert ----
    shiny::observeEvent(input$apply_styles, {
      req(folder())
      callouts <- lapply(c("note","tip","warning","important"), function(t) {
        list(background = input[[paste0("col_", t, "_bg")]],
             header = input[[paste0("col_", t, "_header")]])
      })
      names(callouts) <- c("note","tip","warning","important")
      update_colors(folder(),
                    callout_colours = callouts)


    })

    shiny::observeEvent(input$revert_styles, {
      req(folder())

      # Load JSON defaults
      meta_path <- file.path(folder(), META_FILENAME)
      d <- jsonlite::fromJSON(meta_path)

      # Read CSS
      css_path <- file.path(folder(), "styles.css")
      css <- readLines(css_path, warn = FALSE)

      for (t in names(d$callout_colours)) {
        # find all .callout-<t> block starts
        bg_starts <- which(grepl(paste0("^\\s*\\.callout-", t, "\\s*\\{\\s*$"),
                                 css,
                                 perl = TRUE))
        if (length(bg_starts)) {
          for (start in bg_starts) {
            # look ahead safely from start+1 to end
            if (start < length(css)) {
              tail_idx <- seq.int(start + 1, length(css))
              # find first background-color line in the block
              brace_close_rel <- which(grepl("^\\s*\\}",
                                             css[tail_idx],
                                             perl = TRUE))
              block_end_rel <- if (length(brace_close_rel)) brace_close_rel[1] - 1 else length(tail_idx)
              if (block_end_rel >= 1) {
                block_lines_idx <- tail_idx[seq_len(block_end_rel)]
                bg_rel <- which(grepl("background-color\\s*:",
                                      css[block_lines_idx],
                                      perl = TRUE))
                if (length(bg_rel)) {
                  idx <- block_lines_idx[bg_rel[1]]
                  # preserve trailing text like "!important;" by replacing only the value
                  css[idx] <- sub(
                    "(background-color\\s*:\\s*)[^;]+",
                    paste0("\\1", d$callout_colours[[t]]$background),
                    css[idx],
                    perl = TRUE
                  )
                }
              }
            }
          }
        }

        # find all .callout-<t> .callout-header starts
        header_starts <- which(grepl(paste0("^\\s*\\.callout-", t, "\\s+\\.callout-header\\s*\\{\\s*$"), css, perl = TRUE))
        if (length(header_starts)) {
          for (start in header_starts) {
            if (start < length(css)) {
              tail_idx <- seq.int(start + 1, length(css))
              brace_close_rel <- which(grepl("^\\s*\\}",
                                             css[tail_idx],
                                             perl = TRUE))
              block_end_rel <- if (length(brace_close_rel)) brace_close_rel[1] - 1 else length(tail_idx)
              if (block_end_rel >= 1) {
                block_lines_idx <- tail_idx[seq_len(block_end_rel)]
                bg_rel <- which(grepl("background-color\\s*:",
                                      css[block_lines_idx],
                                      perl = TRUE))
                if (length(bg_rel)) {
                  idx <- block_lines_idx[bg_rel[1]]
                  css[idx] <- sub(
                    "(background-color\\s*:\\s*)[^;]+",
                    paste0("\\1", d$callout_colours[[t]]$header),
                    css[idx],
                    perl = TRUE
                  )
                }
              }
            }
          }
        }
      }

      # Write back CSS
      writeLines(css, css_path)

      # Update Shiny UI inputs
      for (t in names(d$callout_colours)) {
        colourpicker::updateColourInput(session,
                                        paste0("col_", t, "_bg"),
                                        value = d$callout_colours[[t]]$background)
        colourpicker::updateColourInput(session,
                                        paste0("col_", t, "_header"),
                                        value = d$callout_colours[[t]]$header)
      }
    })
  }

  shiny::runApp(list(ui = ui, server = server),
                launch.browser = rstudioapi::viewer)
}
