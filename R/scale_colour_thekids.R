#' @title Colour scale constructor for The Kids colours.
#'
#' @param palette Character Name of palette in thekids_palettes.
#' @param discrete Boolean Indicating whether colour aesthetic is discrete or not
#' @param reverse Boolean Indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_colour_gradientn(), used respectively when discrete is TRUE or FALSE
#'
#' @export
scale_color_thekids <- function(palette = "primary", discrete = TRUE, reverse = FALSE, ...) {

  # TODO: Allow any palette function to be provided
  pal_func <- thekids_pal(palette, discrete, reverse)

  if (discrete) {
    ggplot2::discrete_scale("colour", palette = pal_func, ...)
  } else {
    ggplot2::scale_colour_gradientn(colours = pal_func(256), ...)
  }

}


#' @rdname scale_color_thekids
#' @export
scale_colour_thekids <- scale_color_thekids
