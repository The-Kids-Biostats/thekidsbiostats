# Cleaning Columns

## Overview

Datasets rarely come with cleaned, tidy formatting in their column names
and hence it is common practice to rename the original column names to
those that are more code-friendly (i.e. lower-case, no spaces or special
characters and unique). Alongside the code-friendly renamed columns,
it’s also very practical to store `label` attributes, which act as a
human-readable version of each column that can be used for displaying in
tables and figures. Whilst there already exists functions for renaming
columns
(e.g. [`dplyr::rename()`](https://dplyr.tidyverse.org/reference/rename.html))
and applying labels (e.g. `labelled` or `Hmisc`), there is much leg work
that needs to be applied in setting up the inputs for these functions.

This vignette demonstrates how to use **column dictionaries** to
expedite the process of standardising and labelling columns in a
dataset. We will use three main functions from `thekidsbiostats`:

- [`make_column_dict()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/make_column_dict.md)
  – create a copy-pasteable column dictionary template.
- [`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md)
  – rename and label columns using a column dictionary.
- [`relabel_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/relabel_columns.md)
  – reapply labels to columns using a column dictionary.

``` r

library(thekidsbiostats)
```

  

## 1. Create a data dictionary template: `make_column_dict()`

Suppose we use `patients_raw` from `thekidsbiostats` pacakge as an
example:

``` r

data("patients_raw", package = "thekidsbiostats")

patients_raw |> dplyr::slice_head(n=10) |> gt::gt()
```

| Patient ID | Site Name | trt_grp | randomisation date | AGE_yrs | Sex | Height (cm) | WEIGHT_kg | Do you smoke any form of tabacco product? | Diabetes (Y/N) | Cholesterol-Total | eGFR | HR_bpm | SBP_baseline_mmHg | DBP Baseline (mmHg) | sbp.wk12 | DBP_Week12 |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| BP-001 | Sydney | Control | 2025-08-26 | 55 | Female | 162.7 | 82.0 | Former | N | 5.7 | 70 | 64 | 159 | 96 | 158 | 98 |
| BP-002 | Melbourne | 5 mg/day | 2025-03-14 | 76 | Male | 164.4 | 94.0 | Never | N | 5.7 | 55 | 76 | 157 | 91 | 145 | 87 |
| BP-003 | Perth | Control | 2025-08-19 | 54 | Female | 163.9 | 75.9 | Never | N | 4.0 | 93 | 59 | 153 | 97 | 153 | 96 |
| BP-004 | Perth | Control | 2025-03-14 | 52 | Female | 158.8 | 78.8 | Never | N | 5.2 | 74 | 79 | 143 | 93 | 132 | 92 |
| BP-005 | Melbourne | 10 mg/day | 2025-02-28 | 57 | Male | 170.9 | 90.7 | Never | Y | 5.9 | 90 | 59 | 148 | 84 | 131 | 86 |
| BP-006 | Perth | Control | 2025-02-24 | 75 | Female | 169.1 | 76.8 | Never | Y | 5.4 | 57 | 76 | 150 | 86 | 149 | 82 |
| BP-007 | Melbourne | 5 mg/day | 2025-02-08 | 49 | Female | 164.3 | 59.4 | Never | N | 5.0 | 78 | 71 | 137 | 86 | 125 | 78 |
| BP-008 | Brisbane | 10 mg/day | 2025-06-24 | 66 | Female | 173.6 | 78.1 | Current | N | 5.0 | 82 | 73 | 141 | 88 | 132 | 85 |
| BP-009 | Perth | Control | 2025-04-06 | 52 | Male | 159.5 | 75.5 | Never | N | 4.3 | 71 | 89 | 157 | 93 | 157 | 94 |
| BP-010 | Melbourne | Control | 2025-07-30 | 55 | Female | 161.0 | 76.8 | Former | Y | 4.9 | 84 | 71 | 160 | 105 | 142 | 104 |

  

Beyond these names being inconsistent (mixed case, underscores, dots and
spaces), they can also be tricky to reference when attempting to use
them in coding operations. For example, let’s try to calculate the BMI
of the patients.

``` r

patients_raw <- patients_raw |> 
  mutate(bmi = WEIGHT_kg / (`Height (cm)` / 100.0)^2)

head(patients_raw$bmi)
#> [1] 30.97696 34.77957 28.25426 31.24822 31.05440 26.85802
```

The *spaces*, *question marks* and *parentheses* in the column names
require us to use backticks (\` \`) to avoid R interpreting these
symbols literally. Functions such as
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
can be very useful for standardising such column with syntactic names.
However, for situations like the column
`"Do you smoke any form of tabacco product?"`, the “cleaned” version
(`do_you_smoke_any_form_of_tabacco_product`) is arguably just as
unwieldy.

Nonetheless, the consequence of renaming columns for easy manipulation
in code is that we will likely also drop potentially useful formatting
stored in the columns (e.g. units and symbols). Ideally, we want the
best of both worlds: clean column names and simultaneously retaining
human-readable labels for presentation.

  

The solution is to manually set up a dictionary that maps the old column
names to newly formatted column names as well as apply `$label`
attributes to each column to be used for all visual presentation.

The
**[`make_column_dict()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/make_column_dict.md)**
function makes this process easier by creating a ready-to-fill template
based on the column names that exist within the data. For example:

``` r

dict <- make_column_dict(patients_raw, quiet=FALSE)  # note: setting auto_clean=FALSE will stop the janitor::clean_names() from being performed.
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
#>   "bmi", "bmi", "",
#> )
```

We can either directly modify the `dict` object assigned above or
copy-paste the printed output into our code and modify as needed. Here
we fill in the `new` names with cleaned, syntactic names and add a
human-readable `label` for each column:

``` r

dict_patients <- tribble(
  ~old, ~new, ~label,
  'Patient ID', 'patient_id', 'Patient ID',
  'Site Name', 'site', 'Site name',
  'trt_grp', 'treatment', 'Treatment group',
  'randomisation date', 'rand_date', 'Randomisation date',
  'AGE_yrs', 'age', 'Age (years)',
  'Sex', 'sex', 'Sex',
  'Height (cm)', 'height_cm', 'Height (cm)',
  'WEIGHT_kg', 'weight_kg', 'Weight (kg)',
  'Do you smoke any form of tabacco product?', 'smoking_status', 'Smoking status',
  'Diabetes (Y/N)', 'diabetes', 'Diabetes (Y/N)',
  'Cholesterol-Total', 'chol_total', 'Total cholesterol (mmol/L)',
  'eGFR', 'egfr', 'eGFR',
  'HR_bpm', 'heart_rate', 'Heart rate (bpm)',
  'SBP_baseline_mmHg', 'sbp_baseline', 'Systolic BP baseline (mmHg)',
  'DBP Baseline (mmHg)', 'dbp_baseline', 'Diastolic BP baseline (mmHg)',
  'sbp.wk12', 'sbp_week12', 'Systolic BP week 12 (mmHg)',
  'DBP_Week12', 'dbp_week12', 'Diastolic BP week 12 (mmHg)',
)
```

  
  

## 2. Apply column dictionary: `update_columns()`

Now after having defined the column dictionary above, we can simply use
the
**[`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md)**
function to apply these changes in a single line.

``` r

patients_clean <- update_columns(patients_raw, dict = dict_patients)
patients_clean |> dplyr::slice_head(n=10) |> gt::gt()
```

| Patient ID | Site name | Treatment group | Randomisation date | Age (years) | Sex | Height (cm) | Weight (kg) | Smoking status | Diabetes (Y/N) | Total cholesterol (mmol/L) | eGFR | Heart rate (bpm) | Systolic BP baseline (mmHg) | Diastolic BP baseline (mmHg) | Systolic BP week 12 (mmHg) | Diastolic BP week 12 (mmHg) | bmi |
|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|----|
| BP-001 | Sydney | Control | 2025-08-26 | 55 | Female | 162.7 | 82.0 | Former | N | 5.7 | 70 | 64 | 159 | 96 | 158 | 98 | 30.97696 |
| BP-002 | Melbourne | 5 mg/day | 2025-03-14 | 76 | Male | 164.4 | 94.0 | Never | N | 5.7 | 55 | 76 | 157 | 91 | 145 | 87 | 34.77957 |
| BP-003 | Perth | Control | 2025-08-19 | 54 | Female | 163.9 | 75.9 | Never | N | 4.0 | 93 | 59 | 153 | 97 | 153 | 96 | 28.25426 |
| BP-004 | Perth | Control | 2025-03-14 | 52 | Female | 158.8 | 78.8 | Never | N | 5.2 | 74 | 79 | 143 | 93 | 132 | 92 | 31.24822 |
| BP-005 | Melbourne | 10 mg/day | 2025-02-28 | 57 | Male | 170.9 | 90.7 | Never | Y | 5.9 | 90 | 59 | 148 | 84 | 131 | 86 | 31.05440 |
| BP-006 | Perth | Control | 2025-02-24 | 75 | Female | 169.1 | 76.8 | Never | Y | 5.4 | 57 | 76 | 150 | 86 | 149 | 82 | 26.85802 |
| BP-007 | Melbourne | 5 mg/day | 2025-02-08 | 49 | Female | 164.3 | 59.4 | Never | N | 5.0 | 78 | 71 | 137 | 86 | 125 | 78 | 22.00449 |
| BP-008 | Brisbane | 10 mg/day | 2025-06-24 | 66 | Female | 173.6 | 78.1 | Current | N | 5.0 | 82 | 73 | 141 | 88 | 132 | 85 | 25.91502 |
| BP-009 | Perth | Control | 2025-04-06 | 52 | Male | 159.5 | 75.5 | Never | N | 4.3 | 71 | 89 | 157 | 93 | 157 | 94 | 29.67738 |
| BP-010 | Melbourne | Control | 2025-07-30 | 55 | Female | 161.0 | 76.8 | Former | Y | 4.9 | 84 | 71 | 160 | 105 | 142 | 104 | 29.62849 |

  

### Writing/Loading column dictionaries from file

Both the
[`make_column_dict()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/make_column_dict.md)
and
[`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md)
functions can accept file paths as input or output for the column
dictionary. This is handled slightly differently for each:

- [`make_column_dict()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/make_column_dict.md):
  the `file` argument accepts a character string defining the file path
  to write the dictionary to. The extensions ‘.csv’, ‘.txt’, ‘.rds’ and
  ‘.xlsx’ are accepted.
- [`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md):
  providing a file path in the form of a character string to the `dict`
  argument will attempt to load the dictionary directly from the file.
  In addition, the `old`, `new` and `label` parameters can be used to
  explicitly specify the names of the relevant columns if they are named
  differently.

  
  

## 3. Reapply labels: `relabel_columns()`

When a data frame is modified, the `label` attributes do not always
remain. Recoding or modifying a column can drop its label entirely,
while other operations might carry a label over to a column where it no
longer belongs. Either way, we often need to reapply labels after making
changes to the data.

For example, let’s recode `sex` from `"Male"` and `"Female"` to `"M"`
and `"F"`:

``` r

patients_mod <- patients_clean |>
  mutate(sex = if_else(sex == "Male", "M", "F"))

attr(patients_mod$sex, "label")
#> NULL
```

The label has been lost.

Labels can also be carried over where they do not belong. Calculating
BMI from weight and height gives a new column that inherits the label of
the first component, in this case `weight_kg`:

``` r

patients_mod <- patients_mod |>
  mutate(bmi = weight_kg / (height_cm / 100)^2)

attr(patients_mod$bmi, "label")
#> [1] "Weight (kg)"
```

Rather than setting these by hand, we can reapply the labels from our
previous dictionary with
**[`relabel_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/relabel_columns.md)**.
Unlike
[`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md),
this leaves the column names alone and only sets the `label` attribute:

Note that
[`relabel_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/relabel_columns.md)
only labels columns that are listed in the dictionary, so the incorrect
label will remain unless we add an entry for `bmi`:

``` r


dict_patients <- dict_patients |> 
  add_row(
    old = "",  # as we created bmi afterwards, no `old` column exists
    new = "bmi",
    label = "BMI (kg/m^2)"
  )


patients_mod <- relabel_columns(patients_mod, dict_patients)

attr(patients_mod$sex, "label")
#> [1] "Sex"
attr(patients_mod$bmi, "label")
#> [1] "BMI (kg/m^2)"
```
