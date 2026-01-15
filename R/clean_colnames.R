#' Apply a variable dictionary to a dataset. Each column is replaced with a new name and a corresponding label attribute is applied.
#'
#' @param data A data.frame or tibble
#' @param dict A data.frame or tibble with 3 columns specifying old names, new names, and labels
#' @param old Column name in dict with old column names (default "old_name")
#' @param new Column name in dict with new column names (default "new_name")
#' @param label Column name in dict with human-readable labels (default "label")
#'
#' @return A data.frame with renamed columns and labels applied
#' @export
apply_dictionary <- function(data, dict, old=NULL, new=NULL, label=NULL) {

  # Check if data is a data frame-like object

  # Check for supplied dictionary column names, otherwise set default
  if (is.null(old) && is.null(new) && is.null(label)) {
    old <- "old_name"
    new <- "new_name"
    label <- "label"
  }

  if (!all(c(old, new, label) %in% names(dict))) {  # make sure the specified columns are actually present
    stop(
      "dict does not contain required columns: ",
      paste(c(old, new, label), collapse = ", "),
      ". Either rename dict columns or explicitly specify them with `old`, `new` and `label`.",
      call. = FALSE
    )
  }

  # Internally standardise the naming of the dictionary
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
#' @param filepath Optional character string. If specified, writes a CSV file with the template
#'
#' @return A character string containing a ready-to-paste tribble dictionary template
#' @export
create_dictionary_template <- function(df, auto_clean = TRUE, filepath = NULL) {

  stopifnot(is.data.frame(df))

  suffix <- gsub("^(df|dt|dat|data|tbl|tab)[_.]?", "", make.names(substitute(df)))  # useful for auto-naming the output, but probably a bit presumptuous

  # Suggested new names
  old_names <- names(df)
  new_names <- if (auto_clean) janitor::clean_names(df) |> names() else ''

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
  if (!is.null(filepath)) {
    df_csv <- data.frame(
      old_name = old_names,
      new_name = new_names,
      label = label,
      stringsAsFactors = FALSE
    )
    utils::write.csv(df_csv, file = filepath, row.names = FALSE)
  }

  return(txt)
}
