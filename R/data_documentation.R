#' The Kids Research Institute Australia Colours
#'
#' Colour names and HEX codes consistent with Institute guidelines.
#'
#' @format A named character vector of length 15.
#' Names correspond to semantic colour names (e.g., "Saffron", "Teal", "CoolGrey50").
#'
#' @examples
#' names(thekids_colours)
#' thekids_colours["Teal"]
#'
#' @source The Kids Research Institute Australia style guide.
"thekids_colours"


#' The Kids Research Institute Australia Colour Palettes
#'
#' Additional colour palettes and HEX codes consistent with Institute guidelines.
#'
#' Contains "primary" and "tinted" colours.
#'
#' @format A list of length 4.
#' Names correspond to "primary", "tint50", "tint10", and "typography" guidelines
#'
#' @examples
#' names(thekids_palettes)
#' thekids_palettes$primary["Saffron"]
#'
#' @source The Kids Research Institute Australia style guide.
"thekids_palettes"

#' Image Size Parameters for Save Function
#'
#' Size parameters (mm) for a standard A4 page with "quarter", "half portrait",
#' "half landscape", #' "full portrait", "full landscape". Identifiers for "pdf"
#' and "png" devices included.
#'
#' @format data.frame
"save_params"
