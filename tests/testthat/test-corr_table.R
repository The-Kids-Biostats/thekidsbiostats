library(testthat)

# 1) Output types
test_that("returns output of expected types", {
  out1 <- corr_table(mtcars$mpg,
                     mtcars$hp)
  out2 <- corr_table(mtcars$mpg,
                     mtcars$hp,
                     return_plot = TRUE)

  expect_s3_class(out1, "data.frame")
  expect_type(out2, "list")
  expect_named(out2, c("table", "plot", "test"))
})

test_that("output of expected class when return_plot=TRUE", {
  out <- corr_table(mtcars$mpg,
                    mtcars$hp,
                    return_plot = TRUE)

  expect_s3_class(out$table, "data.frame")
  expect_s3_class(out$plot, "ggplot")
})

test_that("add_smooth=TRUE includes a geom_smooth layer", {
  out <- corr_table(mtcars$mpg,
                    mtcars$hp,
                    return_plot = TRUE,
                    add_smooth = TRUE)

  layer_classes <- vapply(out$plot$layers, function(l) class(l$geom)[1], character(1))
  expect_true("GeomSmooth" %in% layer_classes)
})

test_that("add_smooth=FALSE removes smoother layer", {
  out <- corr_table(mtcars$mpg,
                    mtcars$hp,
                    return_plot = TRUE,
                    add_smooth = FALSE)

  layer_classes <- vapply(out$plot$layers, function(l) class(l$geom)[1], character(1))
  expect_false("GeomSmooth" %in% layer_classes)
})

test_that("x/y axis, default title and subtitle labels are as expected", {
  out <- corr_table(mtcars$mpg,
                    mtcars$hp,
                    return_plot = TRUE,
                    add_smooth = FALSE)

  out_labs <- out$plot$labels

  expect_equal(out_labs$x, "mtcars$mpg")
  expect_equal(out_labs$y, "mtcars$hp")
  expect_equal(out_labs$title, paste0("Pearson correlation between ",
                                      out_labs$x,
                                      " and ",
                                      out_labs$y))
  expect_equal(out_labs$subtitle, paste0("rho = ", out$table$Estimate, ", ",
                                         "p = ", out$table$`p-value`))
})


test_that("test element is htest", {
  out <- corr_table(mtcars$mpg,
                    mtcars$hp,
                    return_plot = TRUE)

  expect_s3_class(out$test, "htest")
})

test_that("custom plot_title is supported", {
  out <- corr_table(mtcars$mpg,
                    mtcars$hp,
                    return_plot = TRUE,
                    plot_title = "Custom Plot Title")

  expect_equal(out$plot$labels$title, "Custom Plot Title")
})

test_that("point_alpha is correctly applied to points", {
  out <- corr_table(mtcars$mpg,
                    mtcars$hp,
                    return_plot = TRUE,
                    point_alpha = 0.2)

  expect_equal(out$plot$layers[[1]]$aes_params$alpha, 0.2)
})

test_that("rounding is correctly applied", {
  actual <- stats::cor.test(mtcars$mpg, mtcars$hp)

  out1 <- corr_table(mtcars$mpg,
                     mtcars$hp)
  out2 <- corr_table(mtcars$mpg,
                     mtcars$hp,
                     round_digits = 6,
                     return_plot = TRUE)

  expect_equal(out1$Estimate, thekidsbiostats::round_vec(actual$estimate, 3))
  expect_equal(out2$table$Estimate, thekidsbiostats::round_vec(actual$estimate, 6))
})

test_that("round_digits affects output numerics", {
  out1 <- corr_table(mtcars$mpg,
                     mtcars$hp,
                     round_digits = 1,
                     return_plot = TRUE)

  out2<- corr_table(mtcars$mpg,
                     mtcars$hp,
                     round_digits = 5,
                     return_plot = TRUE)

  expect_false(identical(out1, out2))
})


