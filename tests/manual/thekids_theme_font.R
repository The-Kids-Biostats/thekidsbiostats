# Testing the font theming for thekids_theme

# Test 1
## "Standard" implementation for `thekids_theme`
## Uses Barlow (not Semi-Condensed by default -- for ease)

library(thekidsbiostats)

getOption("thekidsbiostats.font") # Barlow

mtcars %>%
  ggplot(aes(x = mpg,
             y = wt,
             col = factor(cyl))) +
  geom_point() +
  labs(title = "Test Plot") +
  thekids_theme()
#-------------------------------------------------------------------------------

# Test 2
## Use "Barlow Semi Condensed"
## Set option GLOBALLY (global options level)

options(thekidsbiostats.font = "Barlow Semi Condensed")

mtcars %>%
  ggplot(aes(x = mpg,
             y = wt,
             col = factor(cyl))) +
  geom_point() +
  labs(title = "Test Plot") +
  thekids_theme()
#------------------------------------------------------------------------------

# Test 3
## Use *other* Google font -- specified in `thekids_theme`
## Let's use "Ruge Boogie"

mtcars %>%
  ggplot(aes(x = mpg,
             y = wt,
             col = factor(cyl))) +
  geom_point() +
  labs(title = "Test Plot") +
  thekids_theme(base_family = "Ruge Boogie", base_size = 15)
#-------------------------------------------------------------------------------

# Test 4
## Load *new* Google font at package option level
## Let's use "Monsieur La Doulaise" (note all families can be seen with `sysfonts::font_families_google()`)
## Must restart R session to load this from scratch -- relies on package being loaded to trigger installation

rstudioapi::restartSession()
options(thekidsbiostats.font = "Monsieur La Doulaise")
library(thekidsbiostats)

mtcars %>%
  ggplot(aes(x = mpg,
             y = wt,
             col = factor(cyl))) +
  geom_point() +
  labs(title = "Test Plot") +
  thekids_theme(base_size = 30)
