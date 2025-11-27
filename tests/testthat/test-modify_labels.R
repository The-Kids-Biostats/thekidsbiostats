library(testthat)

test_that("Correctly returns error if non-flextable object is parsed", {
  dat <- data.frame(x = 1:3, y = letters[1:3])
  expect_error(modify_labels(dat), "Error: the table is not a flextable")
})

test_that("Returns an object of class flextable", {
  dat <- data.frame(x = 1:3, y = letters[1:3])
  ft <- flextable::flextable(dat)

  expect_s3_class(modify_labels(ft), "flextable")
})

test_that("padding arguments are forwarded to flextable internals", {
  df <- data.frame(x = 1:3, y = letters[1:3])
  ft <- flextable(df)

  # Change padding on flextable
  ft1 <- padding(ft,
                 j = 1,
                 padding.left = 20)

  # Change padding using modify_labels
  ft2 <- modify_labels(ft,
                       j = 1,
                       padding.left = 20)

  # Extract padding from fltextable objects
  padding_ft1 <- ft1$body$styles$pars$`padding.left`$data
  padding_ft2 <- ft2$body$styles$pars$`padding.left`$data

  # Check values are equivalent
  expect_equal(padding_ft1, padding_ft2)
})


test_that("label rows are correctly detected via minimal left padding", {
  dat <- data.frame(a = c("A","B","C"), b = 1:3)
  ft <- flextable(dat)

  # modify padding so only row 2 has smallest padding
  ft <- padding(ft, i = 2, j = 1, padding.left = 0)
  ft <- padding(ft, i = c(1,3), j = 1, padding.left = 5)

  out <- modify_labels(ft, label_col = 1, bold = TRUE)

  # extract bold metadata
  is_bold <- out$body$styles$text$bold$data

  expect_true(is_bold[2,1])     # only row 2 should be bold
  expect_false(is_bold[1,1])
  expect_false(is_bold[3,1])
})


test_that("bold, italic, color, highlight, bg, fontsize, font all apply correctly", {
  dat <- data.frame(a = c("A","B"), b = 1:2)
  ft <- flextable(dat)

  # ensure row 1 has smallest padding
  ft <- padding(ft, i = 1, j = 1, padding.left = 0)
  ft <- padding(ft, i = 2, j = 1, padding.left = 5)

  out <- modify_labels(
    ft,
    label_col = 1,
    j = 1,
    bold = TRUE,
    italic = TRUE,
    color = "red",
    highlight = "green",
    bg = "yellow",
    fontsize = 14,
    font = "Times New Roman"
  )

  styles <- out$body$styles

  expect_true(styles$text$bold$data[[1, 1]])
  expect_true(styles$text$italic$data[[1, 1]])
  expect_equal(styles$text$color$data[[1, 1]], "red")
  expect_equal(styles$text$shading.color$data[[1, 1]], "green")
  expect_equal(styles$cells$background.color$data[[1, 1]], "yellow")
  expect_equal(styles$text$font.size$data[[1, 1]], 14)
  expect_equal(styles$text$font.family$data[[1, 1]], "Times New Roman")
})


test_that("hline works with fp_border, character colour, logical TRUE/FALSE", {
  dat <- data.frame(a = c("A","B","C","D","E"), b = 1:5)
  ft <- flextable(dat)

  # row 1 is label
  ft <- padding(ft, i = c(1,4), j = 1, padding.left = 0)
  ft <- padding(ft, i = c(2,3,5), j = 1, padding.left = 10)

  # 1. fp_border directly
  border_obj <- officer::fp_border(color = "blue", width = 2)
  out1 <- modify_labels(ft, hline = border_obj)
  expect_equal(out1$body$styles$cells$border.color.top$data[[4, 1]], "blue")

  # 2. character color
  out2 <- modify_labels(ft, hline = "red")
  expect_equal(out2$body$styles$cells$border.color.top$data[[4, 1]], "red")

  # 3. TRUE = default border
  out3 <- modify_labels(ft, hline = TRUE)
  expect_equal(out3$body$styles$cells$border.color.top$data[[4, 1]], "black")

  # 4. FALSE = transparent
  out4 <- modify_labels(ft, hline = FALSE)
  expect_equal(out4$body$styles$cells$border.color.top$data[[4, 1]], "transparent")
})


