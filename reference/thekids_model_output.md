# Generate Model Output for Specified Model Type

This function identifies the type of the fitted model and chooses the
appropriate method to produce model output.

## Usage

``` r
thekids_model_output(model, by = NULL, data = NULL, ...)
```

## Arguments

- model:

  A fitted model object produced by `thekids_model` or another modeling
  function.

- by:

  The main predictor of interest.

- data:

  A data frame containing the variables to be used in the model.

- ...:

  Additional arguments passed to the output method for the specific
  model type.

## Value

Output specific to the fitted model type, as determined by the
appropriate output method (e.g., summary or custom output).

## Details

This function acts as a wrapper, delegating the call to the appropriate
output method based on the class of the model object. The actual
behaviour is determined by the specific method implementation for the
model type.

## Examples

``` r
# Assuming `model` is a fitted model object
# thekids_model_output(model)
```
