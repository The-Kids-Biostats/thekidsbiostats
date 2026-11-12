#' Create a new project structure
#'
#' Creates a new project folder with subfolders, an RProj file, and optional Quarto report.
#' Can optionally open the project in a new session and close the current one.
#'
#' @param path Parent directory for the project. If NULL, prompts the user.
#' @param project_name Name of the new project folder.
#' @param folders Character vector of subfolders to create.
#' @param ext_name Name of the report extension for `create_template()`.
#' @param create_report Whether to create a report using `create_template()`.
#' @param create_rproj Whether to include a .Rproj file.
#' @param open_project Whether to open the new project in a new session. In RStudio the .Rproj file is opened; in Positron the project folder is opened.
#' @param ... Additional arguments passed to `create_template()`.
#'
#' @return Invisibly returns the project path.
#' @export
create_project <- function(project_name,
                           path = NULL,
                           folders = c("data-raw", "data", "admin", "docs", "reports", "scripts"),
                           ext_name = "html",
                           create_report = FALSE,
                           create_rproj = TRUE,
                           open_project = TRUE,
                           ...) {
  if (missing(project_name) || project_name == "") stop("You must provide a project_name.")

  if (is.null(path)) {
    if (!interactive()) stop("Please provide a path when not running interactively.")
    path <- choose_directory("Select parent folder for new project")
    if (is.null(path)) stop("No directory selected.")
  }

  proj_dir <- file.path(path, project_name)
  dir.create(proj_dir, recursive = TRUE, showWarnings = FALSE)
  message("\U0001F4C1 Project directory created: ", proj_dir)

  for (folder in folders) {
    subdir <- file.path(proj_dir, folder)
    dir.create(subdir, showWarnings = FALSE)
    message("\U0001F4C2 Folder created: ", folder)
  }

  rproj_file <- file.path(proj_dir, paste0(project_name, ".Rproj"))
  if (create_rproj) {
    writeLines("Version: 1.0", con = rproj_file)
    message("\U0001F4C4 .Rproj file created: ", basename(rproj_file))
  }

  qmd_file <- NULL
  if (create_report) {
    report_dir <- file.path(proj_dir, "reports")
    if (!dir.exists(report_dir)) {
      dir.create(report_dir)
      message("\U0001F4C2 Report folder created: reports/")
    }
    qmd_file <- create_template(
      directory = report_dir,
      ext_name = ext_name,
      open_file = FALSE,
      ...
    )
  }

  if (open_project && file.exists(rproj_file) && rstudioapi::isAvailable()) {
    message("\U0001F680 Opening project in new session...")
    rstudioapi::openProject(path = project_open_path(rproj_file), newSession = TRUE)

    if (!is.null(qmd_file) && file.exists(qmd_file)) {
      options(thekidsbiostats.qmd_to_open = normalizePath(qmd_file))
    }
  }

  message("\U00002705 Project setup complete!")
  invisible(proj_dir)
}


# Is the current session running inside Positron?
is_positron <- function() {
  identical(Sys.getenv("POSITRON"), "1")
}

# Path to hand to rstudioapi::openProject(): Positron opens folders (opening
# the .Rproj file only opens that single file), RStudio opens the .Rproj file.
project_open_path <- function(rproj_file) {
  if (is_positron()) dirname(rproj_file) else rproj_file
}
