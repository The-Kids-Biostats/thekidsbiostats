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
dataset. We will use two main functions from `thekidsbiostats`:

- [`make_column_dict()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/make_column_dict.md)
  – create a copy-pasteable column dictionary template.
- [`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md)
  – rename and label columns using a column dictionary.

``` r
library(thekidsbiostats)
```

  

## 1. Create a data dictionary template: `make_column_dict()`

Suppose we use
[`thekidsbiostats::data_patient`](https://the-kids-biostats.github.io/thekidsbiostats/reference/data_patient.md)
as an example:

``` r

data("data_patient")

data_patient |> as_flextable()
```

| Patient ID# | DOB \[YYYY-MM-DD\] | Sex (0=Male, 1=Female) | WHAT IS YOUR HEIGHT? (cm) | WHAT IS YOUR CURRENT WEIGHT? (kg) | Do you currently smoke any form of tobacco products, including cigarettes, cigars, or pipes, on a regular basis? | bp (mmHg) | Cholesterol / mmolL |
|-------------|--------------------|------------------------|---------------------------|-----------------------------------|------------------------------------------------------------------------------------------------------------------|-----------|---------------------|
| integer     | Date               | character              | numeric                   | numeric                           | logical                                                                                                          | character | numeric             |
| 101         | 1980-05-12         | 0                      | 175                       | 70                                | true                                                                                                             | 120/80    | 5.2                 |
| 102         | 1992-08-03         | 1                      | 160                       | 55                                | false                                                                                                            | 110/70    | 4.8                 |
| 103         | 1975-12-25         | 1                      | 180                       | 80                                | false                                                                                                            | 130/85    | 6.1                 |
| 104         | 2000-01-01         | 0                      | 165                       | 60                                | true                                                                                                             | 115/75    | 5.0                 |
| 105         | 1985-07-07         | 1                      | 170                       | 75                                | false                                                                                                            | 125/82    | 5.5                 |
| n: 5        |                    |                        |                           |                                   |                                                                                                                  |           |                     |

Beyond this dataset visually looking messy, it can also be tricky to
reference these column names when attempting to use them in operations.
For example, let’s try to calculate the BMI of individuals and recode
the `Sex` column by replacing `0/1` with `Male/Female`.

``` r
data_patient$`Sex (0=Male, 1=Female)` = case_when(
  data_patient$`Sex (0=Male, 1=Female)` == 0 ~ "Male",
  data_patient$`Sex (0=Male, 1=Female)` == 1 ~ "Female",
  T ~ NA_character_
)

bmi = data_patient$`WEIGHT (kg)` / (data_patient$`HEIGHT (cm)` / 100.0)^2
print(bmi)
#> numeric(0)
```

The *spaces*, *equal signs* and *parentheses* in the column names
requires us to use backticks (\` \`) to avoid R interpreting these
symbols literally. Functions such as
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
can be very useful for standardising such column names into syntactic
names. However, for situations like our column
`"Do you currently smoke any form of tobacco products, including cigarettes, cigars, or pipes, on a regular basis?"`,
the “cleaned” version is arguably just as unwieldy.

Nonetheless, the consequence of renaming columns for easy manipulation
in code is likely dropping any potentially useful formatting of the
columns (e.g. units and symbols). Ideally, we want to both rename the
columns and simultaneously retain their human-readable labels for
presentation.

  

The solution is therefore to manually set up a dictionary that maps the
old column names to newly formatted column names as well as apply
`$label` attributes to each column to be used for all visual
presentation.

The
**[`make_column_dict()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/make_column_dict.md)**
function makes this process slightly easier by creating a ready-to-fill
template based on the column names that exist with the data. For
example:

``` r
dict <- make_column_dict(data_patient, quiet=FALSE)  # note: setting auto_clean=FALSE will stop the janitor::clean_names() from being performed.
#> dict_patient <- tribble(
#>   ~old, ~new, ~label,
#>   'Patient ID#', 'patient_id_number', '',
#>   'DOB [YYYY-MM-DD]', 'dob_yyyy_mm_dd', '',
#>   'Sex (0=Male, 1=Female)', 'sex_0_male_1_female', '',
#>   'WHAT IS YOUR HEIGHT? (cm)', 'what_is_your_height_cm', '',
#>   'WHAT IS YOUR CURRENT WEIGHT? (kg)', 'what_is_your_current_weight_kg', '',
#>   'Do you currently smoke any form of tobacco products, including cigarettes, cigars, or pipes, on a regular basis?', 'do_you_currently_smoke_any_form_of_tobacco_products_including_cigarettes_cigars_or_pipes_on_a_regular_basis', '',
#>   'bp (mmHg)', 'bp_mm_hg', '',
#>   'Cholesterol / mmolL', 'cholesterol_mmol_l', '',
#> )
```

We can either directly add to the `dict` object assigned above or
copy-paste the printed output into our code and modify as needed:

``` r
dict_patient <- tribble(
  ~old, ~new, ~label,
  'Patient ID#', 'patient_id_number', '',
  'DOB [YYYY-MM-DD]', 'dob_yyyy_mm_dd', '',
  'Sex (0=Male, 1=Female)', 'sex_0_male_1_female', '',
  'WHAT IS YOUR HEIGHT? (cm)', 'what_is_your_height_cm', '',
  'WHAT IS YOUR CURRENT WEIGHT? (kg)', 'what_is_your_current_weight_kg', '',
  'Do you currently smoke any form of tobacco products, including cigarettes, cigars, or pipes, on a regular basis?', 'do_you_currently_smoke_any_form_of_tobacco_products_including_cigarettes_cigars_or_pipes_on_a_regular_basis', '',
  'bp (mmHg)', 'bp_mm_hg', '',
  'Cholesterol / mmolL', 'cholesterol_mmol_l', '',
)
```

  
  

## 2. Apply column dictionary: `update_columns()`

Now after having defined the column dictionary above, we can simply use
the
**[`update_columns()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/update_columns.md)**
function to apply these changes in a single line.

``` r
data_clean <- update_columns(data_patient, dict = dict_patient)
data_clean |> flextable()
```

|     |            |        |     |     |       |        |     |
|-----|------------|--------|-----|-----|-------|--------|-----|
| 101 | 1980-05-12 | Male   | 175 | 70  | true  | 120/80 | 5.2 |
| 102 | 1992-08-03 | Female | 160 | 55  | false | 110/70 | 4.8 |
| 103 | 1975-12-25 | Female | 180 | 80  | false | 130/85 | 6.1 |
| 104 | 2000-01-01 | Male   | 165 | 60  | true  | 115/75 | 5.0 |
| 105 | 1985-07-07 | Female | 170 | 75  | false | 125/82 | 5.5 |

### Writing/Loading column dictionaries from file

Both of these helper functions can accept file paths as input or output
for the column dictionary. This is handled slightly differently for
each:

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
