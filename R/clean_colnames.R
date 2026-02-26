#' Apply a variable dictionary to a dataset. Each column is replaced with a new name and a corresponding label attribute is applied.
#'
#' @param data A data.frame-like object
#' @param dict A data.frame-like object or .csv file path (.csv, .txt, .xlsx, .rds). Should have 3 columns specifying: `old` names, `new` names, and `label`s. The order that columns appear in $old determines the final ordering in the cleaned data.
#' @param old Column name in dict with old column names (default "old")
#' @param new Column name in dict with new column names (default "new")
#' @param label Column name in dict with human-readable labels (default "label")
#' @param reorder Logical, default `FALSE`. If `TRUE`, columns listed in the dictionary will be
#'    reordered according to the order they appear in the dictionary.
#'    Columns not referenced in the dictionary remain at the end in their original order.
#'
#' @return A data.frame with renamed columns and labels applied
#'
#' @examples
#' data("data_patient", package = "thekidsbiostats")
#'
#' # 1) Create a data dictionary and formulate some cleaned column names, assign to `dict` object
#' dict <- make_column_dict(data_patient, auto_clean = TRUE, quiet = FALSE)
#'
#' # 2) Apply column names to data, assign to `data_patient_clean`
#' data_patient_clean <- update_columns(data_patient, dict = dict)
#'
#' @export
update_columns <- function(data, dict, old=NULL, new=NULL, label=NULL, reorder=FALSE) {

  # Check if the data is dataframe-like
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame-like object", call. = FALSE)
  }

  # Check if the dict is dataframe-like
  if (!is.data.frame(dict)) {
    if (is.character(dict) && length(dict) == 1) {
      ext <- tolower(tools::file_ext(dict))

      if (ext %in% c("csv", "txt")) {
        dict <- readr::read_csv(dict, show_col_types = FALSE)
      } else if (ext == "xlsx") {
        dict <- openxlsx::read.xlsx(dict)
      } else if (ext == "rds") {
        dict <- readRDS(dict)
      } else {
        stop("File extension not supported. Provide .csv, .txt, .xls, or .xlsx file", call. = FALSE)
      }

      # Ensure loaded object is data.frame-like
      if (!inherits(dict, "data.frame")) {
        stop("Dictionary loaded from file is not data.frame-like.", call. = FALSE)
      }

    } else {
      stop("`dict` must be a data.frame-like object or a file path", call. = FALSE)
    }
  }


  # Check for supplied dictionary column names, otherwise set default
  old <- if (!is.null(old)) old else "old"
  new <- if (!is.null(new)) new else "new"
  label <- if (!is.null(label)) label else "label"

  if (!all(c(old, new, label) %in% names(dict))) {  # make sure the specified columns are actually present
    stop(
      "dict does not contain all of the required columns: '",
      paste(c(old, new, label), collapse = "', '"),
      "'. Either rename columns of dict or specify each explicitly with `old=...`, `new=...` and `label=...`.",
      call. = FALSE
    )
  }

  # Internally standardise the naming of the dictionary columns
  dict <- dplyr::mutate(
      .data = dict,
      old = .data[[old]],
      new = .data[[new]],
      label = .data[[label]],
      .keep = 'none'
  )

  # Duplicate checks
  if (anyDuplicated(dict$old)) {
    stop("Duplicate `old` entries in dictionary.")
  }

  if (anyDuplicated(dict$new)) {
    stop("Duplicate `new` entries in dictionary")
  }

  # Identify rows that don't need renaming
  needs_renaming <- dict$old %in% names(data) & dict$old != dict$new

  # Rename only those requiring renaming
  rename_map <- stats::setNames(dict$old[needs_renaming], dict$new[needs_renaming])
  data <- data |>
    dplyr::rename(!!!rename_map)  # any_of() skips old column names that don't exist in the data

  # Attach labels
  for (i in seq_len(nrow(dict))) {
    name <- dict$new[i]
    if (name %in% names(data) && !is.na(dict$label[i])) {  # if the column exists in the renamed data and the label is not empty
      attr(data[[name]], "label") <- dict$label[i]
    }
  }

  if (reorder) {
    dict_order <- dict$new[dict$new %in% names(data)]
    other_cols <- setdiff(names(data), dict_order)
    data <- data[, c(dict_order, other_cols), drop = FALSE]
  }

  return(data)
}



