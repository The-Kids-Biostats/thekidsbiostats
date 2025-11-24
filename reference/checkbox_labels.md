# checkbox_labels

Apply factor labels to categorical responses (checkboxes) per REDCap
data dictionary

Apply factor labels to categorical responses (checkboxes) per REDCap
data dictionary

## Usage

``` r
checkbox_labels(x, dict)

checkbox_labels(x, dict)
```

## Arguments

- x:

  checkbox `Variable / Field Name` per data dictionary

- dict:

  REDCap data dictionary

## Value

Named list of character objects

Named list of character objects

## Examples

``` r
if (FALSE) { # \dontrun{

dat <- tibble(var___0 = c("0", "1"), var___1 = c("1", "0"))

dictionary <- tibble(`Variable / Field Name` = "var",
  `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")

dat <- labelled::set_variable_labels(dat, .labels = checkbox_labels("var", dictionary))

} # }

if (FALSE) { # \dontrun{

dat <- tibble(var___0 = c("0", "1"), var___1 = c("1", "0"))

dictionary <- tibble(`Variable / Field Name` = "var",
  `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes")

dat <- labelled::set_variable_labels(dat, .labels = checkbox_labels("var", dictionary))

} # }
```
