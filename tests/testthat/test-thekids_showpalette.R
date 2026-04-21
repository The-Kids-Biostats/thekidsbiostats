library(testthat)

test_that("thekids_showpalette returns a ggplot object", {
  p <- thekids_showpalette()
  expect_s3_class(p, "ggplot")
})

test_that("thekids_showpalette uses scale_fill_identity", {
  p <- thekids_showpalette()
  scales <- p$scales$scales
  expect_true(any(vapply(scales, function(s) inherits(s, "ScaleDiscreteIdentity"), logical(1))))
})

test_that("thekids_showpalette has expected labels and title", {
  p <- thekids_showpalette()
  expect_equal(p$labels$title, "The Kids Palette")
  expect_null(p$labels$x)
  expect_null(p$labels$y)
})

test_that("thekids_showpalette includes a geom_tile layer", {
  p <- thekids_showpalette()
  geoms <- vapply(p$layers, function(l) class(l$geom)[1], character(1))
  expect_true("GeomTile" %in% geoms)
})

test_that("thekids_showpalette applies coord_fixed with ratio 0.5", {
  p <- thekids_showpalette()
  expect_s3_class(p$coordinates, "CoordCartesian")
  expect_equal(p$coordinates$ratio, 0.5)
})

test_that("thekids_showpalette factors are set correctly", {
  df <- dplyr::bind_rows(thekidsbiostats::thekids_palettes[c('primary', 'tint50', 'tint10')], .id = "Category") |> 
    tidyr::pivot_longer(-tidyselect::all_of("Category"), names_to = "Color", values_to = "Hex") |> 
    tidyr::drop_na() |>  # Remove NA rows
    dplyr::mutate(
      Category = factor(.data$Category, levels = c("primary", "tint50", "tint10")),
      Color = factor(.data$Color, levels = rev(names(thekidsbiostats::thekids_palettes$primary))) # Maintain row order
    )
  
  expect_true(all(levels(df$Category) == c("primary", "tint50", "tint10")))
  expect_true(all(levels(df$Color) == rev(names(thekidsbiostats::thekids_palettes$primary))))
})