test_that("modify_labels() errors for invalid hline types", {
  dat <- data.frame(a = c("A","B","C","D","E"), b = 1:5)
  ft <- flextable(dat)

  invalids <- list(1, 1:3, mtcars)
  lapply(invalids, function(x) {
    expect_error(modify_labels(ft, hline=x), "Invalid 'hline' argument")
  })
})


test_that("border arguments apply correctly", {
  dat <- data.frame(a = c("A","B"), b = 1:2)
  ft <- flextable(dat)

  ft <- padding(ft, i = 1, j = 1, padding.left = 0)
  ft <- padding(ft, i = 2, j = 1, padding.left = 10)

  top <- officer::fp_border(color="red")
  left <- officer::fp_border(color="green")

  out <- modify_labels(ft, border.top = top, border.left = left)

  styles <- out$body$styles$cells

  expect_equal(styles$border.color.top$data[[1, 1]], "red")
  expect_equal(styles$border.color.left$data[[1, 1]], "green")
})


test_that("padding arguments apply correctly", {
  dat <- data.frame(a = c("A","B"), b = 1:2)
  ft <- flextable(dat)

  ft <- padding(ft, i = 1, j = 1, padding.left = 0)
  ft <- padding(ft, i = 2, j = 1, padding.left = 15)

  out <- modify_labels(ft, padding.left = 20)


  expect_equal(out$body$styles$pars$padding.left$data[[1, 1]], 20)
})

test_that("rotation and alignment apply correctly", {
  dat <- data.frame(a = c("A","B"), b = 1:2)
  ft <- flextable(dat)

  ft <- padding(ft, i = 1, j = 1, padding.left = 0)
  ft <- padding(ft, i = 2, j = 1, padding.left = 15)

  out <- modify_labels(ft, rotation = "tbrl", align = "center")

  expect_equal(out$body$styles$cells$text.direction$data[[1, 1]], "tbrl")
  expect_equal(out$body$styles$pars$text.align$data[[1, 1]], "center")
})

test_that("default j = label_col works", {
  dat <- data.frame(a=c("A","B"), b=1:2)
  ft <- flextable(dat)

  ft <- padding(ft, i = 1, j = 1, padding.left = 0)
  ft <- padding(ft, i = 2, j = 1, padding.left = 5)

  out <- modify_labels(ft, bold = TRUE)

  is_bold <- out$body$styles$text$bold$data

  expect_true(is_bold[[1, 1]])     # bold applied to column 1
  expect_false(is_bold[[1, 2]])    # NOT applied to column 2
})


test_that("modify_labels() applies styles to multiple columns in j", {

  # Simple data
  df <- data.frame(
    Group = c("A", "B", "C"),
    Value = 1:3,
    Score = c(10, 20, 30)
  )

  ft <- flextable(df)

  # Manually set padding.left so row 1 is the label row
  # (otherwise flextable defaults are too uniform for testing)
  ft$body$styles$pars$padding.left$data[,] <- 10
  ft$body$styles$pars$padding.left$data[1,] <- 0  # row 1 is the label row

  # columns 1 & 3 will be styled
  out <- modify_labels(
    x = ft,
    j = c("Group", "Score"),
    bold = TRUE,
    color = "blue"
  )

  # Identify label row (row 1)
  label_row <- 1

  # Extract style matrices
  bold_mat   <- out$body$styles$text$bold$data
  color_mat  <- out$body$styles$text$color$data

  # Check bold applied only on columns correctly
  expect_true(bold_mat[[label_row, 1]])
  expect_false(bold_mat[[label_row, 2]]) # Column 2 should remain unchanged
  expect_true(bold_mat[[label_row, 3]])

  # Check colour applied only on columns correctly
  expect_equal(color_mat[[label_row, 1]], "blue")
  expect_false(color_mat[[label_row, 2]] == "blue") # Column 2 should remain unchanged
  expect_equal(color_mat[[label_row, 3]], "blue")
})
