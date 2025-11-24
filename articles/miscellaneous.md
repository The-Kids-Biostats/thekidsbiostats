# Miscellaneous Functions

## Overview

``` r
library(thekidsbiostats)
```

## Example Usage

The data used in the following examples are simulated using OpenAI’s
ChatGPT. Identifiable fields (full names, addresses, etc.) are also
simulated.

### Using Extracts (`> clean_REDCap`)

First, we can use a (.csv) extract of the data and data dictionary from
REDCap:

``` r
dat_raw <- read.csv(file = "materials/miscellaneous/DemoRSyntheticData_DATA_2025-03-18_0728.csv")      # Read in the data
dict    <- read.csv(file = "materials/miscellaneous/DemoRSyntheticData_DataDictionary_2025-03-18.csv", # Read in the data dictionary
                    check.names = FALSE ## So spaces, punctuation etc. are preserved in tibble
                    ) 
```

Visualising the first few rows of our data:

``` r
head(dat_raw, n = 10) %>%
  thekids_table(line.spacing = 0.8,
                padding = 1.5)
#> Warning in check_font_family(font_family = font_family, fallback_family =
#> fallback_font_family): Font 'Barlow' not found; falling back to 'sans'.
```

| record_id | form_1_complete | demo_title | demo_fname         | demo_dob   | demo_address                           | demo_postcode | anthro_sex | anthro_weight | anthro_height | assess_iq | demo_edu | demo_income | demo_num_dep | med_hist_cvd | med_hist_diabetes | life_pol | life_house_date | life_super | synthetic_1_complete |
|-----------|-----------------|------------|--------------------|------------|----------------------------------------|---------------|------------|---------------|---------------|-----------|----------|-------------|--------------|--------------|-------------------|----------|-----------------|------------|----------------------|
| 1         | 0               | Mr.        | William Moore      | 1990‑01‑24 | 99 St Georges Terrace, Scarborough, WA | 6006          | Male       | 97.7          | 1.56          | 58        | 3        | 0           | 2            | 0            | 1                 | Liberal  | 1999‑04‑05      | 4458703    | 0                    |
| 2         | 0               | Mr.        | William Brown      | 1998‑10‑24 |                                        | 6011          | Other      | 62.3          | 1.53          | 54        | 1        | 0           | 1            | 0            | 1                 | Central  | 1985‑05‑31      | 14636346   | 0                    |
| 3         | 0               | Mr.        | Elizabeth Williams | 1983‑03‑01 | 87 Hay Street, Joondalup, WA           | 6011          | Male       | 146.0         | 2.02          | 119       | 3        | 4           | 6            | 1            | 0                 | Liberal  |                 | 5334516    | 0                    |
| 4         | 0               | Ms.        | John Miller        | 1985‑02‑13 | 85 Hay Street, Perth CBD, WA           | 6006          | Female     | 66.4          | 1.53          | 54        | 2        | 0           | 5            | 0            | 1                 | Labour   | 1989‑11‑13      | 6399928    | 0                    |
| 5         | 0               | Mr.        | John Brown         | 1973‑12‑10 | 33 Beaufort Street, Mount Lawley, WA   | 6005          | Other      | 114.9         | 1.55          | 57        | 3        | 0           | 6            | 1            | 1                 | Labour   | 1985‑12‑02      | 294741     | 0                    |
| 6         | 0               | Ms.        | Michael Williams   | 1997‑01‑29 | 24 St Georges Terrace, Northbridge, WA | 6011          | Female     | 69.2          | 1.64          | 69        | 3        | 1           | 2            | 0            | 0                 | Labour   | 1992‑04‑19      | 10847340   | 0                    |
| 7         | 0               | Ms.        | Michael Davis      | 1990‑10‑10 | 84 Hay Street, Northbridge, WA         | 6007          | Male       | 85.6          | 2.03          | 121       | 3        | 4           | 5            | 1            | 0                 | Labour   | 1991‑04‑28      | 6320541    | 0                    |
| 8         | 0               | Mx.        | Mary Brown         | 1994‑08‑20 | 85 Murray Street, Mount Lawley, WA     | 6008          | Male       | 76.7          | 1.70          | 77        | 3        | 1           | 1            | 0            | 0                 | Central  | 2009‑03‑12      | 1726473    | 0                    |
| 9         | 0               | Ms.        | Michael Taylor     | 1978‑05‑13 | 29 King Street, Fremantle, WA          | 6008          | Other      | 109.8         |               | 66        | 1        | 0           | 0            | 0            | 1                 | Liberal  | 2004‑03‑05      | 14534640   | 0                    |
| 10        | 0               | Mx.        | Patricia Moore     | 1990‑06‑06 | 76 Adelaide Terrace, Cottesloe, WA     | 6012          | Other      | 139.8         | 1.93          | 107       | 1        | 3           | 7            | 0            | 0                 | Liberal  | 1992‑12‑20      | 11706012   | 0                    |

