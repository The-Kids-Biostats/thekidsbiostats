# Apply a variable dictionary to a dataset. Each column is replaced with a new name and a corresponding label attribute is applied.

Apply a variable dictionary to a dataset. Each column is replaced with a
new name and a corresponding label attribute is applied.

## Usage

``` r
update_columns(
  data,
  dict,
  old = NULL,
  new = NULL,
  label = NULL,
  reorder = FALSE
)
```

## Arguments

- data:

  A data.frame-like object

- dict:

  A data.frame-like object or .csv file path (.csv, .txt, .xlsx, .rds).
  Should have 3 columns specifying: `old` names, `new` names, and
  `label`s.

- old:

  Column name in dict with old column names (default "old")

- new:

  Column name in dict with new column names (default "new")

- label:

  Column name in dict with human-readable labels (default "label")

- reorder:

  Logical, default `FALSE`. If `TRUE`, columns listed in the dictionary
  will be reordered according to the order they appear in the
  dictionary. Columns not referenced in the dictionary remain at the end
  in their original order.

## Value

A data.frame with renamed columns and labels applied

## Examples

``` r
data("patients_raw", package = "thekidsbiostats")

# 1) Create a data dictionary and formulate some cleaned column names, assign to `dict` object
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

# 2) Apply column names to data, assign to `patients_clean`
patients_clean <- update_columns(patients_raw, dict = dict)
```
