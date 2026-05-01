#' @title Generates a function, which when supplied to ggplot2 will return the appropriate colour palette, depending on the number of levels.
#'
#' @param palette Character name of palette in thekids_palettes
#' @param discrete Boolean Indicating whether the palette is discrete or not (i.e. sequential or diverging)
#' @param reverse Boolean indicating whether the palette should be reversed
#'
#' @return 
#' A palette function based off the thekids_palettes. When called with an integer `n`, 
#' it returns a character vector of `n` hex colour values. Designed for use with
#' scale_colour_thekids(), scale_fill_thekids() and other ggplot2 scale functions.
#' 
#' @export
thekids_pal <- function(palette, discrete = FALSE, reverse = FALSE) {

  if (palette == 'thekids') {
    palette = 'primary'
  }

  palette_names <- thekids_palettes |> (\(x) purrr::keep(x, is.list))() |> purrr::map(names) |> unlist()
  if (!palette %in% palette_names) {
    stop(sprintf(
          "Palette '%s' not recognised. Please select from: %s",
          palette, paste(strwrap(palette_names, width = 60), collapse = ", ")
          ), call. = FALSE)
  }

  if (palette %in% c('primary', 'tint50', 'tint10')) {
    if (discrete) { 
      function(n) {  # These could be moved to thekids_palette$qualitative$...
        if (n <= 6) {
          pal <- unname(thekids_palettes[[palette]][c('MidnightBlue', 'Pumpkin', 'Teal', 'Saffron', 'CelestialBlue', 'CoolGrey')])
          cols <- pal[seq_len(n)]
        } else { 
          # TODO: one-time 24hr warning for using different sequential options if 7 < n < 15.
          pal <- thekids_palettes$sequential[[palette]]
          cols <- pal(n)
        }

        if (reverse) cols <- rev(cols)
        cols
      }
    } else {
      if (reverse){
        function(n) {
          pal <- thekids_palettes$sequential[[palette]]
          rev(pal(n))
        }
      } else {
        function(n) {
          pal <- thekids_palettes$sequential[[palette]]
          pal(n)
        }
      }
    }
  } else {  # sequential or diverging
    if (reverse) {
      function(n) {
        pal <- c(
          thekids_palettes$diverging[[palette]], 
          thekids_palettes$sequential[[palette]]
        )[[1]]
        rev(pal(n))
      }
    } else {
      function(n) {
        pal <- c(
          thekids_palettes$diverging[[palette]], 
          thekids_palettes$sequential[[palette]]
        )[[1]]
        pal(n)
      }
    }
  }
}


#' Allows a begin and end fraction to be imposed on an already created colourRampPalette function
#'
#' Internal function for modifying a palette's begin and end points
#'
#' @param pal_func The palette function generated from colourRampPalette
#' @param begin Numeric The hue between [0,1] at which the colour map should begin.
#' @param end Numeric The hue between [0,1] at which the colour map should end.
#' @param n_interp Number of points to interpolate between the original palette
#' @return Modified palette function truncated between the new begin and end points.
#' @noRd
truncate_pal <- function(pal_func, begin = 0, end = 1, n_interp = 256) {
  
  if (!is.numeric(begin) || length(begin) != 1 || is.na(begin)) {
    stop("`begin` must be a single numeric value")
  }

  if (!is.numeric(end) || length(end) != 1 || is.na(end)) {
    stop("`end` must be a single numeric value")
  }

  if (begin < 0 || begin > 1) {
    stop("`begin` must be between 0 and 1")
  }

  if (end < 0 || end > 1) {
    stop("`end` must be between 0 and 1")
  }

  if (begin >= end) {
    stop("`begin` must be less than `end`")
  }
  
  force(pal_func)  # lock in this exact palette for the returned function.
  
  function(n) {
    cols <- pal_func(n_interp)
    
    i_begin <- floor(begin * (n_interp - 1)) + 1
    i_end   <- ceiling(end * (n_interp - 1)) + 1
    
    cols_sub <- cols[i_begin:i_end]
    
    colorRampPalette(cols_sub)(n)
  }
}
