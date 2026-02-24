# clean_REDCap.R
# Helper functions to clean imported REDCap data per the REDCap data dictionary
# Cretaed by Paul Stevenson, 2021-05-14

#' factor_table
#'
#' @param x character vector of REDCap options (e.g. 0, No | 1, Yes)
#' @param rows (default "\\|") Regex defining row separator
#' @param cols (default ",") Regex defining column separator
#'
#' @details
#' For a more thorough example, see the [vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/miscellaneous.html).
#'
#' @return 2 column tibble of factor levels ("key") and labels ("value")
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' \dontrun{ factor_table("0, No | 1, Yes") }
#'
#' @export
factor_table <- function(x, rows = "\\|", cols = ",") {

  key <- NULL

  tibble::tibble(key = stringr::str_split(x, rows)[[1]]) %>%
    tidyr::separate(key, into = c("key", "value"), sep = cols, extra = "merge") %>%
    dplyr::mutate(dplyr::across(tidyselect::everything(), ~trimws(.)))

}

#' factor_convert
#'
#' Apply factor labels to categorical responses per REDCap data dictionary.
#'
#' @param x character vector
#' @param d REDCap import
#' @param dict REDCap data dictionary
#'
#' @examples
#' \dontrun{
#'
#' dat <- tibble(var = c("0", "1"))
#'
#' dictionary <- tibble(`Variable / Field Name` = "var",
#'   `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")
#'
#' mutate(dat, across("var", factor_convert, d = dat, dict = dictionary))
#'
#' }
#'
#' @export
factor_convert <- function(x, d, dict) {
  y <- factor_table(dict[dict$`Variable / Field Name` == dplyr::cur_column(),]$`Choices, Calculations, OR Slider Labels`)
  factor(x, levels = y$key, labels = y$value)
}

#' checkbox_labels
#'
#' Apply factor labels to categorical responses (checkboxes) per REDCap data dictionary
#'
#' @param x checkbox `Variable / Field Name` per data dictionary
#' @param dict REDCap data dictionary
#'
#' @return Named list of character objects
#'
#' @examples
#' \dontrun{
#'
#' dat <- tibble(var___0 = c("0", "1"), var___1 = c("1", "0"))
#'
#' dictionary <- tibble(`Variable / Field Name` = "var",
#'   `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")
#'
#' dat <- labelled::set_variable_labels(dat, .labels = checkbox_labels("var", dictionary))
#'
#' }
#'
#' @export
checkbox_labels <- function(x, dict) {

  d <- factor_table(dict[dict$`Variable / Field Name` == x,]$`Choices, Calculations, OR Slider Labels`) %>%
    dplyr::mutate(dplyr::across("key", ~paste(x, ., sep = "___")))

  o <- as.list(d$value)
  names(o) <- d$key

  o
}

#' variable_labels
#'
#' Apply variable labels to a data frame per the REDCap data dictionary. If
#' there is no variable label associated with a column then is lable will be the
#' same as the column's name.
#'
#' @param d REDCap import
#' @param dict REDCap data dictionary
#'
#' @return character vector (length `ncol(d)`) of REDCap Field Labels per the data dictionary
#'
#' @examples
#' \dontrun{
#'
#' dat <- tibble(var = 1)
#'
#' dictionary <- tibble(`Variable / Field Name` = "var", `Field Label` = "Label")
#'
#' dat <- labelled::set_variable_labels(dat, .labels = variable_labels(dat, dictionary))
#'
#' }
#'
#' @export
variable_labels <- function(d, dict) purrr::map_chr(names(d),
                                             ~ifelse(.x %in% dict$`Variable / Field Name`,
                                                     dict[dict$`Variable / Field Name` == .x,]$`Field Label`,
                                                     .x), dict = dict)

# clean_REDCap.R
# Helper functions to clean imported REDCap data per the REDCap data dictionary
# Cretaed by Paul Stevenson, 2021-05-14

#' factor_table
#'
#' @param x character vector of REDCap options (e.g. 0, No | 1, Yes)
#' @param rows (default "\\|") Regex defining row separator
#' @param cols (default ",") Regex defining column separator
#'
#' @return 2 column tibble of factor levels ("key") and labels ("value")
#'
#' @examples
#' \dontrun{ factor_table("0, No | 1, Yes") }
#'
#' @export
factor_table <- function(x, rows = "\\|", cols = ",") {

  key <- NULL

  tibble::tibble(key = stringr::str_split(x, rows)[[1]]) %>%
    tidyr::separate(key, into = c("key", "value"), sep = cols, extra = "merge") %>%
    dplyr::mutate(dplyr::across(tidyselect::everything(), ~trimws(.)))

}

