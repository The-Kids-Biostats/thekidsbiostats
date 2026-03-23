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


