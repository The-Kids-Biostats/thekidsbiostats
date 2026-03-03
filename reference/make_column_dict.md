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

  Optional character string, If specified, fills the `$new` column with
  these labels. Length must match the number of columns in `data`.

- labels:

  Optional character string. If specified, fills the `$label` column
  with these labels. Length must match the number of columns in `data`.

- file:

  Optional character string. If specified, writes dictionary template to
  file path (available formats: .csv, .txt, .xlsx, .rds, .R)

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
.R, this writes the R code in the format of a `tribble` to the file.

## Examples

``` r
data("data_patient", package = "thekidsbiostats")

# Create a data dictionary and formulate some cleaned column names, assign to `dict` object
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

```
