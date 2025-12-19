#' Save a ggplot with common practical defaults
#'
#' This function saves ggplot2 plots to common pre-specified sizes and ratios.
#'
#' @param filename File name to create on disk.
#' @param path Path of the directory to save plot to.
#' @param plot Plot to save; defaults to last plot displayed.
#' @param layout Size to save plot to. Can be a vector of strings. Default "full portrait".
#' @param device Device to use. Can be a vector of strings. Default "pdf".
#' @param dpi Plot resolution. Default 300.
#' @param ... Other defaults passed to ggsave.
#'
#' @examples
#' \dontrun{
#' gg <- ggplot(mtcars, aes(hp, mpg, color = as.factor(cyl))) +
#' geom_point() +
#' theme_thekids()
#'
#' thekids_save("example", layout = "half landscape", device = "png")
#' thekids_save("example", layout = "half portrait", device = "png")
#' thekids_save("example", layout = "full landscape", device = "png")
#'
#' thekids_save("example", layout = c("half landscape", "half portrait"))
#' thekids_save("example", device = c("png", "pdf"))
#' }
#'
#' @export

thekids_save <- function(plot = ggplot2::last_plot(),
                         filename,
                         path = "output",
                         layout = "full portrait",
                         device = "pdf",
                         dpi = 300,
                         ...) {

    if (!all(layout %in% unique(thekidsbiostats::save_params$size))) {
      stop(paste0("Your selection for 'layout' must be from the list: ",
                  paste0("'", unique(thekidsbiostats::save_params$size), "'",
                         collapse = ", "),
                  "."))
    }

    if (!all(device %in% unique(thekidsbiostats::save_params$device))) {
      stop(paste0("Your selection for 'device' must be from the list: ",
                  paste0("'", unique(thekidsbiostats::save_params$device), "'",
                         collapse = ", "),
                  "."))
    }

    dir.create(path, showWarnings = FALSE, recursive = TRUE)

    sel <- thekidsbiostats::save_params[thekidsbiostats::save_params$size %in% layout & thekidsbiostats::save_params$device %in% device, ]

    for (i in seq_len(nrow(sel))) {
      args <- sel[i, ]
      out_fname <- paste0(filename, args$suffix, ".", args$device)
      out_full <- file.path(path, out_fname)

      if (file.exists(out_full)) {
        ans <- utils::askYesNo(msg = paste0("File '",
                                            out_full,
                                            "' already exists. Overwrite?"))
        if (isTRUE(ans)){
          message("Overwriting: ", out_full)
        } else if (isFALSE(ans)){
          message("Skipping: ", out_full, "\nFile already exists!")
          next
        }
        else if (is.na(ans)){
          stop("Save cancelled by user.")
          next
        }
        } else if (!file.exists(out_full)){
          message("Saving to: ", out_full)
        }

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
        ...)
      }

  }
