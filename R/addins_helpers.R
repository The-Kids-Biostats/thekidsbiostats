# Is the current R session running inside the named IDE?
# `ide` is "positron" or "rstudio". Positron is checked first so that a
# Positron session is never mistaken for RStudio.
is_ide <- function(ide = c("positron", "rstudio")) {
  ide <- match.arg(ide)
  if (ide == "rstudio" && is_ide("positron")) return(FALSE)
  env_var <- switch(ide, positron = "POSITRON", rstudio = "RSTUDIO")
  identical(Sys.getenv(env_var), "1")
}

# Prompt the user to choose a folder using the best dialog for the current IDE.
# Returns the chosen path, or NULL if the user cancels.
select_folder <- function(caption = "Select folder", path = getwd()) {
  if (is_ide("rstudio") && rstudioapi::isAvailable()) {
    return(rstudioapi::selectDirectory(caption = caption, path = path))
  }

  # Native OS dialog, used in Positron and other R sessions; `res` is "" on cancel
  selected <- svDialogs::dlg_dir(default = path, title = caption)$res
  if (is.null(selected) || !nzchar(selected)) return(NULL)
  selected
}

# Folder-picker button: native RStudio dialog (plain action button) in RStudio,
# shinyFiles browser elsewhere (e.g. Positron)
folder_button <- function(id, label, title, ...) {
  if (is_ide("rstudio") && rstudioapi::isAvailable()) {
    shiny::actionButton(id, label, ...)
  } else {
    shinyFiles::shinyDirButton(id, label, title, ...)
  }
}

# Server-side counterpart: returns the chosen folder (character(0) if none)
folder_selected <- function(input_value, volumes) {
  if (is_ide("rstudio") && rstudioapi::isAvailable()) {
    sel <- rstudioapi::selectDirectory(caption = "Select folder")
    if (is.null(sel)) character(0) else sel
  } else {
    shinyFiles::parseDirPath(volumes, input_value)
  }
}

# Roots for shinyFiles. shinyFiles::getVolumes() shells out to `wmic` on
# Windows, with fall back set to probing drive letters.
get_volumes <- function() {
  # RStudio uses its native dialog, so the shinyFiles roots are never used
  if (is_ide("rstudio") && rstudioapi::isAvailable()) {
    return(c(Home = fs::path_home()))
  }

  vols <- tryCatch(
    suppressWarnings(shinyFiles::getVolumes()()),
    error = function(e) NULL
  )
  if (is.null(vols) && .Platform$OS.type == "windows") {
    drives <- paste0(LETTERS, ":/")
    drives <- drives[dir.exists(drives)]
    vols <- stats::setNames(drives, sub("/$", "", drives))
  }
  c(Home = fs::path_home(), vols)
}
