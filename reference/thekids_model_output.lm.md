# Handle output for Linear Models

Internal function to handle the output for objects of class `lm`.

## Usage

``` r
# S3 method for class 'lm'
thekids_model_output(model, by, data = NULL, ...)
```

## Arguments

- model:

  A fitted linear model object of class `lm`.

- by:

  Required. The main predictor of interest. Behaviour will differ when
  variable is continuous vs categorical

- ...:

  Additional arguments (currently unused).

## Value

A list of model-specific output.

## Details

Output derived from `mod_dat` which is supplied by `thekids_model`.
