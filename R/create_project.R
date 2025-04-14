#' Create a New Project Structure with Extension
#'
#' This function creates a directory structure for a new project based on a specified extension.
#' It can also create additional folders such as `data_raw`, `data`, `admin`, `reports`, and `docs`.
#' The function copies specific files and folders from the chosen extension to the project directory.
#'
#' @param project_name A string. The name of the project to create.
#' @param ext_name A string. The type of project to create. Defaults to `"basic"`. The extension must be available in the package's `ext_proj/_extensions/` directory.
#' @param data_raw Logical. If `TRUE`, a `data_raw` directory will be created in the project. Defaults to `TRUE`.
#' @param data Logical. If `TRUE`, a `data` directory will be created in the project. Defaults to `TRUE`.
#' @param admin Logical. If `TRUE`, an `admin` directory will be created in the project. Defaults to `TRUE`.
#' @param reports Logical. If `TRUE`, a `reports` directory will be created in the project. Defaults to `TRUE`.
#' @param docs Logical. If `TRUE`, a `docs` directory will be created in the project. Defaults to `TRUE`.
#' @param other_folders Vector of strings that contain any other folders that should also be created. Elements should be unique. Default `NULL`.
#'
#' @details
#' This function helps set up the structure of a new project using a predefined extension and
#' optional additional directories. It ensures that the selected extension is valid by checking
#' the available extensions from the `thekidsbiostats` package. After creating the necessary folders,
#' the function copies the appropriate files from the package extension into the project.
#'
#' For a more thorough example, see the \href{../doc/project_workflow.html}{vignette}.
#'
#' @note
#' Ensure that the `thekidsbiostats` package is installed and contains the required extension
#' in `ext_proj/_extensions/`.
#'
#' @examples
#' \dontrun{
#' create_project(ext_name = "basic")
#' create_project(ext_name = "targets", data_raw = FALSE, docs = TRUE)
#' }
#'
#' @export
#'
create_project <- function(project_name,
                           ext_name = "basic",
                           data_raw = T,
                           data = T,
                           admin = T,
                           reports = T,
                           docs = T,
                           other_folders = NULL) {

  if (length(unique(other_folders)) != length(other_folders)){
    stop("The `other_folder` values specified are not unique! Project creation cancelled.")
  }

  base_dir <- rstudioapi::selectDirectory(caption = "Select a location to create the new project folder")
              #tcltk::tk_choose.dir(default = getwd(),
              #                     caption = "Select a location to create the new project folder")

  project_dir <- base_dir

  if (is.na(project_dir) || project_dir == "") {
    stop("Please select a directory. Project creation cancelled.")
  }

  valid_ext <- list.files(system.file("ext_proj/_extensions", package = "thekidsbiostats"))

  # check for available extensions
  stopifnot("Extension not in package" = ext_name %in% valid_ext)

  # add home directory
  dir.create(file.path(project_dir, project_name))

  # add requested directories
  if(data_raw) {
    if(!file.exists(file.path(project_dir, project_name, "data_raw"))) dir.create(file.path(project_dir, project_name, "data_raw"))
  }
  if(data) {
    if(!file.exists(file.path(project_dir, project_name, "data"))) dir.create(file.path(project_dir, project_name, "data"))
  }
  if(admin) {
    if(!file.exists(file.path(project_dir, project_name, "admin"))) dir.create(file.path(project_dir, project_name, "admin"))
  }
  if(reports) {
    if(!file.exists(file.path(project_dir, project_name, "reports"))) dir.create(file.path(project_dir, project_name, "reports"))
  }
  if(docs) {
    if(!file.exists(file.path(project_dir, project_name, "docs"))) dir.create(file.path(project_dir, project_name, "docs"))
  }
  if (!is.null(other_folders)){
    for (i in other_folders){
      if (!file.exists(file.path(project_dir, project_name, i))) dir.create(file.path(project_dir, project_name, i))
    }
  }

  # Create the R Project file in the selected directory
  rproj_file <- file.path(project_dir, project_name, paste0(project_name, ".Rproj"))
  rproj_contents <- c("Version: 1.0") # Required

  writeLines(rproj_contents, rproj_file)

  message("Project structure and RProject file created at: ", paste0(project_dir, "/", project_name))

  # copy specific files and folders from extension
  files <- list.files(system.file(paste0("ext_proj/_extensions/", ext_name), package = "thekidsbiostats"))
  file.copy(
    from = system.file(paste0("ext_proj/_extensions/", ext_name, "/", files), package = "thekidsbiostats"),
    to = file.path(project_dir, project_name),
    overwrite = TRUE,
    recursive = TRUE,
    copy.mode = TRUE
  )
}

#' Create a New Project Structure with Extension (Shiny Compatible)
#'
#' This function creates a directory structure for a new project based on a specified extension.
#' It allows specifying a directory instead of prompting the user.
#'
#' @param path A string. The directory where the project will be created.
#' @param project_name A string. The name of the project to create.
#' @param ext_name A string. The type of project to create. Defaults to `"basic"`.
#' @param data_raw Logical. If `TRUE`, a `data_raw` directory will be created. Defaults to `TRUE`.
#' @param data Logical. If `TRUE`, a `data` directory will be created. Defaults to `TRUE`.
#' @param admin Logical. If `TRUE`, an `admin` directory will be created. Defaults to `TRUE`.
#' @param reports Logical. If `TRUE`, a `reports` directory will be created. Defaults to `TRUE`.
#' @param docs Logical. If `TRUE`, a `docs` directory will be created. Defaults to `TRUE`.
#'
#' @export
create_project_shiny <- function(path,
                                 project_name,
                                 ext_name = "basic",
                                 data_raw = TRUE,
                                 data = TRUE,
                                 admin = TRUE,
                                 reports = TRUE,
                                 docs = TRUE) {
  if (!dir.exists(path)) {
    stop("The specified directory does not exist.")
  }

  project_dir <- file.path(path, project_name)

  if (dir.exists(project_dir)) {
    stop("Project directory already exists. Choose a different name.")
  }

  valid_ext <- list.files(system.file("ext_proj/_extensions", package = "thekidsbiostats"))

  if (!(ext_name %in% valid_ext)) {
    stop("Selected extension is not available in the package.")
  }

  dir.create(project_dir, recursive = TRUE, showWarnings = FALSE)

  sub_dirs <- c("data_raw" = data_raw, "data" = data, "admin" = admin, "reports" = reports, "docs" = docs)

  for (dir_name in names(sub_dirs)) {
    if (sub_dirs[[dir_name]]) {
      dir.create(file.path(project_dir, dir_name), showWarnings = FALSE)
    }
  }

  rproj_file <- file.path(project_dir, paste0(project_name, ".Rproj"))
  writeLines("Version: 1.0", rproj_file)

  message("Project structure and RProject file created at: ", project_dir)

  ext_path <- system.file(paste0("ext_proj/_extensions/", ext_name), package = "thekidsbiostats")
  files <- list.files(ext_path, full.names = TRUE)

  file.copy(from = files, to = project_dir, overwrite = TRUE, recursive = TRUE)

  message("Files copied from extension: ", ext_name)
}


