# Preprocess font changes to Quarto (.qmd) HTML reports

This function "pre-processes" a .qmd file to use different (Google)
fonts, without having to locally download and install the font files.

## Usage

``` r
preprocess_qmd(
  file_path,
  base_family = getOption("thekidsbiostats.font", "Barlow"),
  update_global_option = T
)
```

## Arguments

- file_path:

  File path to the .qmd file to update.

- base_family:

  Font base family to consider. Defaults to the global option when
  loading `thekidsbiostats`. Otherwise, any Google font family can be
  specified (must be in
  [`sysfonts::font_families_google()`](https://rdrr.io/pkg/sysfonts/man/font_families_google.html)).

- update_global_option:

  Update the global option for `thekidsbiostats.font` based on the new
  font family specified. Default TRUE.

## Value

Updates the YAML header of the input .qmd file (formatted per
`thekidsbiostats` template) with the specified font `base_family`.

## Note

Works only for HTML report types that have `mainfont` and
`include-in-header` arguments in the YAML header as specified in the
`thekidsbiostats` HTML template. The template can be created using
[thekidsbiostats::create_template](https://the-kids-biostats.github.io/thekidsbiostats/reference/create_template.md).

## Examples

``` r
if (FALSE) { # \dontrun{
preprocess_qmd(file_path = "path_to_qmd", base_family = "Monsieur La Doulaise")
} # }
```
