# round_vec

A function, for vectors, to keep trailing zeroes when rounding numbers.

## Usage

``` r
round_vec(x, digits = 2)
```

## Arguments

- x:

  a numeric vector

- digits:

  integer indicating the number of decimal places to be used.

## Value

object of class character"

## Details

For a more thorough example, see the
[vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/data_manipulations.html).

## Examples

``` r
round_vec(mtcars$wt, 2)
#>  [1] "2.62" "2.88" "2.32" "3.21" "3.44" "3.46" "3.57" "3.19" "3.15" "3.44"
#> [11] "3.44" "4.07" "3.73" "3.78" "5.25" "5.42" "5.34" "2.20" "1.61" "1.83"
#> [21] "2.46" "3.52" "3.44" "3.84" "3.85" "1.94" "2.14" "1.51" "3.17" "2.77"
#> [31] "3.57" "2.78"

```
