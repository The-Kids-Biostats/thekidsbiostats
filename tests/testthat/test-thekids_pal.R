library(testthat)

test_that("thekids_pal returns a function", {
  pal_fun <- thekids_pal()
  expect_type(pal_fun, "closure")
})

test_that("thekids_pal generates correct number of colors", {
  pal_fun <- thekids_pal()
  cols <- pal_fun(5)
  expect_length(cols, 5)
  expect_true(all(grepl("^#", cols))) # hex codes
})

test_that("reverse = TRUE reverses palette", {
  pal_fun1 <- thekids_pal(reverse = FALSE)
  pal_fun2 <- thekids_pal(reverse = TRUE)

  cols1 <- pal_fun1(4)
  cols2 <- pal_fun2(4)

  expect_equal(rev(cols1), cols2)
})

test_that("invalid palette throws error", {
  expect_error(thekids_pal("not_a_palette"))
})
