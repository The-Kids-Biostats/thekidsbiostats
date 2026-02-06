#' Save a ggplot with common practical defaults
#'
#' This function saves ggplot2 plots to common pre-specified sizes and ratios.
#'
#' @param filename File name to create on disk.
#' @param path Path of the directory to save plot to. Defaults to current working directory.
#' @param plot Plot to save; defaults to last plot displayed.
#' @param layout Size to save plot to. Can be a vector of strings. Default "full landscape". See details.
#' @param device Device to use. Can be a vector of strings. Default "pdf".
#' @param dpi Plot resolution. Default 300.
#' @param ... Other defaults passed to ggsave.
#'
#' @details
#' Plot layouts can take the values "quarter", "half portrait", "half landscape,
#' "full portrait", "full landscape". Each of these are based on the dimensions of a
#' standard A4 page.
#'
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
                         path = ".",
                         layout = "full landscape",
                         device = "pdf",
                         dpi = 300,
                         ...) {

    if (!all(layout %in% unique(thekidsbiostats::layout_params$size))) {
      stop(paste0("Your selection for 'layout' must be from the list: ",
                  paste0("'", unique(thekidsbiostats::layout_params$size), "'",
                         collapse = ", "),
                  "."))
    }

    if (!all(device %in% unique(thekidsbiostats::layout_params$device))) {
      stop(paste0("Your selection for 'device' must be from the list: ",
                  paste0("'", unique(thekidsbiostats::layout_params$device), "'",
                         collapse = ", "),
                  "."))
    }

    dir.create(path, showWarnings = FALSE, recursive = TRUE)

    sel <- thekidsbiostats::layout_params[thekidsbiostats::layout_params$size %in% layout & thekidsbiostats::layout_params$device %in% device, ]

    base_name <- tools::file_path_sans_ext(basename(filename))

    for (i in seq_len(nrow(sel))) {
      args <- sel[i, ]
      out_fname <- paste0(base_name, args$suffix, ".", args$device)
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
