# factor_table

factor_table

factor_table

## Usage

``` r
factor_table(x, rows = "\\|", cols = ",")

factor_table(x, rows = "\\|", cols = ",")
```

## Arguments

- x:

  character vector of REDCap options (e.g. 0, No \| 1, Yes)

- rows:

  (default "\\") Regex defining row separator

- cols:

  (default ",") Regex defining column separator

## Value

2 column tibble of factor levels ("key") and labels ("value")

2 column tibble of factor levels ("key") and labels ("value")

## Details

For a more thorough example, see the
[vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/miscellaneous.html).

## Examples

``` r
if (FALSE)  factor_table("0, No | 1, Yes")  # \dontrun{}

if (FALSE)  factor_table("0, No | 1, Yes")  # \dontrun{}
```
