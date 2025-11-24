# clean_REDCap

Clean a REDCap extract by applying factor levels and convert column
classes per the REDCap data dictionary.

## Usage

``` r
clean_REDCap(
  d,
  dict,
  numeric_date = FALSE,
  yesno_to_bool = FALSE,
  quiet = FALSE
)
```

## Arguments

- d:

  REDCap (data frame)

- dict:

  REDCap data dictionary (data frame)

- numeric_date:

  (default FALSE) set to TRUE if MS Excel has *helpfully* converted to a
  numeric date

- yesno_to_bool:

  (default FALSE) convert factors with levels `c("Yes", "No")` to
  logical objects?

- quiet:

  (default FALSE) pass quiet argument to lubridate functions

## Value

cleaned data frame

## Examples

``` r
if (FALSE) { # \dontrun{

dat <- tibble(var = c("0", "1"))

dictionary <- tibble(`Variable / Field Name` = "var",
  `Field Type` = "radio",
  `Field Label` = "Label",
  `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes",
  `Text Validation Type OR Show Slider Number` = NA)

(dat_clean <- clean_REDCap(dat, dictionary))

} # }
```
