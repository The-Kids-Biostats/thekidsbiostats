# round_df

A function, for data frames or tibbles, to round all numeric columns in
a data frame or tibble.

## Usage

``` r
round_df(x, digits = 2, con_char = F)
```

## Arguments

- x:

  a data frame or tibble vector

- digits:

  integer indicating the number of decimal places to be used

- con_char:

  logical as to whether you want the rounded columns to be converted to
  character class (T) or not (F); default is F

## Value

object of class tibble"

## Details

The option exists to keep these columns as numeric (simply rounding), or
to convert them to characters keeping trailing zeroes in the process.

## Examples

``` r

if (FALSE) { # \dontrun{
round_df(iris, 0)

round_df(iris, 0, con_char = T) %>% str
} # }
```
