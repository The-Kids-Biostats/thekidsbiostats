#' @title Colour scale constructor for The Kids colours.
#'
#' @param palette Character name of palette in thekids_palettes. Options are "primary", "tint50" and "typography"
#' @param discrete Boolean indicating whether color aesthetic is discrete or not
#' @param reverse Boolean indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_color_gradientn(), used respectively when discrete is TRUE or FALSE
#'
#' @import ggplot2
#'
#' @export
scale_color_thekids <- function(palette = "primary", discrete = NULL, reverse = FALSE, ...) {

  palette_names <- thekids_palettes |> (\(x) keep(x, is.list))() |> map(names) |> unlist()
  if (is.character(palette)){
    if (!palette %in% palette_names) {
      stop(
        sprintf(
          "Palette '%s' not recognised. Please select from: %s",
          palette,
          paste(strwrap(palette_names, width = 60), collapse = ", ")
        ),
        call. = FALSE
      )
    } else {
      pal <- thekids_pal(palette)  # returns a function that accepts parameter `n` as levels.
    }

  } else {
    print('ding')
  }

  discrete_scale(aesthetics = "color", palette = pal, ...)

}


#' @rdname scale_color_thekids
#' @export
scale_colour_thekids <- scale_color_thekids
