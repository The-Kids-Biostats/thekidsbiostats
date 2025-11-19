#' Save a ggplot with common practical defauls
#'
#' This function saves ggplot2 plots to common pre-specified sizes and ratios.
#'
#' @param filename File name to create on disk.
#' @param path Path of the directory to save plot to.
#' @param plot Plot to save; defaults to last plot displayed.
#' @param output Size to save plot to. Default "full portrait".
#' @param device Device to use. Must be "png" or "pdf". Default "pdf".
#' @param dpi Plot resolution. Default 300.
#' @param ... Other defaults passed to ggsave.
#'
#' @examples
#' \dontrun{
#' gg <- ggplot(mtcars, aes(hp, mpg, color = as.factor(cyl))) +
#' geom_point() +
#' theme_thekids()
#'
#' ggsave_size("example", output = "half landscape", device = "png")
#' ggsave_size("example", output = "half portrait", device = "png")
#' ggsave_size("example", output = "full landscape", device = "png")
#'
#' ggsave_size("example", output = "half landscape")
#' ggsave_size("example", output = "half portrait")
#' ggsave_size("example", output = "full landscape")
#' }
#'
#' @export

thekids_save <- function(plot = ggplot2::last_plot(),
                         filename,
                         path = "output",
                         output = "full portrait",
                         device = "pdf",
                         dpi = 300,
                         ...) {

    if (length(output) != 1 |
        !output %in% unique(save_params$size)) {
      stop(paste0("Your selection for 'output' must be from the list: ",
                  paste0("'", unique(save_params$size), "'", collapse = ", "), "."))
    }

    if (length(device) != 1 |
        !device %in% save_params$device) {
      stop(paste0("Your selection for 'device' must be from the list: ",
                  paste0("'", unique(save_params$device), "'", collapse = ", "), "."))
    }

    dir.create(path, showWarnings = FALSE, recursive = TRUE)

    sel <- save_params[save_params$size == output & save_params$device == device, ]

    for (i in seq_len(nrow(sel))) {
      args <- sel[i, ]
      out_fname <- paste0(filename, args$suffix, ".", args$device)
      message("Saving to: ", file.path(path, out_fname))

      ggplot2::ggsave(
        filename = out_fname,
        plot = plot,
        path = path,
        device = as.character(args$device),
        width = as.numeric(args$width),
        height = as.numeric(args$height),
        units = as.character(args$units),
        dpi = dpi,
        scale = as.numeric(args$scale),
        ...
      )
    }
}
