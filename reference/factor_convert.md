# factor_convert

Apply factor labels to categorical responses per REDCap data dictionary.

Apply factor labels to categorical responses per REDCap data dictionary.

## Usage

``` r
factor_convert(x, d, dict)

factor_convert(x, d, dict)
```

## Arguments

- x:

  character vector

- d:

  REDCap import

- dict:

  REDCap data dictionary

## Examples

``` r
if (FALSE) { # \dontrun{

dat <- tibble(var = c("0", "1"))

dictionary <- tibble(`Variable / Field Name` = "var",
  `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")

mutate(dat, across("var", factor_convert, d = dat, dict = dictionary))

} # }

if (FALSE) { # \dontrun{

dat <- tibble(var = c("0", "1"))

dictionary <- tibble(`Variable / Field Name` = "var",
  `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")

mutate(dat, across("var", factor_convert, d = dat, dict = dictionary))

} # }
```
