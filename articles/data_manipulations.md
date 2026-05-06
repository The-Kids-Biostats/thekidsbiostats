# Data Manipulation Tools

## Overview

The R programming language has extensive functionality and the vast
ecosystem of community-developed packages extends those capabilities
well beyond the base language. Nonetheless, there is always room for
additional helpful functions to be added to any R programmer’s toolbelt
and the sections below discuss some of those available within
`thekidsbiostats`.

  

## Example Usage

### Rounding Functions

The following two functions (`round_vec` and `round_df`) are examples
where the sole purpose is to keep code concise and to the point. Often
when we present figures — whether that be through plots, tables or in
written form — we wish to preserve trailing zeroes when rounding numbers
to a specific *x* decimal places.

There are two functions that can help with this:

- `round_vec` – preserves trailing zeroes for vectors.
- `round_df` – consistently rounds every numeric column in a
  `data.frame` or `tibble`.

Below we demonstrate the difference between the base R
[`round()`](https://rdrr.io/r/base/Round.html) and
[`round_vec()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/round_vec.md)
when rounding numerical values:

``` r

original <-  c(1.8003, 1.9998, 2.5812)

data.frame(original = original) %>%
  mutate(round     = as.character(round(original, 2)),
         round_vec = round_vec(original, 2)) %>%
  thekids_table()
#> Warning in check_font_family(font_family = font_family, fallback_family =
#> fallback_font_family): Font 'Barlow' not found; falling back to 'sans'.
```

| original | round | round_vec |
|----------|-------|-----------|
| 1.8003   | 1.8   | 1.80      |
| 1.9998   | 2     | 2.00      |
| 2.5812   | 2.58  | 2.58      |

To illustrate `round_df`:

``` r

data.frame(var1 = rnorm(n = 5, mean = 10, sd = 2),
           var2 = rexp(n = 5, rate = 0.25),
           var3 = rweibull(n = 5, shape = 4, scale = 7))  %>%
  round_df(digits = 2) %>%
  thekids_table()
#> Warning in check_font_family(font_family = font_family, fallback_family =
#> fallback_font_family): Font 'Barlow' not found; falling back to 'sans'.
```

| var1  | var2 | var3 |
|-------|------|------|
| 7.20  | 0.09 | 9.02 |
| 10.51 | 3.90 | 6.90 |
| 5.13  | 5.21 | 2.78 |
| 9.99  | 7.81 | 7.38 |
| 11.24 | 5.23 | 5.52 |

### Data Manipulation Functions

#### `> fct_case_when`

Factors are a useful data format for manipulating any categorical data
because they preserve the ordinal nature inherent to those variables.

Below is an example of working with ordinal data.

``` r

x <- 1:50
case_when(x %% 12 == 0 ~ "Very Likely",   # Multiple of 12 (most certain)
          x %% 6  == 0 ~ "Likely",        # Multiple of 6
          x %% 3  == 0 ~ "Neutral",       # Multiple of 3
          x %% 2  == 0 ~ "Unlikely",      # Multiple of 2
          TRUE         ~ "Very Unlikely"  # Default category) %>% 
          ) %>% 
  as.factor %>%
  levels()
#> [1] "Likely"        "Neutral"       "Unlikely"      "Very Likely"  
#> [5] "Very Unlikely"
```

Note, however, the strange (*alphabetical*) ordering of the levels. If
we would like to set a more logical ordering of these factors, we would
also have to use `factor`:

``` r

x <- 1:50
case_when(x %% 12 == 0 ~ "Very Likely",   # Multiple of 12 (most certain)
          x %% 6  == 0 ~ "Likely",        # Multiple of 6
          x %% 3  == 0 ~ "Neutral",       # Multiple of 3
          x %% 2  == 0 ~ "Unlikely",      # Multiple of 2
          TRUE         ~ "Very Unlikely"  # Default category) %>% 
          ) %>% 
  factor(levels = c("Very Unlikely", "Unlikely", "Neutral", "Likely", "Very Likely")) %>%
  as.factor %>%
  levels()
#> [1] "Very Unlikely" "Unlikely"      "Neutral"       "Likely"       
#> [5] "Very Likely"
```

In comparison,
[`fct_case_when()`](https://the-kids-biostats.github.io/thekidsbiostats/reference/fct_case_when.md)
orders the factor levels simply based on the order of their appearance
in the argument, to return an identical result to the above:

``` r

x <- 1:50
fct_case_when(x %% 12 == 0 ~ "Very Likely",   # Multiple of 12 (most certain)
              x %% 6  == 0 ~ "Likely",        # Multiple of 6
              x %% 3  == 0 ~ "Neutral",       # Multiple of 3
              x %% 2  == 0 ~ "Unlikely",      # Multiple of 2
              TRUE         ~ "Very Unlikely"  # Default category) %>% 
              ) %>% 
  as.factor %>%
  levels()
#> Factor levels (in order): Very Likely, Likely, Neutral, Unlikely, Very Unlikely
#> [1] "Very Likely"   "Likely"        "Neutral"       "Unlikely"     
#> [5] "Very Unlikely"
```
