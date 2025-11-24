# Insert Callout via RStudio Addin

Launches a Shiny app as an RStudio addin to insert a Quarto callout at
the cursor position. The user selects a callout type from a dropdown,
sees a preview colour, and inserts formatted callout text into the
current script.

## Usage

``` r
insert_callout()
```

## Value

A Shiny application that runs within RStudio.

## Examples

``` r
if (FALSE) { # \dontrun{
if (interactive()) {
  insert_callout()
}
} # }
```
