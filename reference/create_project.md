# Create a new project structure

Creates a new project folder with subfolders, an RProj file, and
optional Quarto report. Can optionally open the project in a new session
and close the current one.

## Usage

``` r
create_project(
  project_name,
  path = NULL,
  folders = c("data-raw", "data", "admin", "docs", "reports"),
  ext_name = "html",
  create_report = FALSE,
  create_rproj = TRUE,
  open_project = TRUE,
  ...
)
```

## Arguments

- project_name:

  Name of the new project folder.

- path:

  Parent directory for the project. If NULL, prompts the user.

- folders:

  Character vector of subfolders to create.

- ext_name:

  Name of the report extension for
  [`create_template()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/create_template.md).

- create_report:

  Whether to create a report using
  [`create_template()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/create_template.md).

- create_rproj:

  Whether to include a .Rproj file.

- open_project:

  Whether to open the new project in a new RStudio session.

- ...:

  Additional arguments passed to
  [`create_template()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/create_template.md).

## Value

Invisibly returns the project path.
