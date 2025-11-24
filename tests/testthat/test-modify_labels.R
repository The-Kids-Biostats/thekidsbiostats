library(testthat)

test_that("Correctly returns error if non-flextable object is parsed", {
  dat <- data.frame(x = 1:3,
                    y = letters[1:3])
  expect_error(modify_labels(dat), "Error: the table is not a flextable")
})

test_that("Returns an object of class flextable", {
  dat <- data.frame(x = 1:3,
                    y = letters[1:3])
  ft <- flextable::flextable(dat)

  expect_s3_class(modify_labels(ft), "flextable")
})

test_that("padding arguments are forwarded to flextable internals", {
  df <- data.frame(x = 1:3,
                   y = letters[1:3])
  ft <- flextable(df)

  # Change padding on flextable
  ft1 <- padding(ft,
                 j = 1,
                 padding.left = 6)

  # Change padding using modify_labels
  ft2 <- modify_labels(ft,
                       j = 1,
                       padding.left = 6)

  # Extract padding from fltextable objects
  padding_ft1 <- ft1$body$styles$pars$`padding.left`$data
  padding_ft2 <- ft2$body$styles$pars$`padding.left`$data

  # Check values are equivalent
  expect_equal(padding_ft1, padding_ft2)
})
