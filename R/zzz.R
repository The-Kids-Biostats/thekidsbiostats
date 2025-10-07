.onLoad <- function(libname, pkgname) {
  # Vector of packages to attach
  pkgs <- c("tidyverse", "gtsummary", "flextable", "extrafont")

  # Attach packages quietly
  suppressPackageStartupMessages(
    lapply(pkgs, function(p) library(p, character.only = TRUE))
  )

  # Load fonts registered via extrafont
  try(extrafont::loadfonts(quiet = TRUE), silent = TRUE)
}
