# Generates a function, which when supplied to ggplot2 will return the appropriate colour palette, depending on the number of levels.

Generates a function, which when supplied to ggplot2 will return the
appropriate colour palette, depending on the number of levels.

## Usage

``` r
thekids_pal(palette, discrete = FALSE, reverse = FALSE)
```

## Arguments

- palette:

  Character name of palette in thekids_palettes

- discrete:

  Boolean Indicating whether the palette is discrete or not (i.e.
  sequential or diverging)

- reverse:

  Boolean indicating whether the palette should be reversed

## Value

A palette function based off the thekids_palettes. When called with an
integer `n`, it returns a character vector of `n` hex colour values.
Designed for use with scale_colour_thekids(), scale_fill_thekids() and
other ggplot2 scale functions.
