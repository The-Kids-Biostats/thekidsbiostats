# fct_case_when

Essentially the same as dplyr::case_when but the variable is of class
factor, ordered based on the order entered into the case_when statement

## Usage

``` r
fct_case_when(..., message = T)
```

## Arguments

- ...:

  as per dplyr::case_when, essentially all input is passed through to
  dplyr::case_when

  A sequence of two-sided formulas. The left hand side (LHS) determines
  which values match this case. The right hand side (RHS) provides the
  replacement value.

  The LHS must evaluate to a logical vector. The RHS does not need to be
  logical, but all RHS must evaluate to the same type of vector.

  Both LHS and RHS may have the same length of either 1 or n. The value
  of n must be consistent across all cases. The case of n == 0 is
  treated as a variant of n != 1.

  NULL inputs are ignored.

- message:

  prints the resulting factor levels. This is TRUE by default as output
  may often not be as expected

## Value

A vector of length 1 or n, of class factor, matching the length of the
logical input or output vectors. Inconsistent lengths or types will
generate an error.

## Details

For a more thorough example, see the
[vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/data_manipulations.html).

## Examples

``` r
if (FALSE) { # \dontrun{

  x <- 1:50
  case_when(
    x %% 35 == 0 ~ "fizz buzz",
    x %% 5 == 0 ~ "fizz",
    x %% 7 == 0 ~ "buzz",
    TRUE ~ "no fizz buzz"
  ) %>% table

  fct_case_when(
    message = F,
    x %% 35 == 0 ~ "fizz buzz",
    x %% 5 == 0 ~ "fizz",
    x %% 7 == 0 ~ "buzz",
    TRUE ~ "no fizz buzz"
  ) %>% table

} # }
```
