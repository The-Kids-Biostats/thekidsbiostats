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
data("data_patient", package = "thekidsbiostats")

# 1) Create a data dictionary and formulate some cleaned column names, assign to `dict` object
dict <- make_column_dict(data_patient, auto_clean = TRUE, quiet = FALSE)
#> dict_patient <- tribble(
#>   ~old, ~new, ~label,
#>   "Patient ID#", "patient_id_number", "",
#>   "DOB [YYYY-MM-DD]", "dob_yyyy_mm_dd", "",
#>   "Sex (0=Male, 1=Female)", "sex_0_male_1_female", "",
#>   "WHAT IS YOUR HEIGHT? (cm)", "what_is_your_height_cm", "",
#>   "WHAT IS YOUR CURRENT WEIGHT? (kg)", "what_is_your_current_weight_kg", "",
#>   "Do you currently smoke any form of tobacco products, including cigarettes, cigars, or pipes, on a regular basis?", "do_you_currently_smoke_any_form_of_tobacco_products_including_cigarettes_cigars_or_pipes_on_a_regular_basis", "",
#>   "bp (mmHg)", "bp_mm_hg", "",
#>   "Cholesterol / mmolL", "cholesterol_mmol_l", "",
#> ) 

# 2) Apply column names to data, assign to `data_patient_clean`
data_patient_clean <- update_columns(data_patient, dict = dict)
```
