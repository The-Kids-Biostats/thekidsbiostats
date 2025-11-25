library(testthat)
library(lubridate)
library(labelled)

test_that("yesno_var converts correctly", {
  clean <- clean_REDCap(mock_dat, mock_dict, yesno_to_bool = FALSE, quiet = TRUE)

  expect_s3_class(clean$yesno_var, "factor")
  expect_equal(levels(clean$yesno_var), c("Yes", "No"))
  expect_equal(as.character(clean$yesno_var), c("Yes", "No", "Yes"))


  clean2 <- clean_REDCap(mock_dat, mock_dict, yesno_to_bool = TRUE, quiet = TRUE)

  expect_type(as.logical(clean2$yesno_var), "logical")
  expect_equal(as.logical(clean2$yesno_var), c(TRUE,FALSE,TRUE))
})

test_that("radio_var converts to factor with correct labels", {
  clean <- clean_REDCap(mock_dat, mock_dict, yesno_to_bool = FALSE, quiet = TRUE)

  expect_s3_class(clean$radio_var, "factor")
  expect_equal(levels(clean$radio_var), c("No","Yes"))
  expect_equal(as.character(clean$radio_var), c("No","Yes","Yes"))
})

test_that("numeric_var and integer_var convert correctly", {
  clean <- clean_REDCap(mock_dat, mock_dict, yesno_to_bool = FALSE, quiet = TRUE)

  expect_type(clean$numeric_var, "double")
  expect_equal(as.vector(clean$numeric_var), c(3.14, 2.71, 1.61))
  expect_type(clean$integer_var, "integer")
  expect_equal(as.vector(clean$integer_var), c(1L, 2L, 3L))
})

test_that("dates and datetimes convert correctly", {
  clean <- clean_REDCap(mock_dat, mock_dict, quiet = TRUE)

  expect_s3_class(clean$date_var, "Date")
  # remove label for comparison
  attr(clean$date_var, "label") <- NULL
  expect_equal(clean$date_var, ymd(mock_dat$date_var))

  expect_s3_class(clean$datetime_var, "POSIXct")
  # remove label for comparison
  attr(clean$datetime_var, "label") <- NULL
  expect_equal(as.numeric(clean$datetime_var), as.numeric(ymd_hm(mock_dat$datetime_var)))
})

test_that("checkboxes convert to logicals and are labelled correctly", {
  clean <- clean_REDCap(mock_dat, mock_dict, quiet = TRUE)

  expect_type(clean$checkbox_var___1, "logical")
  expect_equal(as.vector(clean$checkbox_var___1), c(TRUE,FALSE,FALSE))

  expect_type(clean$checkbox_var___2, "logical")
  expect_equal(as.vector(clean$checkbox_var___2), c(FALSE,TRUE,FALSE))
})

test_that("variable labels are set correctly", {
  clean <- clean_REDCap(mock_dat, mock_dict, quiet = TRUE)
  labels <- var_label(clean)

  expect_equal(labels$yesno_var, "Yes/No variable")
  expect_equal(labels$radio_var, "Radio variable")
  expect_equal(labels$dropdown_var, "Dropdown variable")
  expect_equal(labels$numeric_var, "Numeric variable")
  expect_equal(labels$integer_var, "Integer variable")
  expect_equal(labels$date_var, "Date variable")
  expect_equal(labels$datetime_var, "Datetime variable")
  expect_equal(labels$checkbox_var___1, "First checkbox")
  expect_equal(labels$checkbox_var___2, "Second checkbox")
})

test_that("yesno_vars() handles factors with != 2 levels and non-factors", {
  df <- tibble(
    yesno_correct = factor(c("Yes", "No", "Yes"), levels = c("Yes", "No")),
    yesno_three = factor(c("Yes", "No", "Maybe"), levels = c("Yes", "No", "Maybe")), # triggers length != 2
    numeric_var = c(1, 0, 1),   # non-factor triggers first if
    char_var = c("Yes", "No", "Yes") # non-factor triggers first if
  )

  result <- yesno_vars(df)

  expect_true("yesno_correct" %in% result)          # should detect correct Yes/No factor
  expect_false("yesno_three" %in% result)          # should NOT detect 3-level factor
  expect_false("numeric_var" %in% result)          # should NOT detect numeric
  expect_false("char_var" %in% result)             # should NOT detect character
})

test_that("numeric_date = TRUE converts Excel numeric dates correctly using mock data", {
  # Add numeric Excel date to mock dataset
  mock_dat2 <- mock_dat
  mock_dat2$excel_date_var <- c(44204, 44235, 44265)  # Excel numeric dates

  # Add corresponding entry to mock dictionary
  mock_dict2 <- bind_rows(
    mock_dict,
    tibble(
      `Variable / Field Name` = "excel_date_var",
      `Field Type` = "text",
      `Field Label` = "Excel Date variable",
      `Choices, Calculations, OR Slider Labels` = NA,
      `Text Validation Type OR Show Slider Number` = "date_ymd"
    )
  )

  clean <- suppressWarnings(clean_REDCap(mock_dat2, mock_dict2, numeric_date = TRUE, quiet = TRUE))

  expect_s3_class(clean$excel_date_var, "Date")

  # remove all attributes before comparison
  actual <- clean$excel_date_var
  expected <- janitor::excel_numeric_to_date(mock_dat2$excel_date_var)
  attributes(actual) <- NULL
  attributes(expected) <- NULL

  expect_equal(actual, expected)
})
