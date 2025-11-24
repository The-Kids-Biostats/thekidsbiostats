# Colour scale constructor for The Kids colours.

Colour scale constructor for The Kids colours.

## Usage

``` r
scale_color_thekids(palette = "primary", discrete = TRUE, reverse = FALSE, ...)

scale_colour_thekids(
  palette = "primary",
  discrete = TRUE,
  reverse = FALSE,
  ...
)
```

## Arguments

- palette:

  Character name of palette in thekids_palettes. Options are "primary",
  "tint50" and "typography"

- discrete:

  Boolean indicating whether color aesthetic is discrete or not

- reverse:

  Boolean indicating whether the palette should be reversed

- ...:

  Additional arguments passed to discrete_scale() or
  scale_color_gradientn(), used respectively when discrete is TRUE or
  FALSE
