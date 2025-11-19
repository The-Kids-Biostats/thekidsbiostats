library(testthat)
library(withr)

test_that("invalid output and device produce informative errors", {
  expect_error(
    thekids_save(filename = "x", output = "not-a-size", device = "pdf"),
    "Your selection for 'output'"
  )

  expect_error(
    thekids_save(filename = "x", output = "full portrait", device = "not-a-device"),
    "Your selection for 'device'"
  )
})

test_that("saves pdf and png files with expected suffixes", {
  td <- local_tempdir()
  p <- ggplot(mtcars, aes(hp, mpg)) + geom_point()

  thekids_save(plot = p, filename = "t_pdf", path = td, output = "full portrait", device = "pdf")
  thekids_save(plot = p, filename = "t_png", path = td, output = "full portrait", device = "png")

  expect_true(file.exists(file.path(td, "t_pdf_full_portrait.pdf")))
  expect_true(file.exists(file.path(td, "t_png_full_portrait.png")))
})

test_that("uses explicit plot argument (not last_plot) when provided", {
  td <- local_tempdir()
  p1 <- ggplot(mtcars, aes(hp, mpg)) + geom_point()
  p2 <- ggplot(mtcars, aes(wt, mpg)) + geom_point()

  # save p1 explicitly
  thekids_save(plot = p1, filename = "explicit", path = td, output = "full portrait", device = "png")

  # change last_plot to p2 (so relying on last_plot would differ)
  print(p2)

  expect_true(file.exists(file.path(td, "explicit_full_portrait.png")))
})

test_that("default behaviour uses last_plot() when plot is omitted", {
  td <- local_tempdir()
  p <- ggplot(mtcars, aes(hp, mpg)) + geom_point()
  print(p)  # sets last_plot()

  thekids_save(filename = "from_lastplot", path = td, output = "full portrait", device = "png")

  expect_true(file.exists(file.path(td, "from_lastplot_full_portrait.png")))
})
