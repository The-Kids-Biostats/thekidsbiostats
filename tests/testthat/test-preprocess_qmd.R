library(testthat)
library(mockery)

test_that("updates global option when requested", {
  tmp <- tempfile(fileext = ".qmd")
  writeLines(c("mainfont: 'OldFont'", "@import url('oldlink');"), tmp)

  old_option <- getOption("thekidsbiostats.font")
  on.exit(options(thekidsbiostats.font = old_option), add = TRUE)

  # Stub font and showtext functions
  stub(preprocess_qmd, "sysfonts::font_add_google", function(name, family) TRUE)
  stub(preprocess_qmd, "showtext::showtext_auto", function() TRUE)
  stub(preprocess_qmd, "readLines", function(file) c("mainfont: 'OldFont'", "@import url('oldlink');"))
  write_mock <- mockery::mock(TRUE)
  stub(preprocess_qmd, "writeLines", write_mock)

  preprocess_qmd(tmp, base_family = "Roboto", update_global_option = TRUE)

  expect_equal(getOption("thekidsbiostats.font"), "Roboto")
})

test_that("does not update global option when requested", {
  tmp <- tempfile(fileext = ".qmd")
  writeLines(c("mainfont: 'OldFont'", "@import url('oldlink');"), tmp)

  old_option <- getOption("thekidsbiostats.font")
  on.exit(options(thekidsbiostats.font = old_option), add = TRUE)

  # Stub font and showtext functions
  stub(preprocess_qmd, "sysfonts::font_add_google", function(name, family) TRUE)
  stub(preprocess_qmd, "showtext::showtext_auto", function() TRUE)
  stub(preprocess_qmd, "readLines", function(file) c("mainfont: 'OldFont'", "@import url('oldlink');"))
  write_mock <- mockery::mock(TRUE)
  stub(preprocess_qmd, "writeLines", write_mock)

  preprocess_qmd(tmp, base_family = "Roboto", update_global_option = FALSE)

  expect_equal(getOption("thekidsbiostats.font"), old_option)
})

test_that("calls font_add_google and showtext_auto", {
  tmp <- tempfile(fileext = ".qmd")
  writeLines(c("mainfont: 'OldFont'", "@import url('oldlink');"), tmp)

  font_mock <- mockery::mock(TRUE)
  showtext_mock <- mockery::mock(TRUE)
  stub(preprocess_qmd, "sysfonts::font_add_google", font_mock)
  stub(preprocess_qmd, "showtext::showtext_auto", showtext_mock)
  stub(preprocess_qmd, "readLines", function(file) c("mainfont: 'OldFont'", "@import url('oldlink');"))
  write_mock <- mockery::mock(TRUE)
  stub(preprocess_qmd, "writeLines", write_mock)

  preprocess_qmd(tmp, base_family = "Roboto")

  expect_called(font_mock, 1)
  expect_called(showtext_mock, 1)
})

test_that("updates mainfont and @import URL in .qmd content", {
  tmp <- tempfile(fileext = ".qmd")

  old_content <- c(
    "title: 'Report'",
    "mainfont: 'OldFont'",
    "subtitle: 'Sub'",
    "@import url('oldlink');",
    "other: 123"
  )
  writeLines(old_content, tmp)

  # Stub font functions
  stub(preprocess_qmd, "sysfonts::font_add_google", function(name, family) TRUE)
  stub(preprocess_qmd, "showtext::showtext_auto", function() TRUE)

  # Run function
  preprocess_qmd(tmp, base_family = "Roboto", update_global_option = FALSE)

  # Read back
  written_content <- readLines(tmp)

  # Assertions
  expect_true(any(grepl("mainfont: 'Roboto'", written_content)))
  expect_true(any(grepl("@import url\\('https://fonts.googleapis.com/css2\\?family=Roboto&display=swap'\\);", written_content)))
})
