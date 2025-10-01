# thekidsbiostats

[![name status badge](https://the-kids-biostats.r-universe.dev/badges/:name)](https://the-kids-biostats.r-universe.dev/)
[![thekidsbiostats status badge](https://the-kids-biostats.r-universe.dev/thekidsbiostats/badges/version)](https://the-kids-biostats.r-universe.dev/thekidsbiostats)
![R-CMD-check](https://github.com/The-Kids-Biostats/thekidsbiostats/actions/workflows/R-CMD-check.yaml/badge.svg)
[![Codecov test coverage](https://codecov.io/gh/The-Kids-Biostats/thekidsbiostats/graph/badge.svg)](https://app.codecov.io/gh/The-Kids-Biostats/thekidsbiostats)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17240567.svg)](https://doi.org/10.5281/zenodo.17240567)

Package with helper functions and formatting templates used by the Biostatistics team of The Kids Research Institute Australia.

All templates and themes in this package use the "Barlow" font family which is not installed by default on many machines. It can be installed here: 
https://fonts.google.com/specimen/Barlow
https://fonts.google.com/specimen/Barlow+Semi+Condensed

# Getting started

## Installing

The Kids Research Institute Australia biostats package can be installed from the R-universe with the following:
```
install.packages("thekidsbiostats", repos = "https://the-kids-biostats.r-universe.dev")
```

Alternatively, the package can be installed via `remotes`:
```         
remotes::install_github("The-Kids-Biostats/thekidsbiostats", build_vignettes = TRUE)
```

## Installing fonts

Because the "Barlow" font is utilised by default on many machines, this font must be downloaded, installed, and then registered so R can recognise it. To register the font in R, simply run:

```
extrafont::font_import()
```

`thekids_table()` requires the font to be installed at a system level, else a default font family will be applied (sans).

`theme_thekids()` can either call the font from the system (after registration), else a fall-back to install the font (using a Google API) will be called.

# Using the template

To make use of our project structure templates for a new project, follow the following steps:

1. Create a new R project in a fresh directory and open it in RStudio.
2. Run `thekidsbiostats::create_project()` function. This function has various parameters to tweak how you would like to set up your project structure which can be read in the documentation. 

To use our quarto templates, run `thekidsbiostats::create_template(file_name = "X")` in an existing R project. The file name parameter is mandatory and specifies the name of the .qmd file. 

The directory parameter of the `create_template()` function specifies where the .qmd file will be located. This is in the "reports" folder by default, which is created as part of `create_project()` above. 

Other parameters for create_template() determine the type of template, e.g. html or word format. 

# Accessing vignettes

Vignettes have been built for some of the functions. These can be opened (using R, for now). The vignettes have the same name as the function.

At the moment, vignettes exist for:

+ Data manipulation functions (`data_manipulations`)
+ Model output functions (`model_output`)
+ Project workflow functions (`project_workflow`)
+ "The Kids" theming functions (`thekids_theming`)
+ Miscellaneous functions (`miscellaneous`)

Accessing these vignettes can be done two ways:

1) Using `utils::browseVignettes(package = "thekidsbiostats")`
     + Opens vignette via web browser.
3) Using `vignette(x, package = "thekidsbiostats")` where x is the function name
     + Opens the vignette in the "Help" tab of RStudio.

