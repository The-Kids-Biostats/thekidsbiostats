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
#' Currently the function works well with input in the form of data frames, tibbles, dplyr pipes (think `summarise()`), `gtsummary()` output, `kable()` output, and `flextable()` output.
#'
#' Note: Errors may be encountered if the input to the function (kable/gtsummary/flextable) has already received a lot of processing (merging cells, aesthetic changes). The intention is that these things would occur after running `thekids_table()`.
#'
#' @param x a table, typically a data.frame, tibble, or output from gtsummary
#' @param font.size the font size for text in the body of the table, defaults to 8 (passed throught to set_flextable_defaults)
#' @param font.size.header the font size for text in the header of the table, defaults to 10
#' @param line.spacing line spacing for the table, defaults to 1.5 (passed throught to set_flextable_defaults)
#' @param padding padding around all four sides of the text within the cell, defaults to 2.5 (passed throught to set_flextable_defaults)
#' @param colour a colour platte from The Kids branding, options include "Saffron", "Pumpkin", "Teal", "DarkTeal", "CelestialBlue", "AzureBlue", "MidnightBlue", or "CoolGrey", defaults to 'CoolGrey'
#' @param zebra puts and alternating 'colour then white' theming onto the table, based on the selected colouring (defaults to `F`)
#' @param highlight a numeric vector indicating which rows are to receive a colour highlight, based on the selected colouring (defaults to `NULL` giving no highlighted rows)
#' @param ... other parameters passed through to \code{\link[flextable]{set_flextable_defaults}}
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
                          zebra = F,
                          highlight = NULL,
                          ...){


  # Convert kable to tibble early, to facilitate nrow count for highlighting

  if(any(class(x) %in% c("knitr_kable"))) {
    x <- x %>%
      as.character %>%
      rvest::read_html() %>%
      rvest::html_node("table") %>%
      rvest::html_table(fill = TRUE) %>%
      as_tibble
  }

  # Checks for issues

  if(!colour %in% names(thekids_palettes$primary)){
    stop("The colour you have provided is not in the list. Please select from: Saffron, Pumpkin, Teal, DarkTeal, CelestialBlue, AzureBlue, MidnightBlue, or CoolGrey")
  }

  if(zebra == TRUE & !is.null(highlight)){
    stop("You can not opt for zebra (alternating) colour as well as highlight specific rows. Please disable one of the two options.")
  }

  # Determine the number of rows based on the class of x
  n_rows <- if (inherits(x, "tbl_summary")) {
    nrow(as_tibble(x))
  } else if(inherits(x, "flextable")){
    nrow_part(x, part = "header") + nrow_part(x, part = "body") + nrow_part(x, part = "footer")
  } else {
    nrow(x)
  }

  if(!is.null(highlight) && length(highlight) > 0){
    if(max(highlight) > n_rows) {
      stop("You are attempting to highlight at least one row that is not in your table (based on the number of rows in the table). Please recheck your indexing", call. = F)
    }
  }

  # Setting up zebra colouring

  theme_thekids_zebra <- function (x,
                                   odd_header = thekids_palettes$primary[[paste(colour)]],
                                   odd_body = thekids_palettes$tint50[[paste(colour)]],
                                   even_header = "transparent",
                                   even_body = "transparent"){

    if (!inherits(x, "flextable")) {
      stop(sprintf("Function `%s` supports only flextable objects.",
                   "theme_kids_zebra()"))
    }
    h_nrow <- nrow_part(x, "header")
    f_nrow <- nrow_part(x, "footer")
    b_nrow <- nrow_part(x, "body")
    x <- border_remove(x)
    x <- align(x = x, align = "center", part = "header")
    if (h_nrow > 0) {
      even <- seq_len(h_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = odd_header, part = "header")
      x <- bg(x = x, i = even, bg = even_header, part = "header")
      x <- bold(x = x, bold = TRUE, part = "header")
    }
    if (f_nrow > 0) {
      even <- seq_len(f_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = odd_header, part = "footer")
      x <- bg(x = x, i = even, bg = even_header, part = "footer")
      x <- bold(x = x, bold = TRUE, part = "footer")
    }
    if (b_nrow > 0) {
      even <- seq_len(b_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = odd_body, part = "body")
      x <- bg(x = x, i = even, bg = even_body, part = "body")
    }
    x <- align_text_col(x, align = "left", header = TRUE)
    x <- align_nottext_col(x, align = "right", header = TRUE)
    x
  }

  # Setting up highlighting colouring

  theme_thekids_highlight <- function (x,
                                       highlight_header = thekids_palettes$primary[[paste(colour)]],
                                       highlight_body = thekids_palettes$tint50[[paste(colour)]],
                                       other_header = "transparent",
                                       other_body = "transparent"){

    if (!inherits(x, "flextable")) {
      stop(sprintf("Function `%s` supports only flextable objects.",
                   "theme_kids_zebra()"))
    }
    h_nrow <- nrow_part(x, "header")
    f_nrow <- nrow_part(x, "footer")
    b_nrow <- nrow_part(x, "body")
    x <- border_remove(x)
    x <- align(x = x, align = "center", part = "header")
    if (h_nrow > 0) {
      even <- seq_len(h_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = highlight_header, part = "header")
      x <- bg(x = x, i = even, bg = other_header, part = "header")
      x <- bold(x = x, bold = TRUE, part = "header")
    }
    if (f_nrow > 0) {
      even <- seq_len(f_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = highlight_header, part = "footer")
      x <- bg(x = x, i = even, bg = other_header, part = "footer")
      x <- bold(x = x, bold = TRUE, part = "footer")
    }
    if (b_nrow > 0) {
      other <- setdiff(seq_len(b_nrow), highlight)
      x <- bg(x = x, i = highlight, bg = highlight_body, part = "body")
      x <- bg(x = x, i = other, bg = other_body, part = "body")
    }
    x <- align_text_col(x, align = "left", header = TRUE)
    x <- align_nottext_col(x, align = "right", header = TRUE)
    x
  }

  # Setting up non-zebra colouring

  theme_thekids_non_zebra <- function (x,
                                       odd_header = thekids_palettes$primary[[paste(colour)]],
                                       odd_body = "transparent",
                                       even_header = "transparent",
                                       even_body = "transparent"){

    if (!inherits(x, "flextable")) {
      stop(sprintf("Function `%s` supports only flextable objects.",
                   "theme_kids_zebra()"))
    }
    h_nrow <- nrow_part(x, "header")
    f_nrow <- nrow_part(x, "footer")
    b_nrow <- nrow_part(x, "body")
    x <- border_remove(x)
    x <- align(x = x, align = "center", part = "header")
    if (h_nrow > 0) {
      even <- seq_len(h_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = odd_header, part = "header")
      x <- bg(x = x, i = even, bg = even_header, part = "header")
      x <- bold(x = x, bold = TRUE, part = "header")
    }
    if (f_nrow > 0) {
      even <- seq_len(f_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = odd_header, part = "footer")
      x <- bg(x = x, i = even, bg = even_header, part = "footer")
      x <- bold(x = x, bold = TRUE, part = "footer")
    }
    if (b_nrow > 0) {
      even <- seq_len(b_nrow)%%2 == 0
      odd <- !even
      x <- bg(x = x, i = odd, bg = odd_body, part = "body")
      x <- bg(x = x, i = even, bg = even_body, part = "body")
    }
    x <- align_text_col(x, align = "left", header = TRUE)
    x <- align_nottext_col(x, align = "right", header = TRUE)
    x
  }

  # Establishing the flextable defaults to be applied, based on the users choices

  if(zebra == TRUE){
    set_flextable_defaults(
      font.family = "Barlow",
      font.size = font.size,
      theme_fun = theme_thekids_zebra,
      line_spacing = line.spacing,
      padding = padding,
      big.mark = "",
      table.layout = "autofit",
      ...)
  } else if(!is.null(highlight)){
    set_flextable_defaults(
      font.family = "Barlow",
      font.size = font.size,
      theme_fun = theme_thekids_highlight,
      line_spacing = line.spacing,
      padding = padding,
      big.mark = "",
      table.layout = "autofit",
      ...)
  } else {
    set_flextable_defaults(
      font.family = "Barlow",
      font.size = font.size,
      theme_fun = theme_thekids_non_zebra,
      line_spacing = line.spacing,
      padding = padding,
      big.mark = "",
      table.layout = "autofit",
      ...)
  }

  # Generating the output - correcting table class

  if(any(class(x) %in% c("flextable"))){
    table_out <- x
  } else if(any(class(x) %in% c("gtsummary"))){
    table_out <- x %>%
      as_flex_table()
  } else if(any(class(x) %in% c("gt_tbl"))){
    table_out <- x %>%
      data.frame %>%
      flextable
  }
  else {
    table_out <- x %>%
      flextable
  }

  # Generating the output - applying finishing touches

  table_out %>%
    fontsize(part = "header", size = font.size.header) %>%
    color(color = "white", part = "header") %>%
    color(color = "#111921", part = "body") %>%
    hline_top(part = "all") %>%
    hline_bottom() %>%
    autofit()
}

