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

  message("📦 Using template extension: ", ext_name)

  # Define source and destination extension folders
  ext_src <- system.file(file.path("ext_qmd/_extensions", ext_name), package = "thekidsbiostats")
  ext_dest <- file.path(directory, "_extensions", ext_name)

  # Copy entire extension directory to the destination
  dir.create(dirname(ext_dest), showWarnings = FALSE, recursive = TRUE)
  if (!dir.exists(ext_dest)) {
    dir.create(ext_dest)
  }

  # Copy all files and subdirectories recursively
  copied <- file.copy(from = list.files(ext_src, full.names = TRUE),
                      to = ext_dest,
                      recursive = TRUE,
                      overwrite = TRUE)

  if (any(!copied)) {
    warning("⚠️ Some extension files could not be copied.")
  } else {
    message("📁 Extension files copied to: ", ext_dest)
  }

  # Set up qmd file
  qmd_file <- file.path(directory, ifelse(endsWith(file_name, ".qmd"), file_name, paste0(file_name, ".qmd")))

  if (file.exists(qmd_file)) {
    warning("⚠️ Report file already exists: ", qmd_file, ". Skipping creation.")
    return(invisible(NULL))
  }

  qmd_lines <- readLines(file.path(system.file(file.path("ext_qmd/_extensions", ext_name), package = "thekidsbiostats"), 'template.qmd'))
  qmd_lines <- update_qmd_template(
    line = qmd_lines,
    title = title,
    subtitle = subtitle,
    author = author,
    affiliation = affiliation,
    include_reproducibility = include_reproducibility
  )

  writeLines(qmd_lines, qmd_file)

  message("📝 Report template created: ", qmd_file)

  if (open_file && rstudioapi::isAvailable()) {
    message("📂 Opening report: ", qmd_file)
    rstudioapi::navigateToFile(qmd_file)
  }

  invisible(qmd_file)
}
