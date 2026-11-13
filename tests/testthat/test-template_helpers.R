html_fixture <- function() {
  path <- system.file("example_reports", "example.html", package = "thekidsbiostats")
  skip_if(path == "", "example.html fixture not available")
  readLines(path, warn = FALSE)
}

qmd_fixture <- function() {
  path <- system.file("quarto_templates", "template_html.qmd", package = "thekidsbiostats")
  skip_if(path == "", "template_html.qmd fixture not available")
  readLines(path, warn = FALSE)
}

default_html_args <- function(...) {
  utils::modifyList(
    list(title = "My Title", subtitle = "My Subtitle", author = "A Researcher",
         affiliation = "Test Affiliation, WA", include_reproducibility = TRUE,
         show_code = TRUE, code_fold = TRUE, code_tools = TRUE),
    list(...)
  )
}

test_that("update_html_template replaces title, subtitle and author", {
  lines <- html_fixture()
  out <- do.call(update_html_template, c(list(lines), default_html_args()))

  expect_true(any(grepl('<h1 class="title">My Title</h1>', out, fixed = TRUE)))
  expect_true(any(grepl('<p class="subtitle lead">My Subtitle</p>', out, fixed = TRUE)))
  expect_true(any(grepl('<p class="author">A Researcher</p>', out, fixed = TRUE)))
})

test_that("update_html_template replaces the multi-line affiliation element", {
  lines <- html_fixture()
  out <- do.call(update_html_template, c(list(lines), default_html_args()))

  expect_equal(sum(grepl('<p class="affiliation">', out, fixed = TRUE)), 1)
  expect_true(any(out == '<p class="affiliation">Test Affiliation, WA</p>'))
  expect_equal(length(lines) - length(out), 2)
})

test_that("update_html_template leaves the document unchanged when no options are changed", {
  lines <- html_fixture()
  out <- update_html_template(lines, title = NULL, subtitle = NULL, author = NULL,
                              affiliation = NULL, include_reproducibility = TRUE,
                              show_code = TRUE, code_fold = TRUE, code_tools = TRUE)
  expect_identical(out, lines)
})

test_that("update_html_template removes reproducibility section when requested", {
  lines <- html_fixture()
  out <- do.call(update_html_template,
                 c(list(lines), default_html_args(include_reproducibility = FALSE)))

  expect_false(any(grepl("START REPRODUCIBILITY", out, fixed = TRUE)))
  expect_false(any(grepl("END REPRODUCIBILITY", out, fixed = TRUE)))
  expect_lt(length(out), length(lines))
})

test_that("update_html_template removes the analysis code chunk when show_code is FALSE", {
  lines <- html_fixture()
  n_before <- sum(lines == '<details class="code-fold">')
  out <- do.call(update_html_template,
                 c(list(lines), default_html_args(show_code = FALSE)))

  expect_equal(sum(out == '<details class="code-fold">'), n_before - 1)
})

test_that("update_html_template unfolds code chunks when code_fold is FALSE", {
  lines <- html_fixture()
  n_before <- sum(lines == '<details class="code-fold">')
  out <- do.call(update_html_template,
                 c(list(lines), default_html_args(code_fold = FALSE)))

  expect_equal(sum(out == '<details class="code-fold">'), n_before - 1)
  expect_true(any(out == '<div class="code-unfolded">'))
})

test_that("update_html_template keeps folded chunks when code_fold is TRUE", {
  lines <- html_fixture()
  out <- do.call(update_html_template,
                 c(list(lines), default_html_args(code_fold = TRUE)))

  expect_false(any(out == '<div class="code-unfolded">'))
  expect_equal(sum(out == '<details class="code-fold">'),
               sum(lines == '<details class="code-fold">'))
})

test_that("update_qmd_template updates title, subtitle, author and affiliation", {
  lines <- qmd_fixture()
  out <- update_qmd_template(lines, title = "New Title", subtitle = "New Sub",
                             author = "New Author", affiliation = "New Aff, WA")

  expect_true(any(out == 'title: "New Title"'))
  expect_true(any(out == 'subtitle: "New Sub"'))
  expect_true(any(out == '  name: "New Author"'))
  expect_true(any(out == '  - "New Aff, WA"'))
})

test_that("update_qmd_template sets code chunk YAML options", {
  lines <- qmd_fixture()
  out <- update_qmd_template(lines, echo = TRUE, code_fold = FALSE, code_tools = FALSE)

  expect_true(any(out == "  echo: true"))
  expect_true(any(out == "    code-fold: false"))
  expect_true(any(out == "    code-tools: false"))
})

test_that("update_qmd_template removes reproducibility section when requested", {
  lines <- qmd_fixture()
  out <- update_qmd_template(lines, include_reproducibility = FALSE)

  expect_false(any(grepl("^# Reproducibility Information", out)))
  expect_false(any(grepl("sessionInfo()", out, fixed = TRUE)))
  expect_true(any(grepl("^# Supplementary Material", out)))
})

test_that("update_qmd_template keeps reproducibility section by default", {
  lines <- qmd_fixture()
  out <- update_qmd_template(lines)

  expect_true(any(grepl("^# Reproducibility Information", out)))
})

test_that("render_preview writes lines to an html file and returns its path", {
  lines <- c("<html>", "<body>preview</body>", "</html>")
  path <- render_preview(lines)

  expect_true(file.exists(path))
  expect_equal(tools::file_ext(path), "html")
  expect_equal(readLines(path, warn = FALSE), lines)
})