#' Create a copy-pasteable variable dictionary template
#'
#' @param data A data.frame or tibble containing the original data with column names to be replaced.
#' @param quiet Logical, default FALSE: suppress printing the generated R code string to the console.
#' @param auto_clean Logical, default TRUE: generate suggested new names using \code{janitor::clean_names()}
#' @param new_names Optional character string, If specified, fills the \code{$new} column with these labels. Length must match the number of columns in \code{data}.
#' @param labels Optional character string. If specified, fills the \code{$label} column with these labels. Length must match the number of columns in \code{data}.
#' @param file Optional character string. If specified, writes dictionary template to file path (available formats: .csv, .txt, .xlsx, .rds, .R)
#' @param ... Additional arguments passed to \code{janitor::clean_names()}
#'
#' @return
#' A data.frame (invisibly returned) with one row per column name in \code{data} and three columns:
#' \describe{
#'   \item{old}{Original column names.}
#'   \item{new}{Suggested new column names (optionally cleaned using
#'     \code{janitor::clean_names()}).}
#'   \item{label}{Empty character field for user-supplied variable labels.}
#' }
#'
#' @details
#' The default behaviour is to print a tribble template to the console. Set \code{quiet=TRUE} to suppress this output.
#' If the file path has the extension .R, this writes the R code in the format of a \code{tribble} to the file.
#'
#' @examples
#' data("data_patient", package = "thekidsbiostats")
#'
#' # Create a data dictionary and formulate some cleaned column names, assign to `dict` object
#' dict <- make_column_dict(data_patient, auto_clean = TRUE, quiet = FALSE)
#'
#'
#' @export
make_column_dict <- function(data, quiet=FALSE, auto_clean=TRUE, new_names=NULL, labels=NULL, file=NULL, ...) {

  # Check if the data is dataframe-like
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame-like object", call. = FALSE)
  }

  suffix <- make.names(substitute(data)) |> # useful for auto-naming the output
    gsub("^(df|dt|dat|data|tbl|tab)[_.]?", "", x = _) |>
    gsub("[_.]?(df|dt|dat|data|tbl|tab)$", "", x = _)

  suffix <- if (suffix == '') make.names(substitute(data)) else suffix

  old_names <- names(data)

  # Check if labels is of correct length, if given, otherwise set to blank
  if (!is.null(labels)) {
    if (is.vector(labels) & length(labels) != ncol(data)) {
       stop("`labels` must be a vector of length equal to the number of columns in `data`.", call. = FALSE)
    }
  } else {
    labels = ""  # set to empty by default
  }

  # Check if new_names is of correct length, if given, otherwise set to blank or clean_names() if auto_clean is TRUE
  if (!is.null(new_names)) {
    if (is.vector(new_names) & length(new_names) != ncol(data)) {
       stop("`new_names` must be a vector of length equal to the number of columns in `data`.", call. = FALSE)
    }
  } else {
    new_names <- if (auto_clean) old_names else rep("", length(old_names))
  }

  if (auto_clean){
    if (!requireNamespace("janitor", quietly = TRUE)) {
      stop("Package 'janitor' to automatically rename columns.", call. = FALSE)
    }

    new_names <- janitor::make_clean_names(new_names, ...)
  }

  dict_columns <- glue::glue(
    '  {old}, {new}, {label},',
    old = encodeString(old_names, quote = '"'),
    new = encodeString(new_names, quote = '"'),  # quotations should not be treated as literal
    label = encodeString(labels, quote = '"')
  ) |> paste( collapse = '\n')

  dict_text <- glue::glue(
    "dict_{suffix} <- tribble(
      ~old, ~new, ~label,
    {dict_columns}
    )"
  )

  dict <- data.frame(
    old = old_names,
    new = new_names,
    label = labels,
    stringsAsFactors = FALSE
  )

  # Optionally save as CSV
  if (!is.null(file)) {

    ext <- tolower(tools::file_ext(file))

    if (ext %in% c("csv", "txt")) {
      utils::write.csv(dict, file = file, row.names = FALSE, )
    } else if (ext %in% c("xls", "xlsx")) {
      if (!requireNamespace("openxlsx", quietly = TRUE)) {
        stop("Package 'openxlsx' is required to write Excel files.", call. = FALSE)
      }
      openxlsx::write.xlsx(dict, file = file)
    } else if (ext == "rds") {
      saveRDS(dict, file = file)
    } else if (tolower(ext) == "r") {
      write_file(dict_text, file = file)
    } else {
      stop("Unsupported file extension. Use .csv, .xls/.xlsx, .rds or .R", call. = FALSE)
    }

    message(sprintf("Successfully saved dictionary to '%s'", normalizePath(file)))
  }

  if (!quiet) cat(dict_text, "\n")

  invisible(dict)
}
