# Apply Institute Theme to ggplot2 Plots

This function applies a custom theme to ggplot2 plots, incorporating
specific fonts and colours to align with the institute's visual
identity.

## Usage

``` r
theme_institute(
  base_size = 11,
  base_family = "Barlow Semi Condensed",
  base_line_size = base_size/22,
  base_rect_size = base_size/22,
  scale_colour_type = "discrete",
  scale_fill_type = "discrete",
  colour_theme = "viridis",
  fill_theme = "viridis",
  rev_colour = F,
  rev_fill = F
)
```

## Arguments

- base_size:

  The base font size, given in points. Default is 11.

- base_family:

  The base font family used for the text. Currently only
  `"Barlow Semi Condensed"` supported.

- base_line_size:

  The base size for line elements (e.g., axis lines, grid lines).
  Calculated as `base_size/22` by default.

- base_rect_size:

  The base size for rect elements (e.g., plot background, legend keys).
  Calculated as `base_size/22` by default.

- scale_colour_type:

  Type of scale used for colours. Should be either `"discrete"` or
  `"continuous"`. Default is `"discrete"`.

- scale_fill_type:

  Type of scale used for fills. Should be either `"discrete"` or
  `"continuous"`. Default is `"discrete"`.

- colour_theme:

  Colour palette to use for colour scales. Must be one of
  `"viridis"`,`"thekids"`,`"thekids_tint"`,`"thekids_grey"`. Default is
  `"viridis"`.

- fill_theme:

  Colour palette to use for fill scales. Must be one of
  `"viridis"`,`"thekids"`,`"thekids_tint"`,`"thekids_grey"`. Default is
  `"viridis"`.

- rev_colour:

  Logical. Should the colour palette be reversed? Default is `FALSE`.

- rev_fill:

  Logical. Should the fill palette be reversed? Default is `FALSE`.

## Value

A list of ggplot2 theme elements and scale adjustments.

## Details

The function determines the operating system and selects appropriate
font names for Windows or other systems. It applies a minimal theme with
custom settings for plot title, axis title, and strip text, using the
'Barlow Semi Condensed' font family. It also adjusts color scales using
the 'viridis' package.

For a more thorough example, see the
[vignette](https://the-kids-biostats.github.io/thekidsbiostats/doc/thekids_theming.md).

## Note

To use this theme, you need to have the 'Barlow Semi Condensed' font
family installed on your system.

## Installing Fonts

To install the 'Barlow Semi Condensed' font family:

1.  **Windows**:

    - Download the fonts from [Google
      Fonts](https://fonts.google.com/specimen/Barlow+Semi+Condensed).
      On Windows, the location is `C:\Windows\Fonts`. (If you can’t move
      fonts there, use
      `C:\\Users\Username\AppData\Local\Microsoft\Windows\Font` to
      install fonts that can only be accessed by your own username.)

    - Install the following font files:

      - `BarlowSemiCondensed-ExtraBold.ttf`

      - `BarlowSemiCondensed-Medium.ttf`

    - Using the extrafont package, run font_import() followed by
      loadfonts(device = "win")

2.  **Mac OS and Linux**:

    - Download the fonts from [Google
      Fonts](https://fonts.google.com/specimen/Barlow+Semi+Condensed).

    - Install the following font files:

      - `BarlowSemiCondensed-Bold.ttf`

      - `BarlowSemiCondensed-Medium.ttf`

## Examples

``` r
if (FALSE) { # \dontrun{
# Install the required fonts first (see below)
# Example usage with ggplot2
library(ggplot2)
library(viridis)

p <- ggplot(mtcars, aes(x = mpg, y = wt, col = factor(cyl))) +
  geom_point() +
  theme_institute()

print(p)

p2 <- gplot(mtcars, aes(x = factor(cyl), y = wt, fill = factor(cyl))) +
  geom_col() +
  theme_institute(fill_theme = "thekids_tint", rev_fill = T)

print(p2)
} # }
```
