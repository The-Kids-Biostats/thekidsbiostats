# Changelog

## thekidsbiostats 1.9.1

- Same as previous version.

## thekidsbiostats 1.9.0

- Access to The Kids colours is now done via the `thekids_colours` list,
  which stores the named colours in lowercase and suffixed with their
  tinted variants (e.g. ‘midnightblue’, ‘saffron_50’).
- Added a suited custom palettes with The Kids colouring, including a
  main continuous/discrete sampling of the main kids colours as well as
  sequential and diverging variants for specific The Kids colour.
- Overhauled parsing/naming of arguments within
  [`thekids_table()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_table.md),
  which previously only allowed accessing very specific flextable
  parameters (some not at all). Additional new arguments:
  `highlight_colour`, `background_colour`. The `colour` parameter now
  also accepts any named colour or hex code in addition to the named The
  Kids colours.
- Created a data-raw folder which contains R scripts for creating The
  Kids colours and palettes.
- Removed scale_colour_thekids() and scale_fill_thekids() functionality
  out of thekids_theme() and merged the scale\_ functions into a single
  file with combined documentation.
- Added parameters `start`, `end` and `na.value` to
  scale_colour_thekids() and scale_fill_thekids() for truncating the
  chosen colourmap.
- Changed default behaviour of thekids_theme() and thekids_table(),
  whereby ‘midnightblue’ is the default background colour, where
  applicable.
- Fixed/Improved documentation and testing for all colour functions and
  list objects.
- Removed `theme_institute()` and `thekids_cols`, which are now
  deprecated.

## thekidsbiostats 1.8.3

- Fixed erroneous print messages in addins.R

## thekidsbiostats 1.8.2

- Made adjustments to make_column_dict(), including ability to prefill
  new_names and labels and escaping quotations.
- When `file` is specified in make_column_dict, a message lets users
  know that the file has been successfully written to the specified
  location.
- Removed duplicates raising errors in update_colnames()

## thekidsbiostats 1.8.1

- Fix deprecation warnings in `ggplot2`.
- Clean NAMESPACE

## thekidsbiostats 1.8.0

- Added functions for cleaning column names
- Changed functions for cleaning column names
- Added tests and cleaned up code
- Added Cleaning Columns vignette
- Added openxlsx to DESCRIPTION Suggests
- Add data_patient to package data

## thekidsbiostats 1.7.0

- Added message argument to fct_case_when
- Format p-values in thekids_model
- Removed tests/manual folder
- Ignoring example_reports htmls

## thekidsbiostats 1.6.4

- Fixed R-CMD-CHECK notes and warnings.

## thekidsbiostats 1.6.3

- Updated vignette hyperlinks in function documentation.

## thekidsbiostats 1.6.2

- updated logo css for wrapping
- fix create_template merge issues

## thekidsbiostats 1.6.1

- Same as previous version.

## thekidsbiostats 1.6.0

- Added modify_labels()
- Added unit testing for modify_labels()

## thekidsbiostats 1.5.0

- Update thekids_table fallback font handling
- Additional font tests for thekids_table()
- Add blog link to pkgdown site
- Enhance pkgdown structure

## thekidsbiostats 1.4.3

- Re-structure readme
- Update README.md

## thekidsbiostats 1.4.2

- Implement a suite of changes with how dependencies are installed by
  the package.
- Updates to README, DESCRIPTION.
- Remove large packages from Depends to an .onLoad() file.

## thekidsbiostats 1.4.1

- Updated DESCRIPTION with pkgdown site url.
- Updated README with R-universe badges.

## thekidsbiostats 1.4.0

- Established unit testing using testthat.
- Added code coverage badge to README.
- Established pkgdown site for package.

## thekidsbiostats 1.3.3

- Resolved small bug in `round_vec` with handling of NA values.

## thekidsbiostats 1.3.2

- Resolved minor spelling mistakes.

## thekidsbiostats 1.3.1

- Resolved non-ASCII characters in addins, create_project,
  create_template, model_helpers
- Fixed thekids_model warnings, update DESCRIPTION
- Fixed bug in round_df()
- Fixed global binding variables model_helpers, thekids_showpalettes,
  thekids_table, table_helpers
- Update release.yml

## thekidsbiostats 1.3.0

- Quality-of-life updates to create_template_addin()
- Added extra functionality to create_template_addin()

## thekidsbiostats 1.2.1

- Same as previous version.

## thekidsbiostats 1.2.0

- Added integer values to zebra parameter in thekids_table
- Added zebra integer highlighting
- Build thekids_table documentation
- Resolve merge conflicts in thekids_table documentation
- date_fix parameter in thekids_table
- Fix date wrapping in thekids_table, rownames in kable column name
  handling
- Add thekids_table tests

## thekidsbiostats 1.1.1

- Same as previous version.

## thekidsbiostats 1.1.0

- Create documentation for thekids_colours, thekids_palettes
- Update license
- Remove duplicated huxtable Import
- More updates to thekids_palettes documentation
- Update .Rbuildignore
- Fix dependency errors and notes
- Include exit conditions for release.yml in case tag already exists
- Fix 4 additional warnings following merge update from main
- Updated Authorship in DESCRIPTION

## thekidsbiostats 1.0.2

- Include shinyFiles, ggeffects in DESCRIPTION\>Depends
- Amend some roxygen headers
- Create shiny addins
- Load shiny, shinyFiles
- update addins.R
- Revert “update addins.R”
- Create project workflow vignettes + references
- minor edits to vignette
- First pass at all vignettes
- Update README.md
- Progress vignette creation, start `miscellaneous`
- Performed checks of vignettes
- table function expanded, help updated
- Updated help documentation

## thekidsbiostats 1.0.1

- Include shinyFiles, ggeffects in DESCRIPTION\>Depends
- Amend some roxygen headers
- Create shiny addins
- Load shiny, shinyFiles
- update addins.R
- Revert “update addins.R”
- Create project workflow vignettes + references
- minor edits to vignette
- First pass at all vignettes
- Update README.md
- Progress vignette creation, start `miscellaneous`
- Performed checks of vignettes
- table function expanded, help updated
- Updated help documentation

## thekidsbiostats 1.0.0

- Include shinyFiles, ggeffects in DESCRIPTION\>Depends
- Amend some roxygen headers
- Create shiny addins
- Load shiny, shinyFiles
- update addins.R
- Revert “update addins.R”
- Create project workflow vignettes + references
- minor edits to vignette
- First pass at all vignettes
- Update README.md
- Progress vignette creation, start `miscellaneous`
- Performed checks of vignettes
- table function expanded, help updated
- Updated help documentation

## thekidsbiostats 0.0.2

- Initial CRAN submission.
