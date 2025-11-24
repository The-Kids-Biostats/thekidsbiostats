# thekidsbiostats

[![name status
badge](https://the-kids-biostats.r-universe.dev/badges/:name)](https://the-kids-biostats.r-universe.dev/)
[![thekidsbiostats status
badge](https://the-kids-biostats.r-universe.dev/thekidsbiostats/badges/version)](https://the-kids-biostats.r-universe.dev/thekidsbiostats)
![R-CMD-check](https://github.com/The-Kids-Biostats/thekidsbiostats/actions/workflows/R-CMD-check.yaml/badge.svg)[![Codecov
test
coverage](https://codecov.io/gh/The-Kids-Biostats/thekidsbiostats/graph/badge.svg)](https://app.codecov.io/gh/The-Kids-Biostats/thekidsbiostats)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17240567.svg)](https://doi.org/10.5281/zenodo.17240567)

This package contains formatting templates and a suite of helper
functions used and developed by the Biostatistics team at The Kids
Research Institute Australia.

All templates and themes in this package use the “Barlow” font family
which is not installed by default on many machines. It can be installed
here: + <https://fonts.google.com/specimen/Barlow> +
<https://fonts.google.com/specimen/Barlow+Semi+Condensed>

# Getting started

## Installing the package

The Kids Research Institute Australia biostats package can be installed
from the R-universe with the following:

``` R
install.packages("thekidsbiostats", repos = "https://the-kids-biostats.r-universe.dev", dependencies = TRUE)
```

Alternatively, the package can be installed via `remotes`:

``` R
remotes::install_github("The-Kids-Biostats/thekidsbiostats", build_vignettes = TRUE, dependencies = TRUE)
```

## Registering fonts

Because the “Barlow” font is utilised by default on many machines, this
font must be downloaded, installed, and then registered so R can
recognise it. To register the font in R, simply run:

``` R
extrafont::font_import()
```

- [`thekids_table()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_table.md)
  requires the font to be installed at a system level, else a default
  font family will be applied (sans).
- [`theme_thekids()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_theme.md)
  can either call the font from the system (after registration), else a
  fall-back to install the font (using a Google API) will be called.

## Accessing vignettes

At the moment, vignettes exist for:

- Data manipulation functions (`data_manipulations`)
- Model output functions (`model_output`)
- Project workflow functions (`project_workflow`)
- “The Kids” theming functions (`thekids_theming`)
- Miscellaneous functions (`miscellaneous`)

Accessing these vignettes can be done two ways:

1.  Via the [package
    website](https://the-kids-biostats.github.io/thekidsbiostats/).
2.  Using `utils::browseVignettes(package = "thekidsbiostats")`
    - Opens vignette via web browser.
3.  Using `vignette(x, package = "thekidsbiostats")` where x is the
    function name
    - Opens the vignette in the “Help” tab of RStudio.

# Using the package

See
[here](https://the-kids-biostats.github.io/posts/2025-01-23_thekids_package/thekids_package.html)
for a broad walkthough of the package and its functionalities.

## Workflow creation

To make use of our project structure templates for a new project, follow
the following steps:

1.  Open RStudio.
2.  Navigate to the “Create New Project” addin, or run
    [`thekidsbiostats::create_project()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/create_project.md).
    - These functionalities contain various parameters to tweak how you
      would like to set up your project structure which can be read in
      the documentation.
    - Branded Quarto templates can be created within the “Create
      Project” addin, directly via the “Create Report Template” addin or
      by running
      [`thekidsbiostats::create_template()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/create_template.md).
      - Either `.html` or `.docx` templates can be created.

## Theming

Using functions that automatically apply a set of formatting options to
plots and tables saves time, allowing us to focus on the analysis and
interpretation.

- Formatting plots:
  [`theme_thekids()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_theme.md)
- Formatting tables:
  [`thekids_table()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_table.md)

## Helper functions

- [`thekids_model()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_model.md)
- [`round_vec()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/round_vec.md)
  &
  [`round_df()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/round_df.md)
- [`fct_case_when()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/fct_case_when.md)
