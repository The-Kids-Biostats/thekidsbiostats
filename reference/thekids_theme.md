# Apply Institute Theming to ggplot2 Plots

This function applies a custom theme to ggplot2 plots, incorporating
specific fonts and colours to align with the institute's visual
identity.

## Usage

``` r
thekids_theme(
  base_size = 11,
  base_family = NULL,
  base_line_size = base_size/22,
  base_rect_size = base_size/22,
  strip_colour = "midnightblue",
  scale_colour_type = lifecycle::deprecated(),
  scale_fill_type = lifecycle::deprecated(),
  colour_theme = lifecycle::deprecated(),
  fill_theme = lifecycle::deprecated(),
  rev_colour = lifecycle::deprecated(),
  rev_fill = lifecycle::deprecated(),
  fig_dpi = 300,
  ...
)

theme_thekids(
  base_size = 11,
  base_family = NULL,
  base_line_size = base_size/22,
  base_rect_size = base_size/22,
  strip_colour = "midnightblue",
  scale_colour_type = lifecycle::deprecated(),
  scale_fill_type = lifecycle::deprecated(),
  colour_theme = lifecycle::deprecated(),
  fill_theme = lifecycle::deprecated(),
  rev_colour = lifecycle::deprecated(),
  rev_fill = lifecycle::deprecated(),
  fig_dpi = 300,
  ...
)
```

## Arguments

- base_size:

  The base font size, given in points. Default is 11.

- base_family:

  The base font family used for the text (default Barlow). Most Google
  Fonts are supported (see Note).

- base_line_size:

  The base size for line elements (e.g., axis lines, grid lines).
  Calculated as `base_size/22` by default.

- base_rect_size:

  The base size for rect elements (e.g., plot background, legend keys).
  Calculated as `base_size/22` by default.

- strip_colour:

  A named colour from the list of The Kids colours, see
  [thekids_colours](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_colours.md)
  for available colour names. Note that only the main colour names are
  accepted because the 50% tint is always used.

- scale_colour_type:

  Deprecated. Use `viridis_pal` instead.

- scale_fill_type:

  Deprecated. Use `viridis_pal` instead.

- colour_theme:

  Deprecated. Use `viridis_pal` instead.

- fill_theme:

  Deprecated. Use `viridis_pal` instead.

- rev_colour:

  Deprecated. Use `viridis_pal` instead.

- rev_fill:

  Deprecated. Use `viridis_pal` instead.

- fig_dpi:

  Base DPI for figure. Only applicable when Barlow font family (default)
  is *not* selected.

- ...:

  Miscellaneous arguments necessary for parameter aliasing, etc.

## Value

A list of ggplot2 theme elements and scale adjustments.

## Details

The function determines the operating system and selects appropriate
font names for Windows or other systems. It applies a minimal theme with
custom settings for plot title, axis title, and strip text, using the
'Barlow Semi Condensed' font family. It also adjusts color scales using
the 'viridis' package.

For a more thorough example, see the
[vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/thekids_theming.html).

## Note

If a Google font has not been loaded with the package, `thekids_theme`
will load this function on your behalf.

Supported Google Fonts are those that exist in
[`sysfonts::font_families_google()`](https://rdrr.io/pkg/sysfonts/man/font_families_google.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# Install the required fonts first (see below)
# Example usage with ggplot2
library(ggplot2)

p <- ggplot(mtcars, aes(x = mpg, y = wt, col = factor(cyl))) +
  geom_point() +
  thekids_theme() +
  scale_colour_thekids()

print(p)

p2 <- ggplot(mtcars, aes(x = factor(cyl), y = wt, fill = factor(cyl))) +
  geom_col() +
  thekids_theme() +
  scale_fill_thekids(palette='tint50', reverse=TRUE)

print(p2)
} # }
if (FALSE) { # \dontrun{
# Install the required fonts first (see below)
# Example usage with ggplot2
library(ggplot2)

p <- ggplot(mtcars, aes(x = mpg, y = wt, col = factor(cyl))) +
  geom_point() +
  theme_thekids() +
  scale_colour_thekids()

print(p)

p2 <- ggplot(mtcars, aes(x = factor(cyl), y = wt, fill = factor(cyl))) +
  geom_col() +
  theme_thekids() +
  scale_fill_thekids(palette='tint50', reverse=TRUE)

print(p2)
} # }
```