#' factor_convert
#'
#' Apply factor labels to categorical responses per REDCap data dictionary.
#'
#' @param x character vector
#' @param d REDCap import
#' @param dict REDCap data dictionary
#'
#' @examples
#' \dontrun{
#'
#' dat <- tibble(var = c("0", "1"))
#'
#' dictionary <- tibble(`Variable / Field Name` = "var",
#'   `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")
#'
#' mutate(dat, across("var", factor_convert, d = dat, dict = dictionary))
#'
#' }
#'
#' @export
factor_convert <- function(x, d, dict) {
  y <- factor_table(dict[dict$`Variable / Field Name` == dplyr::cur_column(),]$`Choices, Calculations, OR Slider Labels`)
  factor(x, levels = y$key, labels = y$value)
}

#' checkbox_labels
#'
#' Apply factor labels to categorical responses (checkboxes) per REDCap data dictionary
#'
#' @param x checkbox `Variable / Field Name` per data dictionary
#' @param dict REDCap data dictionary
#'
#' @return Named list of character objects
#'
#' @examples
#' \dontrun{
#'
#' dat <- tibble(var___0 = c("0", "1"), var___1 = c("1", "0"))
#'
#' dictionary <- tibble(`Variable / Field Name` = "var",
#'   `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")
#'
#' dat <- labelled::set_variable_labels(dat, .labels = checkbox_labels("var", dictionary))
#'
#' }
#'
#' @export
checkbox_labels <- function(x, dict) {

  d <- factor_table(dict[dict$`Variable / Field Name` == x,]$`Choices, Calculations, OR Slider Labels`) %>%
    dplyr::mutate(dplyr::across("key", ~paste(x, ., sep = "___")))

  o <- as.list(d$value)
  names(o) <- d$key

  o
}

#' variable_labels
#'
#' Apply variable labels to a data frame per the REDCap data dictionary. If
#' there is no variable label associated with a column then is label will be the
#' same as the column's name.
#'
#' @param d REDCap import
#' @param dict REDCap data dictionary
#'
#' @return data frame with variable labels
#'
#' @examples
#' \dontrun{
#'
#' dat <- tibble(var = 1, var2___1 = 1, var2___2 = 0)
#' dictionary <- tibble(`Variable / Field Name` = c("var", "var2"),
#'                      `Field Label` = c("Label for field 'Var'", NA),
#'                      `Field Type` = c(NA, "checkbox"),
#'                      `Choices, Calculations, OR Slider Labels` =
#'                        c(NA, "1, First checkbox label | 2, Second checkbox label"))
#'
#' dat <- variable_labels(dat, dictionary)
#' View(dat)
#'
#' }
#'
#' @export
variable_labels <- function(d, dict) {

  dict <- dict[dict$`Variable / Field Name` %in% stringr::str_replace(names(d), "___\\d+", ""),] # remove items from dictionary that aren't in the dataset

  x <- purrr::map_chr(names(d),
               ~ifelse(.x %in% dict$`Variable / Field Name`,
                       dict[dict$`Variable / Field Name` == .x,]$`Field Label`,
                       .x), dict = dict)

  d <- labelled::set_variable_labels(d, .labels = x)

  # Apply checkbox labels

  for (i in dict[purrr::map_lgl(dict$`Field Type` == "checkbox", isTRUE),]$`Variable / Field Name`) {
    d <- labelled::set_variable_labels(d, .labels = checkbox_labels(i, dict))
  }

  d

}

#' yesno_vars
#'
#' @param d a data frame object
#'
#' @return a character vector of columns that are factors with levels: `c("Yes", "No")`
#'
#' @examples
#'   \dontrun{
#'
#' dat <- tibble(var = factor(c("Yes", "Yes", "No", "Yes"), levels = c("Yes", "No")))
#'
#' yesno_vars(dat)
#'
#' mutate(dat, across(yesno_vars(dat), ~case_when(. == "Yes" ~ TRUE, . == "No" ~ FALSE, TRUE ~ NA)))
#'
#' }
#'
#' @export
yesno_vars <- function(d) {
  o <- purrr::map_lgl({{d}}, function(x) {
    if ( !is.factor(x) )
      return(FALSE)
    if ( length(levels(x)) != 2 )
      return(FALSE)
    if ( all(levels(x) == c("Yes", "No")) )
      return(TRUE)
    FALSE
  })
  names(o[which(o)])

}

