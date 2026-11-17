# Apply labels to existing columns using a dictionary

Sets the `label` attribute on columns that already exist in `data`.
Unlike
[`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md),
column names are not changed, so this can be used on any data.frame,
whether or not it has been renamed beforehand.

## Usage

``` r
relabel_columns(data, dict, names = NULL, label = NULL)
```

## Arguments

- data:

  A data.frame-like object.

- dict:

  A data.frame-like object with at least two columns: one matching the
  current column names in `data`, and one with human-readable labels.

- names:

  Column name in `dict` that matches the current column names in `data`
  (default `"new"`, which suits data already passed through
  [`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md)).

- label:

  Column name in `dict` with human-readable labels (default `"label"`).

## Value

A data.frame with labels applied to the matching columns.

## Details

Columns in `data` that are not listed in `dict` are left unchanged.
Dictionary entries that do not match any column in `data` are reported
with a warning. Empty labels (`""`) are applied, while `NA` labels are
skipped.

## Examples

``` r
dict <- data.frame(
  names = c("age", "sex"),
  label = c("Age (years)", "Sex"),
  stringsAsFactors = FALSE
)
df <- data.frame(age = c(34, 58), sex = c("F", "M"))
df <- relabel_columns(df, dict, names = "names")
attr(df$age, "label")
#> [1] "Age (years)"
```
