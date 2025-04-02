#' Insert Callout via RStudio Addin
#'
#' Launches a Shiny app as an RStudio addin to insert a Quarto callout at the cursor position.
#' The user selects a callout type from a dropdown, sees a preview color, and inserts formatted
#' callout text into the current script.
#'
#' @return A Shiny application that runs within RStudio.
#' @export
#'
#' @import shiny
#'
#' @examples
#' if (interactive()) {
#'   insert_callout()
#' }
insert_callout <- function() {
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
