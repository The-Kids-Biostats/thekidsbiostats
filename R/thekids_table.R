#' The Kids themed table output
#'
#' A function that accepts tabular data, in a range of formats, and outputs an object of class `flextable()` (intended) for display in html and word documents.
#'
#' The purpose of this function is easily coerce many different table structures in a consistent format (look and feel), with The Kids branding applied, that ultimately will look nice in either an html or word output.
#'
#' Default settings produce a relatively compact table, to avoid reports becoming excessively lengthy.
#'
#' The output can be piped (`%>%`) into further `flextable()` functions for advance customisation of the appearance.
#'
#' Currently the function works well with input in the form of data frames, tibbles, dplyr pipes (think `summarise()`), `gtsummary`, and `kable` outputs.
#'
#' @note
#' Errors may be encountered if the input to the function (kable/gtsummary/flextable) has already received a lot of processing (merging cells, aesthetic changes). The intention is that these things would occur after running `thekids_table()`.
#'
#' Font family must be installed at a system level, otherwise the default ("sans") will be applied.
#'
#' Pre-specified formatting applied to 'flextable' objects (ahead of `thekids_table()`) may not carry over as expected. Please consider using `thekids_table() `in place of an explicit `flextable()` call, because our function already coerces the table to a flextable object.
#'
#' @param x a table, typically a data.frame, tibble, or output from gtsummary.
#' @param font.size the font size for text in the body of the table, defaults to 8 (passed throught to set_flextable_defaults).
#' @param font.size.header the font size for text in the header of the table, defaults to 10.
#' @param line.spacing line spacing for the table, defaults to 1.5 (passed through to set_flextable_defaults).
#' @param padding padding around all four sides of the text within the cell, defaults to 2.5 (passed throught to set_flextable_defaults).
#' @param colour a colour palette from The Kids branding, options include "Saffron", "Pumpkin", "Teal", "DarkTeal", "CelestialBlue", "AzureBlue", "MidnightBlue", or "CoolGrey", defaults to 'CoolGrey'.
#' @param zebra controls alternating highlighting of rows, logical or integer (defaults to `F`);
#'  if TRUE, alternate each row's background with `colour`;
#'  if an integer, alternate row blocks of this size are highlighted;
#'  if negative, this will invert the sequence of highlighted blocks;
#'  (defaults to `F`)
#' @param highlight a numeric vector indicating which rows are to receive a colour highlight, based on the selected colouring (defaults to `NULL` giving no highlighted rows).
#' @param font_family string containing the font family to apply to the table. Default "Barlow", otherwise "sans".
#' @param date_fix re-wraps date objects to strictly occupy one line, instead of splitting (defaults to `T`).
#' @param ... other parameters passed through to \code{\link[flextable]{set_flextable_defaults}}.
#'
#' @return a flextable class object that will display in both html and word output
#'
#' @import tidyverse flextable
#'
#' @examples
#'
#' \dontrun{
#'
#' head(mtcars, 10) %>%
#'   thekids_table(colour = "Saffron")
#'
#'
#' mtcars %>%
#'   select(cyl, mpg, hp, wt, gear) %>%
#'   group_by(cyl, gear) %>%
#'   summarise(mean_mpg = mean(mpg),
#'             mean_hp = mean(hp),
#'             mean_wt = mean(wt)) %>%
#'   thekids_table(colour = "CelestialBlue", highlight = c(4:6),
#'                 padding.left = 20, padding.right = 20)

#' }
#'
#' @export
#'

thekids_table <- function(x,
                          font.size = 10,
                          font.size.header = 11,
                          line.spacing = 1.5,
                          padding = 2.5,
                          colour = "CoolGrey",
                          zebra = FALSE,
                          highlight = NULL,
                          font_family = "Barlow",
                          date_fix = TRUE,
                          ...) {


  # Check font family availability
  font_family <- check_font_family(font_family)

  # Standardise argument aliasing
  call <- match.call()
  std_call <- standardise_args(call)
  if (!identical(names(call), names(std_call))) {
    return(eval(std_call, parent.frame()))
  }

  # Check colours are available
  if (!colour %in% names(thekids_palettes$primary)) {
    stop(sprintf("Invalid colour. Choose from: %s",
                 paste(shQuote(names(thekids_palettes$primary)), collapse = ", ")))
  }

  # Check zebra vs highlight
  if (zebra && !is.null(highlight)) {
    stop("Cannot use both zebra striping and highlight rows. Choose one.")
  }

  # Check if x is already class flextable
  if (inherits(x, "flextable")) {
    warning("Object of class 'flextable' detected. Please note that some flextable formatting may not carry over as expected.\n\nPlease consider applying `thekids_table()` in place of `flextable()` call in your workflow.")
  }


  # Save *existing* flextable defaults so they can be restored at the end
  old_defaults <- flextable::get_flextable_defaults()

  # Ensure these existing defaults are reset on any exit
  #on.exit(flextable::init_flextable_defaults(), add = TRUE) ## This works! But resets to package default options on exit
  on.exit(do.call(flextable::set_flextable_defaults, old_defaults),
          add = TRUE)

  # NOW set the flextable defaults
  if (isTRUE(zebra)){
    flextable::set_flextable_defaults(font.family = font_family,
                                      font.size = font.size,
                                      theme_fun = function(y) table_zebra(y, colour = colour),
                                      line_spacing = line.spacing,
                                      padding = padding,
                                      big.mark = "",
                                      table.layout = "autofit",
                                      ...)
  } else if (is.numeric(zebra) && zebra == as.integer(zebra)) {
    if (zebra == 0) {
      stop("zebra must be non-zero.")
    } else {
      pattern = if (zebra > 0) c(FALSE, TRUE) else c(TRUE, FALSE)
      n_rows = get_num_body_rows(x)
      if (abs(zebra) >= n_rows) {
        warning("The 'zebra' value is greater than or equal to the number of body rows; highlighting may not work as intended.")
      }
      highlight = which(rep(rep(pattern, each = abs(zebra)), length.out = n_rows))
    }

    flextable::set_flextable_defaults(font.family = font_family,
                                      font.size = font.size,
                                      theme_fun = function(y) table_highlight(y, colour = colour, highlight = highlight),
                                      line_spacing = line.spacing,
                                      padding = padding,
                                      big.mark = "",
                                      table.layout = "autofit",
                                      ...)
  } else if (!is.null(highlight)){
    flextable::set_flextable_defaults(font.family = font_family,
                                      font.size = font.size,
                                      theme_fun = function(y) table_highlight(y, colour = colour, highlight = highlight),
                                      line_spacing = line.spacing,
                                      padding = padding,
                                      big.mark = "",
                                      table.layout = "autofit",
                                      ...)
  } else {
    flextable::set_flextable_defaults(font.family = font_family,
                                      font.size = font.size,
                                      theme_fun = function(y) table_non_zebra(y, colour = colour),
                                      line_spacing = line.spacing,
                                      padding = padding,
                                      big.mark = "",
                                      table.layout = "autofit",
                                      ...)
  }

  # Coerce x to flextable
  ## amended flextable defaults will be applied within function environment
  table_out <- table_coerce(x,
                            date_fix = date_fix)

  table_out <- table_out %>%
    flextable::fontsize(size = font.size.header, part = "header") %>%
    flextable::color(color = "white", part = "header") %>%
    flextable::color(color = "#111921", part = "body") %>%
    flextable::hline_top(part = "all") %>%
    flextable::hline_bottom() %>%
    flextable::autofit()

  return(table_out)

}
