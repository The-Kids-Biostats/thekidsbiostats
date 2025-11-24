# Create a Quarto report template

Copies extension files into `_extensions/` and creates a `.qmd` report
file. Optionally opens the created file. If the file already exists, no
overwrite occurs and a warning is shown.

## Usage

``` r
create_template(
  file_name = NULL,
  directory = "reports",
  ext_name = "html",
  title = NULL,
  subtitle = NULL,
  author = NULL,
  affiliation = NULL,
  include_reproducibility = TRUE,
  open_file = TRUE
)
```

## Arguments

- file_name:

  Name of the report file (without .qmd).

- directory:

  Directory to save the report and extensions in.

- ext_name:

  Name of the template extension (e.g. "html", "word").

- title:

  Title of the report.

- subtitle:

  Subtitle of the report.

- author:

  Author name (defaults to `Sys.info()[['user']]`).

- affiliation:

  Affiliation of the author.

- include_reproducibility:

  Whether or not to include a 'Reproducibility Information' section,
  which outputs the R session information (default: TRUE).

- open_file:

  Whether to open the file after creation (default: TRUE).

## Value

Invisibly returns path to created .qmd file, or NULL if skipped.
