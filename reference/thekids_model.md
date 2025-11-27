# Fit a Statistical Model and Pass to Output Handler

This function fits a statistical model to the given dataset using a
specified formula based on the dependent (`y`) and independent (`x` and
`formula`) variables. After fitting, the model is passed to a dedicated
output handler (`thekids_model_output`) for further processing or
customization. Supported model types include linear regression, negative
binomial regression, and quantile regression.

## Usage

``` r
thekids_model(data, y, x, formula = "", model = "linear", ...)
```

## Arguments

- data:

  A data frame containing the variables to be used in the model.

- y:

  Character string specifying the name of the dependent variable.

- x:

  Character string specifying the name of the primary independent
  variable.

- formula:

  Optional character string specifying additional terms to include in
  the formula. If not provided, the formula will be auto-generated as
  `y ~ x`.

- model:

  Character string specifying the type of model to fit. Currently
  supported are `"linear"`, `"negbin"`, or `"quantile"`.

- ...:

  Additional arguments passed to the underlying modeling functions.

## Value

Model output relating to the appropriate modeling function (e.g.,
[`lm`](https://rdrr.io/r/stats/lm.html),
[`glm.nb`](https://rdrr.io/pkg/MASS/man/glm.nb.html), or
[`rq`](https://rdrr.io/pkg/quantreg/man/rq.html)). This is the same
object returned by
[`thekids_model_output`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_model_output.md)
if the latter is called directly.

## Details

This function validates the specified model type and constructs a
formula based on the supplied arguments. The data is reduced to complete
cases for the variables included in the formula before fitting the
model. The fitted model is passed to
[`thekids_model_output`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_model_output.md)
for further handling, allowing for streamlined customization of model
outputs.

For a more thorough example, see the
[vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/model_output.html).

## See also

[`thekids_model_output`](https://the-kids-biostats.github.io/thekidsbiostats/reference/thekids_model_output.md)

## Examples

``` r
# Example 1: Linear model
if (FALSE) { # \dontrun{
data(mtcars)
thekids_model(mtcars, y = "mpg", x = "wt", model = "linear")
} # }

# Example 2: Linear model with factor
if (FALSE) { # \dontrun{
thekids_model(mtcars %>% mutate(cyl = as.factor(cyl)), y = "mpg", x = "cyl", model = "linear")
} # }

# Example 3: Quantile regression
if (FALSE) { # \dontrun{
library(quantreg)
data(engel)
thekids_model(engel, y = "foodexp", x = "income", model = "quantile", tau = 0.5)
} # }
```
