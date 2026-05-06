# The Kids themed table output

A function that accepts tabular data, in a range of formats, and outputs
an object of class
[`flextable()`](https://davidgohel.github.io/flextable/reference/flextable.html)
(intended) for display in html and word documents.

## Usage

``` r
thekids_table(
  x,
  fontsize = 10,
  fontsize_header = 11,
  line_spacing = 1.5,
  padding = 2.5,
  colour = "midnightblue",
  highlight = NULL,
  highlight_colour = NULL,
  zebra = FALSE,
  font_family = "Barlow",
  fallback_font_family = "sans",
  date_fix = TRUE,
  ...
)
```

## Arguments

- x:

  a table, typically a data.frame, tibble, or output from gtsummary.

- fontsize:

  the font size for text in the body of the table, defaults to 8 (passed
  through to set_flextable_defaults).

- fontsize_header:

  the font size for text in the header of the table, defaults to 10.

- line_spacing:

  line spacing for the table, defaults to 1.5 (passed through to
  set_flextable_defaults).

- padding:

  padding around all four sides of the text within the cell, defaults to
  2.5 (passed through to set_flextable_defaults).

- colour:

  a named colour, hex code or one of the colours from The Kids palette,
  see
  [thekids_colours](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_colours.md)
  for available colour names.

- highlight:

  A numeric vector indicating which rows to highlight. Defaults to
  `NULL`, meaning no rows are highlighted.

- highlight_colour:

  Colour used when highlighting rows for both `highlight` and `zebra`.
  If `NULL`, a 50% tint of the main `colour` argument is used.

- zebra:

  controls alternating highlighting of rows, logical or integer
  (defaults to `FALSE`); if TRUE, alternate each row's background with
  `colour`; if an integer, alternate row blocks of this size are
  highlighted; if negative, this will invert the sequence of highlighted
  blocks; (defaults to `FALSE`)

- font_family:

  string containing the font family to apply to the table. Default
  "Barlow".

- fallback_font_family:

  fallback font family if `font_family` is does not exist. Default is
  "sans".

- date_fix:

  re-wraps date objects to strictly occupy one line, instead of
  splitting (defaults to `TRUE`).

- ...:

  other parameters passed through to
  [`set_flextable_defaults`](https://davidgohel.github.io/flextable/reference/set_flextable_defaults.html).

## Value

a flextable class object that will display in both html and word output

## Details

The purpose of this function is easily coerce many different table
structures in a consistent format (look and feel), with The Kids
branding applied, that ultimately will look nice in either an html or
word output.

Default settings produce a relatively compact table, to avoid reports
becoming excessively lengthy.

The output can be piped (`%>%`) into further
[`flextable()`](https://davidgohel.github.io/flextable/reference/flextable.html)
functions for advance customisation of the appearance.

Currently the function works well with input in the form of data frames,
tibbles, dplyr pipes (think `summarise()`), `gtsummary`, and `kable`
outputs.

For a more thorough example, see the
[vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/thekids_theming.html).

## Note

Errors may be encountered if the input to the function
(kable/gtsummary/flextable) has already received a lot of processing
(merging cells, aesthetic changes). The intention is that these things
would occur after running `thekids_table()`.

Font family must be installed at a system level, otherwise the default
("sans") will be applied.

Pre-specified formatting applied to 'flextable' objects (ahead of
`thekids_table()`) may not carry over as expected. Please consider using
`thekids_table() `in place of an explicit
[`flextable()`](https://davidgohel.github.io/flextable/reference/flextable.html)
call, because our function already coerces the table to a flextable
object.

## Examples

``` r

if (FALSE) { # \dontrun{

head(mtcars, 10) %>%
  thekids_table(colour = "Saffron")


mtcars %>%
  select(cyl, mpg, hp, wt, gear) %>%
  group_by(cyl, gear) %>%
  summarise(mean_mpg = mean(mpg),
            mean_hp = mean(hp),
            mean_wt = mean(wt)) %>%
  thekids_table(colour = "CelestialBlue", highlight = c(4:6),
                padding.left = 20, padding.right = 20)
} # }
```
