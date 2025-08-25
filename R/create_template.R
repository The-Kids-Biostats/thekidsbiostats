#' Create a Quarto report template
#'
#' Copies extension files into `_extensions/` and creates a `.qmd` report file.
#' Optionally opens the created file. If the file already exists, no overwrite occurs and a warning is shown.
#'
#' @param file_name Name of the report file (without .qmd).
#' @param directory Directory to save the report and extensions in.
#' @param ext_name Name of the template extension (e.g. "html", "word").
#' @param open_file Whether to open the file after creation (default: TRUE).
#' @param title Title of the report.
#' @param subtitle Subtitle of the report.
#' @param author Author name (defaults to `Sys.info()[['user']]`).
#' @param affiliation Affiliation of the author.
#' @param include_reproducibility Whether or not to include a 'Reproducibility Information' section, which outputs the R session information (default: TRUE).
#'
#' @return Invisibly returns path to created .qmd file, or NULL if skipped.
#' @export
create_template <- function(file_name = NULL,
                            directory = "reports",
                            ext_name = "html",
                            title = NULL,
                            subtitle = NULL,
                            author = NULL,
                            affiliation = NULL,
                            include_reproducibility = TRUE,
                            open_file = TRUE) {

  if (!dir.exists(directory)) stop("Directory does not exist.")
  if (is.null(file_name)) stop("You must provide a file_name.")

  valid_ext <- list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats"))
  stopifnot("Extension not in package" = ext_name %in% valid_ext)

  message("\U0001F4E6 Using template extension: ", ext_name)

  extfolder <- file.path(directory, "_extensions")
  dir.create(extfolder, showWarnings = FALSE)
  dir.create(file.path(extfolder, ext_name), showWarnings = FALSE)

  message("\U0001F4C1 _extensions folder created: ", extfolder)

  file.copy(
    from = system.file(file.path("ext_qmd/_extensions", ext_name), package = "thekidsbiostats"),
    to = extfolder,
    overwrite = TRUE,
    recursive = TRUE,
    copy.mode = TRUE
  )
  message("\U0001F4C4 Template extension files copied to: ", file.path(extfolder, ext_name))

  qmd_file <- file.path(directory, ifelse(endsWith(file_name, ".qmd"), file_name, paste0(file_name, ".qmd")))

  if (file.exists(qmd_file)) {
    warning("\u26A0\uFE0F Report file already exists: ", qmd_file, ". Skipping creation.")
    return(invisible(NULL))
  }

  qmd_lines <- readLines(file.path(system.file(file.path("ext_qmd/_extensions", ext_name), package = "thekidsbiostats"), 'template.qmd'))
  qmd_lines <- update_qmd_template(
    lines = qmd_lines,
    title = title,
    subtitle = subtitle,
    author = author,
    affiliation = affiliation,
    include_reproducibility = include_reproducibility
  )

  writeLines(qmd_lines, qmd_file)

  message("\U0001F4DD Report template created: ", qmd_file)

  if (open_file && rstudioapi::isAvailable()) {
    message("\U0001F4C2 Opening report: ", qmd_file)
    rstudioapi::navigateToFile(qmd_file)
  }

  invisible(qmd_file)
}
