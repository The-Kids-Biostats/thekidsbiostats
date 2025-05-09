#' @title Function to display the available colours in The Kids palette
#'
#' @description Displays the colour palette for The Kids, including their hex codes.
#'
#' @export
thekids_showpalette <- function() {

  dplyr::bind_rows(thekids_palettes, .id = "Category") %>%
    dplyr::filter(Category != "typography") %>%
    tidyr::pivot_longer(-Category, names_to = "Color", values_to = "Hex") %>%
    tidyr::drop_na() %>%  # Remove NA rows
    dplyr::mutate(
      Category = factor(Category, levels = c("primary", "tint50", "tint10")),
      Color = factor(Color, levels = rev(names(thekids_palettes$primary))) # Maintain row order
    ) %>%
    ggplot2::ggplot(aes(x = Category, y = Color, fill = Hex)) +
    ggplot2::geom_tile(width = 0.45, height = 0.9) +  # Reduce width more than height to increase horizontal spacing
    ggplot2::labs(x = NULL, y = NULL, title = "The Kids Palette") +
    thekids_theme(base_size = 14) +
    ggplot2::scale_fill_identity() +  # Use exact hex colors
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(face = "bold"),  # Bold column headers
      axis.text.y = ggplot2::element_text(face = "bold"),  # Bold row labels
      panel.grid = ggplot2::element_blank(),  # Remove grid lines
      axis.ticks = ggplot2::element_blank(),  # Remove axis ticks
      legend.position = "none"
    ) +
    ggplot2::coord_fixed(ratio = 0.5)  # Increase ratio to add more horizontal space

}

