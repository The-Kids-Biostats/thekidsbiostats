#' @title The Kids Colour Scales for ggplot2
#' @description Scale functions (fill and colour) for \code{\link[ggplot2]{ggplot2}}.

#' @name scale_thekids
NULL # place-holder for naming the documentation 'scale_thekids' topic

#' @param palette Name of the palette in thekids_palettes.
#' @param discrete A boolean indicating whether fill aesthetic is discrete or not.
#' @param reverse A boolean indicating whether the palette should be reversed.
#' @param begin A numeric value between 0 and 1 at which the colour palette should begin.
#' @param end A numeric value between 0 and 1 at which the colour palette should end.
#' @param na.value A colour to use for missing values (Default='coolgrey_50').
#' @param ... Additional arguments passed to \code{discrete_scale()} and
#'            \code{scale_colour_gradientn()}/\code{scale_fill_gradientn()}, used respectively when discrete is TRUE or FALSE
#'
#' @rdname scale_thekids
#' @export
scale_fill_thekids <- function(palette = "primary",
                               discrete = TRUE, 
                               reverse = FALSE,
                               begin=0, 
                               end=1,
                               na.value = thekids_colours$coolgrey_50,
                               ...) {

  pal_func <- thekids_pal(palette, discrete, reverse)

  # Truncate the colour palette function if required
  if (begin != 0 | end != 1) {
    pal_func <- truncate_pal(pal_func, begin, end)
  }

  if (discrete) {
    ggplot2::discrete_scale("fill", palette = pal_func, na.value=na.value, ...)
  } else {
    ggplot2::scale_fill_gradientn(colours = pal_func(256), na.value=na.value, ...)
  }

}

#' @rdname scale_thekids
#' @export
scale_colour_thekids <- function(palette = "primary",
                                discrete = TRUE, 
                                reverse = FALSE,
                                begin=0, 
                                end=1,
                                na.value = thekids_colours$coolgrey_50,
                                ...) {

  pal_func <- thekids_pal(palette, discrete, reverse)

  # Truncate the colour palette function if required
  if (begin != 0 | end != 1) {
    pal_func <- truncate_pal(pal_func, begin, end)
  }

  if (discrete) {
    ggplot2::discrete_scale("colour", palette = pal_func, na.value=na.value, ...)
  } else {
    ggplot2::scale_colour_gradientn(colours = pal_func(256), na.value=na.value, ...)
  }

}

#' @rdname scale_thekids
scale_color_thekids <- scale_colour_thekids
