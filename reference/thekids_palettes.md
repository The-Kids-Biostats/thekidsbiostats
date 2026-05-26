# The Kids Research Institute Australia Colour Palettes

Colour palettes using colours from The Kids Research Institute
Australia.

## Usage

``` r
thekids_palettes
```

## Format

A nested list of colourmaps Palettes are stored in a nested list of
palette variants, which can be accessed by:
`thekids_palettes$<variant>$<name>`

- **Sequential palettes**: Continuous colour gradients for ordered data
  values

  - `thekids_palettes$sequential$primary`

  - `thekids_palettes$sequential$tint50`

  - `thekids_palettes$sequential$tint10`

  - mono-colour sequential ramps, accessed by
    `thekids_palettes$sequential$...` `saffron`, `pumpkin`, `teal`,
    `celestialblue`, `azureblue`, `midnightblue`, `coolgrey`

  These return palette functions of the form `function(n)` for
  continuous scales.

- **Diverging palettes**: Two-ended colour gradients deviating about a
  central white reference point.

  - `thekids_palettes$diverging$pumpkin2celestial`

  - `thekids_palettes$diverging$saffron2teal`

  - `thekids_palettes$diverging$saffron2midnight`

  These return palette functions of the form `function(n)` for diverging
  scales.

- **Qualitative palettes**: Sets of visually distinct colours for
  nominal (unordered) categories.

  - `thekids_palettes$qualitative$primary` - NOT YET IMPLEMENTED

  - `thekids_palettes$qualitative$tint50` - NOT YET IMPLEMENTED

  - `thekids_palettes$qualitative$tint10` - NOT YET IMPLEMENTED

  These return a named list of colours.

## Source

The Kids Research Institute Australia style guide.

## Details

In addition to the nested lists (sequential, diverging and qualitative),
there are also three separate lists at the base level, namely:
`$primary`, `$tint50`, `$tint10`. These historically contained the list
of The Kids colours (which have now been moved to `thekids_colours`) but
have been left here for backwards compatibility. Future updates of
`thekidsbiostats` package will remove these lists from
`thekids_palettes` object.

## Examples

``` r
thekids_palettes$sequential$primary
#> function (n) 
#> {
#>     x <- ramp(seq.int(0, 1, length.out = n))
#>     if (ncol(x) == 4L) 
#>         rgb(x[, 1L], x[, 2L], x[, 3L], x[, 4L], maxColorValue = 255)
#>     else rgb(x[, 1L], x[, 2L], x[, 3L], maxColorValue = 255)
#> }
#> <bytecode: 0x5581dc40db90>
#> <environment: 0x5581dc3fe450>
thekids_palettes$sequential$midnightblue
#> function (n) 
#> {
#>     x <- ramp(seq.int(0, 1, length.out = n))
#>     if (ncol(x) == 4L) 
#>         rgb(x[, 1L], x[, 2L], x[, 3L], x[, 4L], maxColorValue = 255)
#>     else rgb(x[, 1L], x[, 2L], x[, 3L], maxColorValue = 255)
#> }
#> <bytecode: 0x5581dc4acd58>
#> <environment: 0x5581dc49d308>
thekids_palettes$diverging$saffron2teal
#> function (n) 
#> {
#>     x <- ramp(seq.int(0, 1, length.out = n))
#>     if (ncol(x) == 4L) 
#>         rgb(x[, 1L], x[, 2L], x[, 3L], x[, 4L], maxColorValue = 255)
#>     else rgb(x[, 1L], x[, 2L], x[, 3L], maxColorValue = 255)
#> }
#> <bytecode: 0x5581dc4df8c8>
#> <environment: 0x5581dc4cfe78>
```