# 2) Specification
test_that("works with various formula interfaces", {

  out1 <- corr_table(x = "mpg",
                     y = "hp",
                     data = mtcars)
  out2 <- corr_table(x = mtcars$mpg,
                     y = mtcars$hp)
  out3 <- corr_table(formula = ~ mpg + hp,
                     data = mtcars)

  expect_identical(out1, out2)
  expect_identical(out2, out3)
})

test_that("formula interface errors without data or misspecification", {
  expect_error(
    corr_table(formula = ~ mpg + hp),
    "A data frame must be provided when using a formula"
  )

  expect_error(corr_table(formula = mpg ~ hp,
                          data = mtcars))
})

test_that("errors when no columns or formula provided", {
  expect_error(corr_table(data = mtcars),
               "You must provide either a formula or x and y vectors")
})

test_that("columns must be in data", {
  expect_error(corr_table(x = "not_in_data",
                          y = "hp",
                          data = mtcars),
               "not found in data")
  expect_error(corr_table(x = "mpg",
                          y = "not_in_data",
                          data = mtcars),
               "not found in data")
  expect_error(corr_table(x = "not_in_data",
                          y = "also_not_in_data",
                          data = mtcars),
               "not found in data")
})

test_that("vectors must be of same length", {
  x_vec <- mtcars$mpg
  y_vec <- head(mtcars$hp, -1) # pop last element

  expect_error(corr_table(x = x_vec,
                          y = y_vec),
               "x and y must be of the same length")
})

test_that("supports only pearson, spearman, kendall methods", {
  out1 <- corr_table(x = "mpg",
                     y = "hp",
                     data = mtcars,
                     method = "pearson")
  out2 <- suppressWarnings(corr_table(x = "mpg",
                                      y = "hp",
                                      data = mtcars,
                                      method = "spearman"))
  out3 <- suppressWarnings(corr_table(x = "mpg",
                                      y = "hp",
                                      data = mtcars,
                                      method = "kendall"))

  actual1 <- stats::cor.test(mtcars$mpg, mtcars$hp,
                      method = "pearson")
  actual2 <- suppressWarnings(stats::cor.test(mtcars$mpg, mtcars$hp,
                                       method = "spearman"))
  actual3 <- suppressWarnings(stats::cor.test(mtcars$mpg, mtcars$hp,
                                       method = "kendall"))

  expect_equal(out1$Estimate, thekidsbiostats::round_vec(actual1$estimate, 3))
  expect_equal(out2$Estimate, thekidsbiostats::round_vec(actual2$estimate, 3))
  expect_equal(out2$Estimate, thekidsbiostats::round_vec(actual2$estimate, 3))
  expect_error(corr_table(x = "mpg",
                          y = "hp",
                          data = mtcars,
                          method = "misc_corr"),
               'should be one of "pearson", "spearman", "kendall"')
})


test_that("alternative argument is respected and applied", {
  actual <- stats::cor.test(mtcars$mpg, mtcars$hp,
                            alternative = "greater")

  out <- corr_table(x = mtcars$mpg,
                    y = mtcars$hp,
                    alternative = "greater")

  expect_equal(out$Estimate, thekidsbiostats::round_vec(actual$estimate, 3))
  expect_equal(out$`95% CI`, paste0("(",
                                    thekidsbiostats::round_vec(actual$conf.int[1], 3),
                                    ", ",
                                    thekidsbiostats::round_vec(actual$conf.int[2], 3),
                                    ")"))
})

test_that("confidence interval column is present and accepts alternative arguments", {
  out <- corr_table(x = mtcars$mpg,
                    y = mtcars$hp,
                    conf.level = 0.9)

  expect_true(paste0(100*0.9, "% CI") %in% colnames(out))
})

test_that("... argument honoured within `cor.test`", {
  expect_silent(corr_table(x = mtcars$mpg,
                           y = mtcars$hp,
                           exact = TRUE,
                           continuity = TRUE))
})

