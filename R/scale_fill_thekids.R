#' @title Fill scale constructor for The Kids colours.
#'
#' @param palette Character Name of palette in thekids_palettes.
#' @param discrete Boolean Indicating whether fill aesthetic is discrete or not
#' @param reverse Boolean Indicating whether the palette should be reversed
#' @param ... Additional arguments passed to discrete_scale() or
#'            scale_fill_gradientn(), used respectively when discrete is TRUE or FALSE
#'
#' @export
scale_fill_thekids <- function(palette = "primary", discrete = TRUE, reverse = FALSE, ...) {

  pal_func <- thekids_pal(palette, discrete, reverse)

  if (discrete) {
    ggplot2::discrete_scale("fill", palette = pal_func, ...)
  } else {
    ggplot2::scale_fill_gradientn(colours = pal_func(256), ...)
  }

}
