#' @title Function to display the available colours in The Kids palette
#'
#' @description Displays the colour palette for The Kids, including their hex codes.
#'
#' @export
thekids_showpalette <- function() {

  bind_rows(thekids_palettes, .id = "Category") %>%
    filter(Category != "typography") %>%
    pivot_longer(-Category, names_to = "Color", values_to = "Hex") %>%
    drop_na() %>%  # Remove NA rows
    mutate(
      Category = factor(Category, levels = c("primary", "tint50", "tint10")),
      Color = factor(Color, levels = rev(names(thekids_palettes$primary))) # Maintain row order
    ) %>%
    ggplot(aes(x = Category, y = Color, fill = Hex)) +
    geom_tile(width = 0.45, height = 0.9) +  # Reduce width more than height to increase horizontal spacing
    labs(x = NULL, y = NULL, title = "The Kids Palette") +
    thekids_theme(base_size = 14) +
    scale_fill_identity() +  # Use exact hex colors
    scale_x_discrete(position = "top") +
    theme(
      axis.text.x = element_text(face = "bold"),  # Bold column headers
      axis.text.y = element_text(face = "bold"),  # Bold row labels
      panel.grid = element_blank(),  # Remove grid lines
      axis.ticks = element_blank(),  # Remove axis ticks
      legend.position = "none"
    ) +
    coord_fixed(ratio = 0.5)  # Increase ratio to add more horizontal space

}

