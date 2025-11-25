#' Modify flextable Labels
#'
#' Apply formatting and styling specifically to the label cells of a \code{flextable} object.
#' Label cells are automatically identified as the cells with the smallest left padding
#' in the specified column, which typically correspond to row labels.
#'
#' @param x A \code{flextable} object.
#' @param label_col Numeric or character; the column used to identify label rows.
#'   Label rows are automatically detected as those with the smallest left padding
#'   in this column. Default is 1.
#' @param j Numeric or character; the column(s) to which the styling/formatting should
#'   be applied, which by default is \code{label_col}.
#' @param hline specifies a horizontal line above label cells.
#'   Can be an \code{fp_border} object, a color string (e.g., \code{"red"}), or a logical
#'   value (\code{TRUE} for default border, \code{FALSE} for no line).
#'   Note that \code{j} is ignored for \code{hline}, use \code{border} to apply to specific columns only.
#' @param bold Logical; make label text bold.
#' @param italic Logical; make label text italic.
#' @param color Character; text colour of the label cells.
#' @param bg Character; background colour of the label cells.
#' @param highlight Character; highlight colour for the label cells.
#' @param fontsize Numeric; font size of the label cells.
#' @param font Character; font family name of the label cells.
#' @param rotation Numeric; rotation of label text, can be one of "lrtb", "tbrl", "btlr".
#' @param align Character; text alignment of label (\code{"left"}, \code{"center"}, \code{"right"} or \code{"justify"}).
#' @param border @param border.top @param border.left @param border.bottom @param border.right Optional \code{fp_border} objects
#'   to set cell borders.
#' @param padding @param padding.top @param padding.left @param padding.bottom @param padding.right Optional numeric values
#'   to set cell padding.
#'
#' @return A \code{flextable} object with the specified modifications applied to the label cells.
#'
#' @details
#' This function identifies label cells by finding the rows in column \code{label_col} with the
#' smallest left padding. It then applies any formatting options specified and leaving unchanged those
#' options that were left unspecified.
#'
#' Horizontal lines specified via \code{hline} are applied above the label cells and across the entire table.
#' If \code{hline} is a logical value, \code{TRUE} applies a default border and \code{FALSE} makes it transparent.
#'
#' @examples
#' library(flextable)
#' df <- data.frame(Group = c("A","B","C"), Value = 1:3)
#' ft <- thekids_table(df)  # or flextable(df)
#' ft <- modify_labels(ft, bold = TRUE, hline = "black", fontsize = 12)
#'
#' @export
modify_labels <- function(x, label_col=1, j=NULL, hline=NULL, bold=NULL, italic=NULL, color=NULL, bg=NULL, highlight=NULL,
                          fontsize=NULL, font=NULL, rotation=NULL, align=NULL,
                          border=NULL, border.top=NULL, border.left=NULL, border.bottom=NULL, border.right=NULL,
                          padding=NULL, padding.top=NULL, padding.left=NULL, padding.bottom=NULL, padding.right=NULL) {

  if(!inherits(x, "flextable")) {
    stop("Error: the table is not a flextable object. Please first run `thekids_table()` or `flextable()`.")
  }

  if (is.null(j)) { # If j is not specified, use label_col
    j <- label_col
  }

  paddings <- x$body$styles$pars$padding.left$data  # access the padding.left style
  min_padding <- min(paddings[, label_col], na.rm = TRUE)  # cells with the least padding are probably the labels
  label_rows <- which(paddings[, label_col] == min_padding)

  if (!is.null(hline)) {
    if (inherits(hline, "fp_border")) {
      border_line <- hline
    } else if (is.character(hline)){
      border_line <- officer::fp_border(color=hline)
    } else if (is.logical(hline) && length(hline) == 1) {
      if (isTRUE(hline)){
        border_line <- officer::fp_border()
      } else {
        border_line = officer::fp_border(color = 'transparent')
      }
    } else {
      stop("Invalid 'hline' argument: expected an fp_border() object, a colour character string or a logical value (TRUE/FALSE).")
    }
    x <- flextable::border(x, i=label_rows, j=1:ncol(x$body$dataset), border.top = border_line)
  }

  if (!is.null(bold)) {
    x <- flextable::bold(x, i=label_rows, j=j, bold=bold)
  }

  if (!is.null(italic)) {
    x <- flextable::italic(x, i=label_rows, j=j, italic=italic)
  }

  if (!is.null(color)) {
    x <- flextable::color(x, i=label_rows, j=j, color=color)
  }

  if (!is.null(bg)) {
    x <- flextable::bg(x, i=label_rows, j=j, bg=bg)
  }

  if (!is.null(highlight)) {
    x <- flextable::highlight(x, i=label_rows, j=j, color=highlight)
  }

  if (!is.null(fontsize)) {
    x <- flextable::fontsize(x, i=label_rows, j=j, size=fontsize)
  }

  if (!is.null(font)) {
    x <- flextable::font(x, i=label_rows, j=j, fontname=font)
  }

  if (any(!sapply(list(border, border.top, border.left, border.bottom, border.right), is.null))) {
    x <- flextable::border(x, i=label_rows, j=j,
                            border=border,
                            border.top=border.top,
                            border.bottom=border.bottom,
                            border.left=border.left,
                            border.right=border.right)
  }

  if (any(!sapply(list(padding, padding.top, padding.left, padding.bottom, padding.right), is.null))) {
    x <- flextable::padding(x, i=label_rows, j=j,
                            padding=padding,
                            padding.top=padding.top,
                            padding.bottom=padding.bottom,
                            padding.left=padding.left,
                            padding.right=padding.right)
  }

  if (!is.null(rotation)) {
    x <- flextable::rotate(x, i=label_rows, j=j, rotation=rotation)
  }

  if (!is.null(align)) {
    x <- flextable::align(x, i=label_rows, j=j, align=align)
  }

  return(x)
}
