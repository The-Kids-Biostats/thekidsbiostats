#' Create Template for Quarto
#'
#' This function creates a HTML or Word template in the current working directory
#' using a specified Quarto extension. It copies the template files to the
#' `_extensions/` directory and generates a new Quarto markdown (.qmd) file.
#'
#' An interactive screen will appear, asking the user to select where to generate the extension files and report template.
#' If you are working in a project environment (e.g., created by `thekidsbiostats::create_project`), the default working
#' directory will be the "reports" folder. Otherwise, any other folder can be selected.
#'
#' @param file_name A string. The name of the new Quarto markdown (.qmd) file. This must be provided.
#' @param directory A string. The name of the directory to plate the files. Default is "reports" (if this folder exists).
#' @param ext_name A string. The name of the extension to use for the HTML template.
#'        Defaults to "html". "word" is an alternative which used the Word template.
#'
#' @details
#' The function first checks whether a `_extensions/` directory exists in the current working
#' directory. If not, it creates one. It then copies the necessary extension files from the
#' package's internal data to the `_extensions/` directory. Finally, it creates
#' a new Quarto markdown file based on the extension template.
#'
#' For a more thorough example, see the \href{../doc/project_workflow.html}{vignette}.
#'
#' @note
#' The function assumes that the package `thekidsbiostats` contains the necessary extension files
#' under `ext_qmd/_extensions/`.
#'
#' @examples
#' \dontrun{
#' create_template(file_name = "my_report")
#' create_template(file_name = "my_doc", ext_name = "word")
#' }
#'
#' @export

create_template <- function(file_name = NULL,
                            directory = "reports",
                            ext_name = "html") {

  if (is.null(file_name)) {
    stop("You must provide a valid file_name")
  }

  # Check if the "reports" folder exists, otherwise use the current working directory
  default_dir <- ifelse(dir.exists(directory), directory, getwd())

  # Allow user to select a directory, defaulting to the identified default directory
  selected_dir <- rstudioapi::selectDirectory(caption = "Select directory to save the .qmd file",
                                              path = default_dir)

  if (is.null(selected_dir)) {
    stop("No directory selected. Operation aborted.")
  }

  # Update directory based on user selection
  directory <- selected_dir

  valid_ext <- list.files(system.file("ext_qmd/_extensions", package = "thekidsbiostats"))

  # check for available extensions
  stopifnot("Extension not in package" = ext_name %in% valid_ext)

  extfolder <- paste0(directory, "/_extensions")

  # check for existing _extensions directory
  if(!file.exists(extfolder)) dir.create(extfolder)
  message("Created '_extensions' folder")

  # create folder
  if(!file.exists(extfolder)) dir.create(paste0(extfolder, "/", ext_name))

  # copy from internals
  file.copy(
    from = system.file(paste0("ext_qmd/_extensions/", ext_name), package = "thekidsbiostats"),
    to = extfolder,
    overwrite = TRUE,
    recursive = TRUE,
    copy.mode = TRUE
  )

  # logic check to make sure extension files were moved
  n_files <- length(dir(paste0(extfolder, "/", ext_name)))

  if(n_files >= 2){
    message(paste(ext_name, "was installed to _extensions folder in ", directory, "."))
  } else {
    message("Extension appears not to have been created")
  }

  # create new qmd report based on skeleton
  file.copy(paste0(extfolder, "/", ext_name, "/template.qmd"),
            paste0(directory, "/", file_name, ".qmd", collapse = ""))
  # remove qmd template in _extensions
  file.remove(paste0(extfolder, "/", ext_name, "/template.qmd"))
}
