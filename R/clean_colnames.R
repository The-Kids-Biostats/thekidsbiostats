#' Apply a variable dictionary to a dataset. Each column is replaced with a new name and a corresponding label attribute is applied.
#'
#' @param data A data.frame-like object
#' @param dict A data.frame-like object or .csv file path (.csv, .txt, .xlsx, .rds). Should have 3 columns specifying: `old` names, `new` names, and `label`s.
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
#' data("patients_raw", package = "thekidsbiostats")
#'
#' # 1) Create a data dictionary and formulate some cleaned column names, assign to `dict` object
#' dict <- make_column_dict(patients_raw, auto_clean = TRUE, quiet = FALSE)
#'
#' # 2) Apply column names to data, assign to `patients_clean`
#' patients_clean <- update_columns(patients_raw, dict = dict)
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

  # Identify rows that don't need renaming
  needs_renaming <- dict$old %in% names(data) & dict$old != dict$new

  # Duplicate checks
  old_nonempty <- dict$old[needs_renaming]
  old_nonempty <- old_nonempty[!is.na(old_nonempty) & old_nonempty != ""]

  if (anyDuplicated(old_nonempty)) {
    dup_names <- unique(old_nonempty[duplicated(old_nonempty)])
    warning(
      "Duplicate `old` names in dictionary: '",
      paste(dup_names, collapse = "', '"),
      "'. Only the last entry will be used for new names and labels",
      call. = FALSE
    )
  }

  if (anyDuplicated(dict$new)) {
    stop("Duplicate `new` entries in dictionary")
  }

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



#' Apply labels to existing columns using a dictionary
#'
#' Sets the `label` attribute on columns that already exist in `data`. Unlike
#' [thekidsbiostats::update_columns()], column names are not changed, so this can be used on any
#' data.frame, whether or not it has been renamed beforehand.
#'
#' @param data A data.frame-like object.
#' @param dict A data.frame-like object with at least two columns: one matching
#'    the current column names in `data`, and one with human-readable labels.
#' @param names Column name in `dict` that matches the current column names in
#'    `data` (default `"new"`, which suits data already passed through [thekidsbiostats::update_columns()]).
#' @param label Column name in `dict` with human-readable labels (default `"label"`).
#'
#' @details
#' Columns in `data` that are not listed in `dict` are left unchanged. Dictionary
#' entries that do not match any column in `data` are reported with a warning.
#' Empty labels (`""`) are applied, while `NA` labels are skipped.
#'
#' @return A data.frame with labels applied to the matching columns.
#'
#' @examples
#' dict <- data.frame(
#'   names = c("age", "sex"),
#'   label = c("Age (years)", "Sex"),
#'   stringsAsFactors = FALSE
#' )
#' df <- data.frame(age = c(34, 58), sex = c("F", "M"))
#' df <- relabel_columns(df, dict, names = "names")
#' attr(df$age, "label")
#'
#' @export
relabel_columns <- function(data, dict, names = NULL, label = NULL) {

  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame-like object", call. = FALSE)
  }
  if (!is.data.frame(dict)) {
    stop("`dict` must be a data.frame-like object", call. = FALSE)
  }

  names <- if (!is.null(names)) names else "new"
  label <- if (!is.null(label)) label else "label"

  if (!all(c(names, label) %in% colnames(dict))) {
    stop(
      "dict does not contain all of the required columns: '",
      paste(c(names, label), collapse = "', '"),
      "'. Either rename columns of dict or specify each explicitly with `names=...` and `label=...`.",
      call. = FALSE
    )
  }

  if (anyDuplicated(dict[[names]])) {
    stop("Duplicate entries in dictionary column '", names, "'", call. = FALSE)
  }

  unmatched <- setdiff(stats::na.omit(dict[[names]]), colnames(data))
  if (length(unmatched) > 0) {
    warning(
      "Dictionary entries not found in `data`: '",
      paste(unmatched, collapse = "', '"),
      "'",
      call. = FALSE
    )
  }

  for (i in seq_len(nrow(dict))) {
    col <- dict[[names]][i]
    lab <- dict[[label]][i]
    if (!is.na(col) && col %in% colnames(data) && !is.na(lab)) {
      attr(data[[col]], "label") <- lab
    }
  }

  return(data)
}


#' Create a copy-pasteable variable dictionary template
#'
#' @param data A data.frame or tibble containing the original data with column names to be replaced.
#' @param quiet Logical, default FALSE: suppress printing the generated R code string to the console.
#' @param auto_clean Logical, default TRUE: generate suggested new names using \code{janitor::clean_names()}
#' @param new_names Optional character vector. If specified, fills the \code{$new} column with these names. Length must match the number of columns in \code{data}.
#' @param labels Optional character vector. If specified, fills the \code{$label} column with these labels. Length must match the number of columns in \code{data}. Set to \code{"keep"} to copy the original column names into the \code{$label} column.
#' @param file Optional character string. If specified, writes dictionary template to file path (available formats: .csv, .txt, .xlsx, .rds, .R)
#' @param overwrite Logical, default FALSE: if \code{file} already exists, an error is raised rather than overwriting it. Set to TRUE to replace an existing file.
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
#' To protect manual edits, the function will not overwrite an existing \code{file} unless \code{overwrite=TRUE}.
#'
#' @examples
#' data("patients_raw", package = "thekidsbiostats")
#'
#' # Create a data dictionary and formulate some cleaned column names, assign to `dict` object
#' dict <- make_column_dict(patients_raw, auto_clean = TRUE, quiet = FALSE)
#'
#'
#' @export
make_column_dict <- function(data, quiet=FALSE, auto_clean=TRUE, new_names=NULL, labels=NULL, file=NULL, overwrite=FALSE, ...) {

  # Check if the data is dataframe-like
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame-like object", call. = FALSE)
  }

  # Only derive the object name from a plain variable; piped or inline expressions use plain "dict"
  data_name <- substitute(data)
  suffix <- ""
  if (is.name(data_name) && as.character(data_name) != ".") {
    stripped <- make.names(as.character(data_name)) |> # useful for auto-naming the output
      gsub("^(df|dt|dat|data|tbl|tab)[_.]?", "", x = _) |>
      gsub("[_.]?(df|dt|dat|data|tbl|tab)$", "", x = _)

    suffix <- if (stripped == '') make.names(as.character(data_name)) else stripped
  }
  dict_name <- if (suffix == '') "dict" else paste0("dict_", suffix)

  old_names <- names(data)

  # labels = "keep" copies the original column names into the label column
  if (identical(labels, "keep")) {
    labels <- old_names
  } else if (!is.null(labels)) {
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
    "{dict_name} <- tribble(
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

    if (file.exists(file) && !isTRUE(overwrite)) {
      stop(
        sprintf("File '%s' already exists. Set `overwrite = TRUE` to replace it.", file),
        call. = FALSE
      )
    }

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