#' @title Generates a function, which when supplied to ggplot2 will return the appropriate colour palette, depending on the number of levels.
#'
#' @param palette Character name of palette in thekids_palettes
#' @param reverse Boolean indicating whether the palette should be reversed
#'
#' @export
thekids_pal <- function(palette, reverse=FALSE) {

  if (palette %in% c('primary', 'tint50', 'tint10')) {
    function(n) {
      if (n <= 6) {
        pal <- unname(thekids_palettes[[palette]][c('MidnightBlue', 'Saffron', 'Teal', 'Pumpkin', 'CelestialBlue', 'CoolGrey')])
        cols <- pal[seq_len(n)]
      } else {
        pal <-
        cols <- pal(n)
      }

      if (reverse) cols <- rev(cols)
      cols
    }
  } else {
    function(n) {
      pal <- thekids_palettes[[palette]]
      cols <- pal(n)
      if (reverse) cols <- rev(cols)
      cols
    }
  }
}


