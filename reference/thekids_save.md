# Save a ggplot with common practical defaults

This function saves ggplot2 plots to common pre-specified sizes and
ratios.

## Usage

``` r
thekids_save(
  plot = ggplot2::last_plot(),
  filename,
  path = ".",
  layout = "full landscape",
  device = "pdf",
  dpi = 300,
  ...
)
```

## Arguments

- plot:

  Plot to save; defaults to last plot displayed.

- filename:

  File name to create on disk.

- path:

  Path of the directory to save plot to. Defaults to current working
  directory.

- layout:

  Size to save plot to. Can be a vector of strings. Default "full
  landscape". See details.

- device:

  Device to use. Can be a vector of strings. Default "pdf".

- dpi:

  Plot resolution. Default 300.

- ...:

  Other defaults passed to ggsave.

## Details

Plot layouts can take the values "quarter", "half portrait", "half
landscape, "full portrait", "full landscape". Each of these are based on
the dimensions of a standard A4 page.

## Examples

``` r
if (FALSE) { # \dontrun{
gg <- ggplot(mtcars, aes(hp, mpg, color = as.factor(cyl))) +
geom_point() +
theme_thekids()

thekids_save("example", layout = "half landscape", device = "png")
thekids_save("example", layout = "half portrait", device = "png")
thekids_save("example", layout = "full landscape", device = "png")

thekids_save("example", layout = c("half landscape", "half portrait"))
thekids_save("example", device = c("png", "pdf"))
} # }
```
