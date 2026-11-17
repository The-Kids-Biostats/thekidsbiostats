# Create a copy-pasteable variable dictionary template

Create a copy-pasteable variable dictionary template

## Usage

``` r
make_column_dict(
  data,
  quiet = FALSE,
  auto_clean = TRUE,
  new_names = NULL,
  labels = NULL,
  file = NULL,
  overwrite = FALSE,
  ...
)
```

## Arguments

- data:

  A data.frame or tibble containing the original data with column names
  to be replaced.

- quiet:

  Logical, default FALSE: suppress printing the generated R code string
  to the console.

- auto_clean:

  Logical, default TRUE: generate suggested new names using
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)

- new_names:

  Optional character vector. If specified, fills the `$new` column with
  these names. Length must match the number of columns in `data`.

- labels:

  Optional character vector. If specified, fills the `$label` column
  with these labels. Length must match the number of columns in `data`.
  Set to `"keep"` to copy the original column names into the `$label`
  column.

- file:

  Optional character string. If specified, writes dictionary template to
  file path (available formats: .csv, .txt, .xlsx, .rds, .R)

- overwrite:

  Logical, default FALSE: if `file` already exists, an error is raised
  rather than overwriting it. Set to TRUE to replace an existing file.

- ...:

  Additional arguments passed to
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)

## Value

A data.frame (invisibly returned) with one row per column name in `data`
and three columns:

- old:

  Original column names.

- new:

  Suggested new column names (optionally cleaned using
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)).

- label:

  Empty character field for user-supplied variable labels.

## Details

The default behaviour is to print a tribble template to the console. Set
`quiet=TRUE` to suppress this output. If the file path has the extension
.R, this writes the R code in the format of a `tribble` to the file. To
protect manual edits, the function will not overwrite an existing `file`
unless `overwrite=TRUE`.

## Examples

``` r
data("patients_raw", package = "thekidsbiostats")

# Create a data dictionary and formulate some cleaned column names, assign to `dict` object
dict <- make_column_dict(patients_raw, auto_clean = TRUE, quiet = FALSE)
#> dict_patients_raw <- tribble(
#>   ~old, ~new, ~label,
#>   "Patient ID", "patient_id", "",
#>   "Site Name", "site_name", "",
#>   "trt_grp", "trt_grp", "",
#>   "randomisation date", "randomisation_date", "",
#>   "AGE_yrs", "age_yrs", "",
#>   "Sex", "sex", "",
#>   "Height (cm)", "height_cm", "",
#>   "WEIGHT_kg", "weight_kg", "",
#>   "Do you smoke any form of tabacco product?", "do_you_smoke_any_form_of_tabacco_product", "",
#>   "Diabetes (Y/N)", "diabetes_y_n", "",
#>   "Cholesterol-Total", "cholesterol_total", "",
#>   "eGFR", "e_gfr", "",
#>   "HR_bpm", "hr_bpm", "",
#>   "SBP_baseline_mmHg", "sbp_baseline_mm_hg", "",
#>   "DBP Baseline (mmHg)", "dbp_baseline_mm_hg", "",
#>   "sbp.wk12", "sbp_wk12", "",
#>   "DBP_Week12", "dbp_week12", "",
#> ) 

```
