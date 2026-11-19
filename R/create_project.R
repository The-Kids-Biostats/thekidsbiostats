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
#' @param init_git Whether to run `git init` in the project folder and write a `.gitignore` suited to the current IDE.
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
                           init_git = FALSE,
                           open_project = TRUE,
                           ...) {
  if (missing(project_name) || project_name == "") stop("You must provide a project_name.")

  if (is.null(path)) {
    if (!interactive()) stop("Please provide a path when not running interactively.")
    path <- select_folder("Select parent folder for new project")
    if (is.null(path)) stop("No directory selected.")
  }

  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
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
    message("\U2699\UFE0F '", basename(rproj_file), "' created")
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

  if (init_git) init_git_repo(proj_dir)

  message("\U00002705 Project setup complete!")
  invisible(proj_dir)
}


# Path to hand to rstudioapi::openProject(): Positron opens folders (opening
# the .Rproj file only opens that single file), RStudio opens the .Rproj file.
project_open_path <- function(rproj_file) {
  if (is_ide("positron")) dirname(rproj_file) else rproj_file
}

# .gitignore entries shared by R projects, plus IDE-specific files
gitignore_lines <- function() {
  common <- c(".Rhistory", ".RData", ".Ruserdata")
  if (is_ide("rstudio")) return(c(common, ".Rproj.user/"))
  if (is_ide("positron")) return(c(common, ".positron/", ".vscode/"))
  common
}

# Write a .gitignore and run `git init` in proj_dir. Returns TRUE on success.
init_git_repo <- function(proj_dir) {
  proj_dir <- normalizePath(proj_dir, winslash = "/", mustWork = TRUE)
  git <- Sys.which("git")
  if (!nzchar(git)) {
    warning("\U26A0 git was not found on the PATH; skipping git initialisation.", call. = FALSE)
    return(invisible(FALSE))
  }

  writeLines(gitignore_lines(), file.path(proj_dir, ".gitignore"))

  out <- system2(git, c("-C", shQuote(proj_dir), "init"), stdout = TRUE, stderr = TRUE)
  status <- attr(out, "status")
  if (!is.null(status) && status != 0L) {
    warning("\U274C git init failed: ", paste(out, collapse = "\n"), call. = FALSE)
    return(invisible(FALSE))
  }

  message("\U0001F500 Git repository initialised")
  invisible(TRUE)
}
