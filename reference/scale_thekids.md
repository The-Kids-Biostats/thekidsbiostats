# The Kids Colour Scales for ggplot2

Scale functions (fill and colour) for
[`ggplot2`](https://ggplot2.tidyverse.org/reference/ggplot2-package.html).

## Usage

``` r
scale_fill_thekids(
  palette = "primary",
  discrete = TRUE,
  reverse = FALSE,
  begin = 0,
  end = 1,
  na.value = thekids_colours$coolgrey_50,
  ...
)

scale_colour_thekids(
  palette = "primary",
  discrete = TRUE,
  reverse = FALSE,
  begin = 0,
  end = 1,
  na.value = thekids_colours$coolgrey_50,
  ...
)

scale_color_thekids(
  palette = "primary",
  discrete = TRUE,
  reverse = FALSE,
  begin = 0,
  end = 1,
  na.value = thekids_colours$coolgrey_50,
  ...
)
```

## Arguments

- palette:

  Name of the palette in thekids_palettes.

- discrete:

  A boolean indicating whether fill aesthetic is discrete or not.

- reverse:

  A boolean indicating whether the palette should be reversed.

- begin:

  A numeric value between 0 and 1 at which the colour palette should
  begin.

- end:

  A numeric value between 0 and 1 at which the colour palette should
  end.

- na.value:

  A colour to use for missing values (Default='coolgrey_50').

- ...:

  Additional arguments passed to `discrete_scale()` and
  `scale_colour_gradientn()`/`scale_fill_gradientn()`, used respectively
  when discrete is TRUE or FALSE
