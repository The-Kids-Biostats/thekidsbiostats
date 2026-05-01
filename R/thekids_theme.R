#' Apply Institute Theming to ggplot2 Plots
#'
#' This function applies a custom theme to ggplot2 plots, incorporating specific fonts and colours to align with the institute's visual identity.
#'
#' @details
#' The function determines the operating system and selects appropriate font names for Windows or other systems. It applies a minimal theme with custom settings for plot title, axis title, and strip text, using the 'Barlow Semi Condensed' font family. It also adjusts color scales using the 'viridis' package.
#'
#' For a more thorough example, see the [vignette](https://the-kids-biostats.github.io/thekidsbiostats/articles/thekids_theming.html).
#'
#' @param base_size The base font size, given in points. Default is 11.
#' @param base_family The base font family used for the text (default Barlow). Most Google Fonts are supported (see Note).
#' @param base_line_size The base size for line elements (e.g., axis lines, grid lines). Calculated as `base_size/22` by default.
#' @param base_rect_size The base size for rect elements (e.g., plot background, legend keys). Calculated as `base_size/22` by default.
#' @param strip_colour A named colour from the list of The Kids colours, see \link{thekids_colours} for available colour names. Note that only the main colour names are accepted because the 50% tint is always used.
#' @param colour_theme Deprecated. Use [scale_colour_thekids()] instead.
#' @param fill_theme Deprecated. Use [scale_fill_thekids()] instead.
#' @param scale_colour_type Deprecated. Use [scale_colour_thekids()] instead.
#' @param scale_fill_type Deprecated. Use [scale_fill_thekids()] instead.
#' @param rev_colour Deprecated. Use [scale_colour_thekids()] instead.
#' @param rev_fill Deprecated. Use [scale_fill_thekids()] instead.
#' @param fig_dpi Base DPI for figure. Only applicable when Barlow font family (default) is *not* selected.
#' @param ... Miscellaneous arguments necessary for parameter aliasing, etc.
#'
#' @note
#' If a Google font has not been loaded with the package, `thekids_theme` will load this function on your behalf.
#'
#' Supported Google Fonts are those that exist in `sysfonts::font_families_google()`.
#'
#' @return A list of ggplot2 theme elements and scale adjustments.
#'
#' @examples
#' \dontrun{
#' # Install the required fonts first (see below)
#' # Example usage with ggplot2
#' library(ggplot2)
#'
#' p <- ggplot(mtcars, aes(x = mpg, y = wt, col = factor(cyl))) +
#'   geom_point() +
#'   thekids_theme() +
#'   scale_colour_thekids()
#'
#' print(p)
#'
#' p2 <- ggplot(mtcars, aes(x = factor(cyl), y = wt, fill = factor(cyl))) +
#'   geom_col() +
#'   thekids_theme() +
#'   scale_fill_thekids(palette='tint50', reverse=TRUE)
#'
#' print(p2)
#' }
#' @export

