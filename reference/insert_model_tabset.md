# RStudio Addin: Insert child Quarto tabset for model output

This Shiny gadget inserts a `model_name <- "mod"` line and a child chunk
to include a preformatted tabset from an external Quarto file. It also
optionally previews the output.

## Usage

``` r
insert_model_tabset()
```

## Value

Inserts code into the active RStudio document and copies a child QMD
file.
