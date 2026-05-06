library(testthat)

test_that("errors on invalid palette name", {
  expect_error(
    thekids_pal("not_a_real_palette"),
    "not recognised"
  )
})


test_that("All palette types returns a function", {
  pal <- thekids_pal('primary')
  expect_type(pal, "closure")
  
  pal_seq <- thekids_pal('pumpkin')
  expect_type(pal, "closure")
  
  pal_div <- thekids_pal('pumpkin2celestial')
  expect_type(pal, "closure")
})


test_that("discrete palette returns correct number of colours", {
  pal <- thekids_pal('primary', discrete = TRUE)

  expect_length(pal(5), 5)
  expect_length(pal(10), 10)
})


test_that("reverse correctly inverts palette", {
  pal_fwd <- thekids_pal('primary', discrete = TRUE, reverse = FALSE)
  pal_rev <- thekids_pal('primary', discrete = TRUE, reverse = TRUE)

  expect_equal(pal_rev(5), rev(pal_fwd(5)))
})


test_that("discrete palette uses fixed set for n <= 6", {
  pal <- thekids_pal('primary', discrete = TRUE)
  cols <- pal(6)

  expected_cols <- unname(thekids_palettes[['primary']][c('MidnightBlue', 'Pumpkin', 'Teal', 'Saffron', 'CelestialBlue', 'CoolGrey')])

  expect_equal(cols, expected_cols)

})


test_that("discrete palette handles n > 6", {
  pal <- thekids_pal('primary', discrete = TRUE)
  cols <- pal(10)

  expect_length(cols, 10)
  expect_equal(cols[1], thekids_colours$midnightblue)  # start colour matches
  expect_equal(cols[10], thekids_colours$pumpkin)  # end colour matches
})


test_that("palette returns hex colours", {
  pal <- thekids_pal('primary')
  cols <- pal(5)

  expect_true(all(grepl("^#", cols)))
})


test_that("palette works with ggplot2 scale", {
  pal <- thekids_pal('primary')

  scale <- ggplot2::scale_fill_gradientn(colours = pal(10))

  expect_s3_class(scale, "ScaleContinuous")
})