thekids_theme <- function(base_size = 11,
                          base_family = NULL,
                          base_line_size = base_size / 22,
                          base_rect_size = base_size / 22,
                          strip_colour = 'midnightblue',
                          scale_colour_type = lifecycle::deprecated(),
                          scale_fill_type = lifecycle::deprecated(),
                          colour_theme = lifecycle::deprecated(),
                          fill_theme = lifecycle::deprecated(),
                          rev_colour = lifecycle::deprecated(),
                          rev_fill = lifecycle::deprecated(),
                          fig_dpi = 300,
                          ...) {
  
  # Standardise argument aliasing
  call <- match.call()
  std_call <- standardise_args(
    call,
    alias_map = c(
      "color" = "colour",
      "gray" = "grey",
      "strip_color" = "strip_colour"
    )
  )
  if (!identical(names(call), names(std_call))) {
    return(eval(std_call, parent.frame()))
  }

  # Deprecation checks
  if (lifecycle::is_present(scale_colour_type)) {
    lifecycle::deprecate_warn(
      when="2.0.0", what="thekids_theme(scale_colour_type)",
      details = "Colour scales are now controlled via `scale_colour_thekids()`."
    )
  }
  
  if (lifecycle::is_present(scale_fill_type)) {
    lifecycle::deprecate_warn(
      when="2.0.0", what="thekids_theme(scale_fill_type)",
      details = "Fill scales are now controlled via `scale_fill_thekids()`."
    )
  }
  
  if (lifecycle::is_present(colour_theme)) {
    lifecycle::deprecate_warn(
      when="2.0.0", what="thekids_theme(colour_theme)",
      details = "Colour scales are now controlled via `scale_colour_thekids()`."
    )
  }
  
  if (lifecycle::is_present(fill_theme)) {
    lifecycle::deprecate_warn(
      when="2.0.0", what="thekids_theme(fill_theme)",
      details = "Fill scales are now controlled via `scale_fill_thekids()`."
    )
  }
  
  if (lifecycle::is_present(rev_colour)) {
    lifecycle::deprecate_warn(
      when="2.0.0", what="thekids_theme(rev_colour)",
      details = "Colour scales are now controlled via `scale_colour_thekids()`."
    )
  }
  
  if (lifecycle::is_present(rev_fill)) {
    lifecycle::deprecate_warn(
      when="2.0.0", what= "thekids_theme(rev_fill)",
      details = "Fill scales are now controlled via `scale_fill_thekids()`."
    )
  }

  # Default font from options
  default_font <- "Barlow"  # No need for getOption()

  # Use default font if base_family is not provided
  base_family <- base_family %||% default_font

  # Ensure the font is available before applying it
  if (!(base_family %in% sysfonts::font_families())) {
    tryCatch({
      sysfonts::font_add_google(base_family, base_family)
    }, error = function(e) {
      warning("Could not load Google Font: ", base_family, ". Defaulting to: ", default_font)
      base_family <- default_font
    })
  }

  # Ensure showtext is active ONLY when a custom font is specified
  if (base_family != default_font) {
    showtext::showtext_opts(dpi = fig_dpi)  # Match the Quarto YAML dpi setting
    showtext::showtext_auto()

    message(paste0("Non-default font family (", base_family, ") selected.\nPlease consider changing `fig_dpi` if any issues with plot scaling are encountered."))
  }

  if (!strip_colour %in% names(thekids_colours)[!grepl("_", names(thekids_colours))]) {
    stop("`strip_colour` must be one of the main (i.e. not '_50' or '_10') named colours listed in `thekids_colours`.", call. = FALSE)
  }

  # Get the 50% tint version of the requested The Kids colour.
  strip.background = thekids_colours[[paste0(strip_colour, '_50')]]

  # Return the theme and functions
  list(
    ggplot2::theme_minimal(
      base_family = base_family, 
      base_size = base_size,
      base_line_size = base_line_size, 
      base_rect_size = base_rect_size
    ) +
    ggplot2::theme(
      axis.line = ggplot2::element_line(colour = "grey75", linewidth = 0.6),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = "grey90", linewidth = 0.4),
      plot.title = ggplot2::element_text(family = base_family, size=base_size * 1.3, face = "bold"),
      plot.subtitle = ggplot2::element_text(family = base_family, size=base_size * 1.1, colour = 'grey30'),
      axis.title.x = ggplot2::element_text(family = base_family, face = "bold", margin = ggplot2::margin(t = 8)),
      axis.title.y = ggplot2::element_text(family = base_family, face = "bold", margin = ggplot2::margin(r = 8)),
      axis.text = ggplot2::element_text(family = base_family, size=ggplot2::rel(0.9)),
      strip.text = ggplot2::element_text(
        family = base_family, face = "bold", 
        size = base_size * 1.1, hjust = 0,
        margin = ggplot2::margin(l=8, r=4, t=8, b=8)
      ),
      strip.background = ggplot2::element_rect(fill = strip.background, colour = "grey75", linewidth = 1),
      legend.title = element_text(size = base_size * 0.9, face = "bold"),
      legend.text  = element_text(size = base_size * 0.8),
      legend.key.size = unit(base_size * 0.05, "cm"),
      plot.background = ggplot2::element_rect(fill = "white", colour = "white"),
      plot.margin = ggplot2::margin(t = 10, r = 15, b = 10, l = 10),
      panel.spacing = ggplot2::unit(1, "lines")
    )
  )
}

#' @rdname thekids_theme
#' @examples
#' \dontrun{
#' # Install the required fonts first (see below)
#' # Example usage with ggplot2
#' library(ggplot2)
#'
#' p <- ggplot(mtcars, aes(x = mpg, y = wt, col = factor(cyl))) +
#'   geom_point() +
#'   theme_thekids() +
#'   scale_colour_thekids()
#'
#' print(p)
#'
#' p2 <- ggplot(mtcars, aes(x = factor(cyl), y = wt, fill = factor(cyl))) +
#'   geom_col() +
#'   theme_thekids() +
#'   scale_fill_thekids(palette='tint50', reverse=TRUE)
#'
#' print(p2)
#' }
#' @export
theme_thekids <- thekids_theme