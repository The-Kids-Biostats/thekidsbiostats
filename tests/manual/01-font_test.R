# Test font rendering for HTML qmd files

rstudioapi::restartSession()

# Step 1:
## Create a blank qmd template
## Adds the .qmd file and _extensions folder
thekidsbiostats::create_template(file_name = "02-font_test")


# Step 2:
## Open qmd template and render
## By default, we install and run the report using **Barlow font**.
## This is done at a file-level (installs Barlow in the YAML header to the Quarto script)
#-------------------------------------------------------------------------------

# Test 1
## Globally set package font to a different font
## Let's use "Orbitron"
rstudioapi::restartSession()

options(thekidsbiostats.font = "Orbitron")
library(thekidsbiostats)

# This automatically changes the YAML header
thekidsbiostats:::.preprocess_qmd(file_path = "tests/manual/02-font_test.qmd")

# Now we can re-render.

# **Note**
## This does not seem to change the font for the plot, since this runs a "fresh"/"isolated" qmd environment that does not
## consider the options we define here.

## We would need to specify `options(thekidsbiostats.font = "Orbitron")` in the qmd file to impact the theming.
#-------------------------------------------------------------------------------


# Test 2
## Note the YAML header of the Quarto file


#mainfont: 'Orbitron'
#include-in-header:
#  text: |
#  <style>
#  @import url('https://fonts.googleapis.com/css2?family=Orbitron&display=swap');
#</style>


# We can manually specify the font family here (so we don't need to use thekidsbiostats:::.preprocess_qmd)
# url structure just needs the `family` specified with "+" in place of spaces " ".
#     Eg) Barlow Semi Condensed = url('https://fonts.googleapis.com/css2?family=Barlow+Semi+Condensed&display=swap')