Similarly, we can visualise our standardised data dictionary extract
from REDCap:

![Figure 1: Data dictionary
extract.](materials/miscellaneous/00-data_dictionary.png)  

Clearly:

- Some categorical fields (`demo_income`, `demo_num_dep`,
  `med_hist_cvd`, `med_hist_diabetes`) are numerically coded and will
  need resolution before proceeding.
- Column headers are variable names, not labels.

If we were to tabulate this data (stratifying by, say, `med_hist_cvd`),
we must manually apply labels to categorical variable levels (which is
indeed made easier using
[`thekidsbiostats::fct_case_when`](https://the-kids-biostats.github.io/thekidsbiostats/reference/fct_case_when.md))
and variable names (passed directly to `tbl_summary`):

``` r
dat_raw %>%
  select(demo_postcode, anthro_sex:life_pol, life_super) %>%
  mutate(demo_edu = fct_case_when(demo_edu == 0 ~ "Completed High School",
                                  demo_edu == 1 ~ "TAFE or Trade",
                                  demo_edu == 2 ~ "Higher Degree",
                                  demo_edu == 3 ~ "Bachelor Degree"),
         demo_income = fct_case_when(demo_income == 0 ~ "<80000",
                                     demo_income == 1 ~ "80000-120000",
                                     demo_income == 2 ~ "120000-160000",
                                     demo_income == 3 ~ "160000-200000",
                                     demo_income == 4 ~ ">200000"),
         across(c(med_hist_cvd, med_hist_diabetes), ~fct_case_when(. == 0 ~ "No",
                                                                   . == 1 ~ "Yes")),
         across(c(anthro_sex, life_pol), ~case_when(. == "" ~ NA,
                                                    TRUE ~ .))) %>%
  
  tbl_summary(by = med_hist_cvd,
              type = list(demo_postcode ~ "categorical"),
              digits = list(all_categorical() ~ c(0, 1)),
              label = list(demo_postcode     ~ "Postcode",
                           anthro_sex        ~ "Sex",
                           anthro_weight     ~ "Weight",
                           anthro_height     ~ "Height",
                           assess_iq         ~ "IQ",
                           demo_edu          ~ "Highest level of education",
                           demo_income       ~ "Household income",
                           demo_num_dep      ~ "Number of dependents",
                           med_hist_diabetes ~ "History of diabetes",
                           life_pol          ~ "Political affiliation",
                           life_super        ~ "Total superannuation balance")
              ) %>%
  modify_spanning_header(all_stat_cols() ~ "**History of CVD**") %>%
  thekids_table()
#> Warning in check_font_family(font_family = font_family, fallback_family =
#> fallback_font_family): Font 'Barlow' not found; falling back to 'sans'.
#> 100 missing rows in the "med_hist_cvd" column have been
#> removed.
```

[TABLE]

The above code chunk is clearly quite sizeable and required a
significant degree of user input.

Instead, using `clean_REDCap`:

``` r
dat_mod <- clean_REDCap(d = dat_raw,
             dict = dict,
             yesno_to_bool = T)

dat_mod %>%
  select(demo_postcode, anthro_sex:life_pol, life_super) %>%
  
  tbl_summary(by = med_hist_cvd,
              type = list(demo_postcode ~ "categorical"),
              digits = list(all_categorical() ~ c(0, 1))
              ) %>%
  modify_spanning_header(all_stat_cols() ~ "**History of CVD**") %>%
  thekids_table()
#> Warning in check_font_family(font_family = font_family, fallback_family =
#> fallback_font_family): Font 'Barlow' not found; falling back to 'sans'.
#> 100 missing rows in the "med_hist_cvd" column have been
#> removed.
```

[TABLE]

The variable levels and labels are automatically applied.

### Using APIs
