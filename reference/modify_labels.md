# Modify flextable Labels

Apply formatting and styling specifically to the label cells of a
`flextable` object. Label cells are automatically identified as the
cells with the smallest left padding in the specified column, which
typically correspond to row labels.

## Usage

``` r
modify_labels(
  x,
  label_col = 1,
  j = NULL,
  hline = NULL,
  bold = NULL,
  italic = NULL,
  color = NULL,
  bg = NULL,
  highlight = NULL,
  fontsize = NULL,
  font = NULL,
  rotation = NULL,
  align = NULL,
  border = NULL,
  border.top = NULL,
  border.left = NULL,
  border.bottom = NULL,
  border.right = NULL,
  padding = NULL,
  padding.top = NULL,
  padding.left = NULL,
  padding.bottom = NULL,
  padding.right = NULL
)
```

## Arguments

- x:

  A `flextable` object.

- label_col:

  Numeric or character; the column used to identify label rows. Label
  rows are automatically detected as those with the smallest left
  padding in this column. Default is 1.

- j:

  Numeric or character; the column(s) to which the styling/formatting
  should be applied, which by default is `label_col`.

- hline:

  specifies a horizontal line above label cells. Can be an `fp_border`
  object, a color string (e.g., `"red"`), or a logical value (`TRUE` for
  default border, `FALSE` for no line). Note that `j` is ignored for
  `hline`, use `border` to apply to specific columns only.

- bold:

  Logical; make label text bold.

- italic:

  Logical; make label text italic.

- color:

  Character; text colour of the label cells.

- bg:

  Character; background colour of the label cells.

- highlight:

  Character; highlight colour for the label cells.

- fontsize:

  Numeric; font size of the label cells.

- font:

  Character; font family name of the label cells.

- rotation:

  Numeric; rotation of label text, can be one of "lrtb", "tbrl", "btlr".

- align:

  Character; text alignment of label (`"left"`, `"center"`, `"right"` or
  `"justify"`).

- border, border.top, border.left, border.bottom, border.right:

  Optional `fp_border` objects to set cell borders.

- padding, padding.top, padding.left, padding.bottom, padding.right:

  Optional numeric values to set cell padding.

## Value

A `flextable` object with the specified modifications applied to the
label cells.

## Details

This function identifies label cells by finding the rows in column
`label_col` with the smallest left padding. It then applies any
formatting options specified and leaving unchanged those options that
were left unspecified.

Horizontal lines specified via `hline` are applied above the label cells
and across the entire table. If `hline` is a logical value, `TRUE`
applies a default border and `FALSE` makes it transparent.

## Examples

``` r
library(flextable)
df <- data.frame(Group = c("A","B","C"), Value = 1:3)
ft <- thekids_table(df)  # or flextable(df)
#> Warning: Font 'Barlow' not found; falling back to 'sans'.
ft <- modify_labels(ft, bold = TRUE, hline = "black", fontsize = 12)
```
