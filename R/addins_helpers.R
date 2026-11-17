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
