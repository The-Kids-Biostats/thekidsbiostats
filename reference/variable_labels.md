# variable_labels

Apply variable labels to a data frame per the REDCap data dictionary. If
there is no variable label associated with a column then is lable will
be the same as the column's name.

Apply variable labels to a data frame per the REDCap data dictionary. If
there is no variable label associated with a column then is label will
be the same as the column's name.

## Usage

``` r
variable_labels(d, dict)

variable_labels(d, dict)
```

## Arguments

- d:

  REDCap import

- dict:

  REDCap data dictionary

## Value

character vector (length `ncol(d)`) of REDCap Field Labels per the data
dictionary

data frame with variable labels

## Examples

``` r
if (FALSE) { # \dontrun{

dat <- tibble(var = 1)

dictionary <- tibble(`Variable / Field Name` = "var", `Field Label` = "Label")

dat <- labelled::set_variable_labels(dat, .labels = variable_labels(dat, dictionary))

} # }

if (FALSE) { # \dontrun{

dat <- tibble(var = 1, var2___1 = 1, var2___2 = 0)
dictionary <- tibble(`Variable / Field Name` = c("var", "var2"),
                     `Field Label` = c("Label for field 'Var'", NA),
                     `Field Type` = c(NA, "checkbox"),
                     `Choices, Calculations, OR Slider Labels` =
                       c(NA, "1, First checkbox label | 2, Second checkbox label"))

dat <- variable_labels(dat, dictionary)
View(dat)

} # }
```
