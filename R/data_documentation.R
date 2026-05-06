#' The Kids Research Institute Australia Colours
#'
#' Colour names and HEX codes consistent with Institute guidelines.
#'
#' @format A named character string.
#' The following colours can be accessed with three variants (main colours and their 50% or 10% tint variations):
#' - Saffron: `saffron`, `saffron_50`, `saffron_10`
#' - Pumpkin: `pumpkin`, `pumpkin_50`, `pumpkin_10`
#' - Teal: `teal`, `teal_50`, `teal_10`
#' - Dark teal: `darkteal`, `darkteal_50`, `darkteal_10`
#' - Celestial blue: `celestialblue`, `celestialblue_50`, `celestialblue_10`
#' - Azure blue: `azureblue`, `azureblue_50`, `azureblue_10`
#' - Midnight blue: `midnightblue`, `midnightblue_50`, `midnightblue_10`
#' - Cool grey: `coolgrey`, `coolgrey_50`, `coolgrey_10`
#'
#' @examples
#' names(thekids_colours)
#' thekids_colours$teal
#' thekids_colours$saffron_50
#'
#' @source The Kids Research Institute Australia style guide.
"thekids_colours"


#' The Kids Research Institute Australia Colour Palettes
#'
#' Colour palettes using colours from The Kids Research Institute Australia.
#'
#' @format A nested list of colourmaps
#' Palettes are stored in a nested list of palette variants, 
#' which can be accessed by: `thekids_palettes$<variant>$<name>`
#' 
#' - **Sequential palettes**: Continuous colour gradients for ordered data values
#'   - `thekids_palettes$sequential$primary`
#'   - `thekids_palettes$sequential$tint50`
#'   - `thekids_palettes$sequential$tint10`
#'   - mono-colour sequential ramps, accessed by `thekids_palettes$sequential$...`
#'     `saffron`, `pumpkin`, `teal`,
#'     `celestialblue`, `azureblue`, `midnightblue`, `coolgrey`
#' 
#'   These return palette functions of the form `function(n)` for continuous scales.
#'
#' - **Diverging palettes**: Two-ended colour gradients deviating about a central white reference point.
#'   - `thekids_palettes$diverging$pumpkin2celestial`
#'   - `thekids_palettes$diverging$saffron2teal`
#'   - `thekids_palettes$diverging$saffron2midnight`
#' 
#'   These return palette functions of the form `function(n)` for diverging scales.
#' 
#' - **Qualitative palettes**: Sets of visually distinct colours for nominal (unordered) categories.
#'   - `thekids_palettes$qualitative$primary` - NOT YET IMPLEMENTED
#'   - `thekids_palettes$qualitative$tint50` - NOT YET IMPLEMENTED
#'   - `thekids_palettes$qualitative$tint10` - NOT YET IMPLEMENTED
#' 
#'   These return a named list of colours.
#'
#' @details
#' In addition to the nested lists (sequential, diverging and qualitative), there are also
#' three separate lists at the base level, namely: `$primary`, `$tint50`, `$tint10`. These historically
#' contained the list of The Kids colours (which have now been moved to `thekids_colours`)
#' but have been left here for backwards compatibility. Future updates of `thekidsbiostats` package
#' will remove these lists from `thekids_palettes` object.
#' 
#' @examples
#' thekids_palettes$sequential$primary
#' thekids_palettes$sequential$midnightblue
#' thekids_palettes$diverging$saffron2teal
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
"layout_params"

#' Example of a (fictional) uncleaned data set for analysis
#'
#' Includes variables that represent common patient information,
#' with column names that would generally be problematic in an analytical setting
#' without some form of cleaning.
#'
#' @format data.frame
"data_patient"
