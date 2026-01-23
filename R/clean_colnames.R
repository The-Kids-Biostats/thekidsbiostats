#' Apply a variable dictionary to a dataset. Each column is replaced with a new name and a corresponding label attribute is applied.
#'
#' @param data A data.frame-like object
#' @param dict A data.frame-like object or .csv file path (.csv, .txt, .xlsx, .xls, .rds). Should have 3 columns specifying old names, new names, and labels
#' @param old Column name in dict with old column names (default "old_name")
#' @param new Column name in dict with new column names (default "new_name")
#' @param label Column name in dict with human-readable labels (default "label")
#'
#' @return A data.frame with renamed columns and labels applied
#' @export
update_columns <- function(data, dict, old=NULL, new=NULL, label=NULL) {

  # Check if the data is dataframe-like
  if (!is.data.frame(df)) {
    stop("`df` must be a data.frame-like object", call. = FALSE)
  }

  # Check if the dict is dataframe-like
  if (!is.data.frame(dict)) {
    if (is.character(dict) && length(dict) == 1) {
      ext <- tolower(tools::file_ext(dict))

      if (ext %in% c("csv", "txt")) {
        dict <- readr::read_csv(dict, show_col_types = FALSE)
      } else if (ext %in% c("xls", "xlsx")) {
        dict <- readxl::read_excel(dict)
      } else if (ext == "rds") {
        dict <- readRDS(dict)
      } else {
        stop("File extension not supported. Provide .csv, .txt, .xls, or .xlsx file", call. = FALSE)
      }

      # Ensure loaded object is data.frame-like
      if (!inherits(dict, "data.frame")) {
        stop("Loaded dict is not data.frame-like.", call. = FALSE)
      }

    } else {
      stop("`dict` must be a data.frame-like object or a file path", call. = FALSE)
    }
  }


  # Check for supplied dictionary column names, otherwise set default
  old <- if (!is.null(old)) old else "old_name"
  new <- if (!is.null(new)) new else "new_name"
  label <- if (!is.null(label)) label else "label"

  if (!all(c(old, new, label) %in% names(dict))) {  # make sure the specified columns are actually present
    stop(
      "dict does not contain required columns: ",
      paste(c(old, new, label), collapse = ", "),
      ". Either rename dict columns or specify them explicitly with `old`, `new` and `label`.",
      call. = FALSE
    )
  }

  # Internally standardise the naming of the dictionary columns
  dict <- dplyr::mutate(
      .data = dict,
      old_name = .data[[old]],
      new_name = .data[[new]],
      label = .data[[label]],
      .keep = 'none'
  )

  # Duplicate checks
  if (anyDuplicated(dict$old_name)) {
    stop("Duplicate old_name entries in dictionary.")
  }

  if (anyDuplicated(dict$new_name)) {
    stop("Duplicate new_name entries in dictionary")
  }

  # Identify rows that don't need renaming
  needs_renaming <- !(dict$old_name %in% dict$new_name & dict$old_name %in% names(data))

  # Rename only those requiring renaming
  rename_map <- setNames(dict$old_name[needs_renaming], dict$new_name[needs_renaming])
  data <- data |>
    dplyr::rename(!!!rename_map)  # any_of() skips old column names that don't exist in the data

  # Attach labels
  for (i in seq_len(nrow(dict))) {
    name <- dict$new_name[i]
    if (name %in% names(data) && !is.na(dict$label[i])) {  # if the column exists in the renamed data and the label is not empty
      attr(data[[name]], "label") <- dict$label[i]
    }
  }

  return(data)
}



#' Create a copy-pasteable variable dictionary template
#'
#' @param df A data.frame or tibble
#' @param auto_clean Logical, default TRUE: generate suggested new names using janitor::clean_names()
#' @param file Optional character string. If specified, writes a CSV file with the template
#' @param quiet Logical, default FALSE: suppress printing the generated R code string to the console.
#'
#' @return A character string containing a ready-to-paste tribble dictionary template
#' @export
make_column_dict <- function(df, auto_clean=TRUE, file=NULL, quiet=FALSE) {

  stopifnot(is.data.frame(df))

  suffix <- gsub("^(df|dt|dat|data|tbl|tab)[_.]?", "", make.names(substitute(df)))  # useful for auto-naming the output, but probably a bit presumptuous

  # Suggested new names
  old_names <- names(df)
  if (auto_clean){
    if (!requireNamespace("janitor", quietly = TRUE)) {
      stop("Package 'janitor' to automatically rename columns.", call. = FALSE)
    }
    new_names <- names(janitor::clean_names(df))
  } else {
    new_names = ''
  }

  columns <- glue::glue(
    "  '{old}', '{new}', '',",
    old = old_names,
    new = new_names
  ) |> paste( collapse = '\n')

  txt <- glue::glue(
    "dict_{suffix} <- tribble(
      ~old_name, ~new_name, ~label,
    {columns}
    )"
  )

  # Optionally save as CSV
  if (!is.null(file)) {

    ext <- tolower(tools::file_ext(file))

    dict <- data.frame(
      old_name = old_names,
      new_name = new_names,
      label = "",
      stringsAsFactors = FALSE
    )

    if (ext %in% c("csv", "txt")) {
      utils::write.csv(dict, file = file, row.names = FALSE, )
    } else if (ext %in% c("xls", "xlsx")) {
      if (!requireNamespace("openxlsx", quietly = TRUE)) {
        stop("Package 'openxlsx' is required to write Excel files.", call. = FALSE)
      }
      openxlsx::write.xlsx(dict, file = file)
    } else if (ext == "rds") {
      saveRDS(dict, file = file)
    } else {
      stop("Unsupported file extension. Use .csv, .xls/.xlsx, or .rds", call. = FALSE)
    }
  }

  if (!quiet) cat(txt, "\n")

  invisible(txt)
}
