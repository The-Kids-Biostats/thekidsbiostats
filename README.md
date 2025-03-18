# thekidsbiostats

Package with helper functions and formatting templates used by the Biostatistics team of The Kids Research Institute Australia.

All templates and themes in this package use the "Barlow" font family which is not installed by default on many machines. It can be installed here: 
https://fonts.google.com/specimen/Barlow
https://fonts.google.com/specimen/Barlow+Semi+Condensed

# Getting started

## Installing

The Kids Research Institute Australia biostats package (`thekidsbiostats`) can be installed with the following:

```         
remotes::install_github("The-Kids-Biostats/thekidsbiostats", build_vignettes = TRUE)
```
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

