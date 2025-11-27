# Mock dataset
mock_dat <- tibble(
  yesno_var = c("1", "0", "1"),
  radio_var = c("0", "1", "1"),
  dropdown_var = c("1", "0", "1"),
  numeric_var = c("3.14", "2.71", "1.61"),
  integer_var = c("1", "2", "3"),
  date_var = c("2025-01-01", "2025-02-02", "2025-03-03"),
  datetime_var = c("2025-01-01 12:00", "2025-02-02 13:30", "2025-03-03 14:45"),
  checkbox_var___1 = c("1","0","0"),
  checkbox_var___2 = c("0","1","0")
)

# Mock dictionary
mock_dict <- tibble(
  `Variable / Field Name` = c("yesno_var","radio_var","dropdown_var","numeric_var","integer_var","date_var","datetime_var","checkbox_var"),
  `Field Type` = c("yesno","radio","dropdown","text","text","text","text","checkbox"),
  `Field Label` = c("Yes/No variable","Radio variable","Dropdown variable","Numeric variable","Integer variable","Date variable","Datetime variable","Checkbox variable"),
  `Choices, Calculations, OR Slider Labels` = c(
    "1, Yes | 0, No",
    "0, No | 1, Yes",
    "0, No | 1, Yes",
    NA, NA, NA, NA,
    "1, First checkbox | 2, Second checkbox"
  ),
  `Text Validation Type OR Show Slider Number` = c(NA, NA, NA, "number", "integer", "date_ymd", "datetime_ymd", NA)
)
