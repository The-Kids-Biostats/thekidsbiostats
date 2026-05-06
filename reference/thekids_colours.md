# The Kids Research Institute Australia Colours

Colour names and HEX codes consistent with Institute guidelines.

## Usage

``` r
thekids_colours
```

## Format

A named character string. The following colours can be accessed with
three variants (main colours and their 50% or 10% tint variations):

- Saffron: `saffron`, `saffron_50`, `saffron_10`

- Pumpkin: `pumpkin`, `pumpkin_50`, `pumpkin_10`

- Teal: `teal`, `teal_50`, `teal_10`

- Dark teal: `darkteal`, `darkteal_50`, `darkteal_10`

- Celestial blue: `celestialblue`, `celestialblue_50`,
  `celestialblue_10`

- Azure blue: `azureblue`, `azureblue_50`, `azureblue_10`

- Midnight blue: `midnightblue`, `midnightblue_50`, `midnightblue_10`

- Cool grey: `coolgrey`, `coolgrey_50`, `coolgrey_10`

## Source

The Kids Research Institute Australia style guide.

## Examples

``` r
names(thekids_colours)
#>  [1] "saffron"          "pumpkin"          "teal"             "darkteal"        
#>  [5] "celestialblue"    "azureblue"        "midnightblue"     "coolgrey"        
#>  [9] "saffron_50"       "pumpkin_50"       "teal_50"          "darkteal_50"     
#> [13] "celestialblue_50" "azureblue_50"     "midnightblue_50"  "coolgrey_50"     
#> [17] "saffron_10"       "pumpkin_10"       "teal_10"          "darkteal_10"     
#> [21] "celestialblue_10" "azureblue_10"     "midnightblue_10"  "coolgrey_10"     
thekids_colours$teal
#> [1] "#00A39C"
thekids_colours$saffron_50
#> [1] "#F8DA9A"
```
