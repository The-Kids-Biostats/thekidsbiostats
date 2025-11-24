# yesno_vars

yesno_vars

## Usage

``` r
yesno_vars(d)
```

## Arguments

- d:

  a data frame object

## Value

a character vector of columns that are factors with levels:
`c("Yes", "No")`

## Examples

``` r
  if (FALSE) { # \dontrun{

dat <- tibble(var = factor(c("Yes", "Yes", "No", "Yes"), levels = c("Yes", "No")))

yesno_vars(dat)

mutate(dat, across(yesno_vars(dat), ~case_when(. == "Yes" ~ TRUE, . == "No" ~ FALSE, TRUE ~ NA)))

} # }
```