#' clean_REDCap
#'
#' Clean a REDCap extract by applying factor levels and convert column classes
#' per the REDCap data dictionary.
#'
#' @param d REDCap (data frame)
#' @param dict REDCap data dictionary (data frame)
#' @param numeric_date (default FALSE) set to TRUE if MS Excel has _helpfully_ converted to a numeric date
#' @param yesno_to_bool (default FALSE) convert factors with levels `c("Yes", "No")` to logical objects?
#' @param quiet (default FALSE) pass quiet argument to lubridate functions
#'
#' @return cleaned data frame
#'
#' @examples
#' \dontrun{
#'
#' dat <- tibble(var = c("0", "1"))
#'
#' dictionary <- tibble(`Variable / Field Name` = "var",
#'   `Field Type` = "radio",
#'   `Field Label` = "Label",
#'   `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes",
#'   `Text Validation Type OR Show Slider Number` = NA)
#'
#' (dat_clean <- clean_REDCap(dat, dictionary))
#'
#' }
#'
#' @export
clean_REDCap <- function(d, dict, numeric_date = FALSE, yesno_to_bool = FALSE, quiet = FALSE) {

  dict <- dict[dict$`Variable / Field Name` %in% stringr::str_replace(names(d), "___\\d+", ""),] # remove items from dictionary that aren't in the dataset

  d <- dplyr::mutate(d,
              dplyr::across(dict[purrr::map_lgl(dict$`Field Type` == "yesno", isTRUE),]$`Variable / Field Name`,
                            ~factor(x = ., levels = c("1", "0"), labels = c("Yes", "No"))),
              dplyr::across(dict[purrr::map_lgl(dict$`Field Type` == "calc", isTRUE),]$`Variable / Field Name`,
                            ~as.numeric(.)),
              dplyr::across(tidyselect::starts_with(paste0(dict[purrr::map_lgl(dict$`Field Type` == "checkbox", isTRUE),]$`Variable / Field Name`, "___")),
                            ~as.logical(as.numeric(.))),
              dplyr::across(dict[purrr::map_lgl(dict$`Field Type` %in% c("dropdown", "radio"), isTRUE),]$`Variable / Field Name`,
                            ~factor_convert(x = ., d = d, dict = dict)),

              dplyr::across(dict[purrr::map_lgl(dict$`Text Validation Type OR Show Slider Number` == "integer", isTRUE),]$`Variable / Field Name`,
                            ~as.integer(.)),
              dplyr::across(dict[grepl("^number((?!comma).)*$", dict$`Text Validation Type OR Show Slider Number`, perl = TRUE),]$`Variable / Field Name`,
                            ~as.numeric(.)), # starts with "number", does not contain "comma"
              dplyr::across(dict[grepl("^number.*comma.*$", dict$`Text Validation Type OR Show Slider Number`),]$`Variable / Field Name`,
                            ~as.numeric(sub(",", ".", .x)))) # starts with "number", does contain "comma"

  if (numeric_date) {
    d <- dplyr::mutate(d, dplyr::across(dict[grepl("^date.*$", dict$`Text Validation Type OR Show Slider Number`, perl = TRUE),]$`Variable / Field Name`,
                                        ~janitor::excel_numeric_to_date(as.numeric(.))))
  } else {
    d <- dplyr::mutate(d,
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^date_ymd"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd(., quiet = quiet)),
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^date_mdy"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd(., quiet = quiet)),
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^date_dmy"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd(., quiet = quiet)),

                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^datetime_ymd"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd_hm(., quiet = quiet)),
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^datetime_mdy"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd_hm(., quiet = quiet)),
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^datetime_dmy"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd_hm(., quiet = quiet)),

                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^datetime_seconds_ymd"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd_hms(., quiet = quiet)),
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^datetime_seconds_mdy"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd_hms(., quiet = quiet)),
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^datetime_seconds_dmy"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ymd_hms(., quiet = quiet)),

                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^time$"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::hm(., quiet = quiet)),
                dplyr::across(dict[purrr::map_lgl(stringr::str_detect(dict$`Text Validation Type OR Show Slider Number`, "^time_mm_ss$"), isTRUE),]$`Variable / Field Name`,
                              ~lubridate::ms(., quiet = quiet)))
  }

  if (yesno_to_bool)
    d <- dplyr::mutate(d, dplyr::across(yesno_vars(d),
                                        ~dplyr::case_when(. == "Yes" ~ TRUE,
                                                          . == "No" ~ FALSE,
                                                          TRUE ~ NA)))

  variable_labels(d, dict)

}
