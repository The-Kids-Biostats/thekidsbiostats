library(testthat)
library(shiny)
library(mockery)

test_that("insert_callout triggers insertText for each button", {
  inserted <- character(0)

  # Mock rstudioapi::insertText to capture calls
  mock_insert <- function(text) {
    inserted <<- c(inserted, text)
  }

  # Mock shiny::runGadget to just run the server logic without launching UI
  mock_run <- function(ui, server, viewer) {
    # simulate pressing each button
    testServer(server, {
      session$setInputs(note = 1, warning = 1, caution = 1, important = 1, tip = 1)
    })
    "ran"
  }

  # Patch the functions temporarily
  stub(insert_callout, 'rstudioapi::insertText', mock_insert)
  stub(insert_callout, 'shiny::runGadget', mock_run)

  res <- insert_callout()
  expect_equal(res, "ran")

  # Check all callouts were inserted with collapse parameter and title/content placeholders
  expected <- c(
    "::: {.callout-note collapse=\"true\"}\n## <title>\n<content>\n:::\n",
    "::: {.callout-warning collapse=\"true\"}\n## <title>\n<content>\n:::\n",
    "::: {.callout-caution collapse=\"true\"}\n## <title>\n<content>\n:::\n",
    "::: {.callout-important collapse=\"false\"}\n## <title>\n<content>\n:::\n",
    "::: {.callout-tip collapse=\"true\"}\n## <title>\n<content>\n:::\n"
  )
  expect_setequal(inserted, expected)
})
