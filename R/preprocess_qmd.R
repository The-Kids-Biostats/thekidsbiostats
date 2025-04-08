#' Preprocess font changes to Quarto (.qmd) HTML reports
#'
#' This function "pre-processes" a .qmd file to use different (Google) fonts, without having to locally download and install the font files.
#'
#' @param file_path File path to the .qmd file to update.
#' @param base_family Font base family to consider. Defaults to the global option when loading `thekidsbiostats`. Otherwise, any Google font family can be specified (must be in `sysfonts::font_families_google()`).
#' @param update_global_option Update the global option for `thekidsbiostats.font` based on the new font family specified. Default TRUE.
#'
#' @return Updates the YAML header of the input .qmd file (formatted per `thekidsbiostats` template) with the specified font `base_family`.
#'
#' @note Works only for HTML report types that have `mainfont` and `include-in-header` arguments in the YAML header as specified in the `thekidsbiostats` HTML template. The template can be created using \link[thekidsbiostats:create_template]{thekidsbiostats::create_template}.
#'
#' @examples
#' \dontrun{
#' preprocess_qmd(file_path = "path_to_qmd", base_family = "Monsieur La Doulaise")
#' }
#'
#' @export

preprocess_qmd <- function(file_path, base_family = getOption("thekidsbiostats.font", "Barlow"), update_global_option = T) {

  # If requested, update the global option
  if (update_global_option){
    options(thekidsbiostats.font = base_family)
  }

  # Register the font using sysfonts
  sysfonts::font_add_google(name = base_family, family = base_family)
  showtext::showtext_auto()

  google_fonts_link <- paste0("https://fonts.googleapis.com/css2?family=", gsub(" ", "+", base_family), "&display=swap")

  content <- readLines(file_path)
  content <- gsub("mainfont: .*", paste0("mainfont: '", base_family, "'"), content)
  content <- gsub("@import url\\('.*'\\);", paste0("@import url('", google_fonts_link, "');"), content)

  writeLines(content, file_path)
}
