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
                                      shiny::imageOutput("logo_preview",
                                                         height = "150px"),
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
                                      shiny::verbatimTextOutput("status_styles")),

                      # ---- Column Margin Tab ----
                      shiny::tabPanel(
                        "Column Margins",
                        # ---- Header settings first ----
                        shiny::wellPanel(
                          shiny::tags$h4("Header settings"),
                          colourpicker::colourInput("colmargin_header_bg", "Background colour", value = NULL),
                          shiny::textInput("colmargin_header_text", "Text colour", value = NULL),
                          shiny::numericInput("colmargin_header_padding", "Padding (em)", value = NULL, step = 0.5),
                          shiny::textInput("colmargin_header_content", "Title", value = NULL),
                          shiny::selectInput("colmargin_header_weight",
                                             "Font weight",
                                             choices = c("bold"),
                                             selected = NULL
                                             )
                        ),

                        # ---- Box settings ----
                        shiny::wellPanel(
                          shiny::tags$h4("Box settings"),
                          shiny::numericInput("colmargin_border_width", "Border width (px)", value = NULL),
                          colourpicker::colourInput("colmargin_border_color", "Border colour", value = NULL),
                          shiny::numericInput("colmargin_padding", "Padding (em)", value = NULL),
                          colourpicker::colourInput("colmargin_bg_color", "Background colour", value = NULL)
                        ),

                        # ---- Apply / Revert buttons ----
                        shiny::actionButton("apply_colmargin", "Update Column Margin"),
                        shiny::actionButton("revert_colmargin", "Revert Column Margin")
                      )
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
        shiny::tags$p("Please select the folder where the Quarto theming documents are currently stored. If `thekidsbiostats::create_template()` was used, this is the _extensions folder."),
        shiny::actionButton("browse_folder",
                            "Select Quarto styling folder"),
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
        req(current_defaults())
        update_ui_from_defaults(current_defaults(), session, logo_file)
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
        req(current_defaults())
        callout_ui(current_defaults()$callout_colours)
      })
    })

    # ---- Enable/disable Callouts "Update" and "Revert" buttons ----
    shiny::observe({
      req(folder())

      current_callouts <- get_current_callouts(input)

      defaults_callouts <- current_defaults()$callout_colours

      changed <- callouts_changed(current_callouts, defaults_callouts)

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
      logo_path <- get_active_logo(folder())
      req(logo_path)

      list(src = logo_path,
           width = 150#input$logo_width,
           #height = input$logo_height
           )
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
      current_callouts <- get_current_callouts(input)
      update_colors(folder(),
                    callout_colours = callouts)
      })

    shiny::observeEvent(input$revert_styles, {
      req(folder())
      meta_path <- file.path(folder(), META_FILENAME)
      d <- jsonlite::fromJSON(meta_path)
      css_path <- file.path(folder(), "styles.css")

      revert_callouts_css(css_path, d$callout_colours)
      update_callout_inputs(session, d$callout_colours)
    })
    shiny::observeEvent(input$apply_colmargin, {
      req(folder())
      current_colmargin <- get_column_margin(input)
      update_colors(folder(),
                    column_margin = current_colmargin)
    })

    shiny::observeEvent(input$revert_colmargin, {
      req(folder())
      meta_path <- file.path(folder(), META_FILENAME)
      d <- jsonlite::fromJSON(meta_path)
      css_path <- file.path(folder(), "styles.css")

      revert_callouts_css(css_path, d$column_margin)
      update_callout_inputs(session, d$column_margin)
    })
  }

  shiny::runApp(list(ui = ui, server = server),
                launch.browser = rstudioapi::viewer)
}
