# i) Helper function with default logo name
default_logo_name <- function() "thekids.png"

# ii) Helper function to extract `title-block-banner` from qmd YAML
parse_qmd_banner_colour <- function(qmd_path) {
  qmd <- readLines(qmd_path, warn = FALSE)
  line <- grep("^\\s*title-block-banner\\s*:\\s*", qmd, value = TRUE)
  if (length(line)) {
    val <- sub("^\\s*title-block-banner\\s*:\\s*", "", line[1])
    gsub("^['\"]|['\"]$", "", val)
  } else NULL
}

# iii) Helper function to extract callout colours from styles.css
parse_css_colors <- function(css_path) {
  css <- paste(readLines(css_path, warn = FALSE), collapse = "\n")
  types <- c("note","tip","warning","important")
  out <- setNames(vector("list", length(types)), types)
  for (t in types) {
    bg_pattern <- paste0("\\.callout-", t, "\\s*\\{[^}]*?background-color:\\s*([^;]+);")
    bg_match <- regmatches(css, regexec(bg_pattern, css, perl = TRUE))[[1]]
    bg <- if(length(bg_match) >= 2) sub("\\s*!important.*", "", bg_match[2]) else NA

    header_pattern <- paste0("\\.callout-", t, "\\s+\\.callout-header\\s*\\{[^}]*?background-color:\\s*([^;]+);")
    header_match <- regmatches(css, regexec(header_pattern, css, perl = TRUE))[[1]]
    header <- if(length(header_match) >= 2) sub("\\s*!important.*", "", header_match[2]) else NA

    out[[t]] <- list(background = bg, header = header)
  }
  out
}

parse_column_margin <- function(css_path) {
  css <- readLines(css_path, warn = FALSE)
  css <- trimws(css)

  # --- Box block ---
  start_box <- grep("^\\.column-margin > \\*\\s*\\{", css)
  end_box <- grep("^\\}", css)
  end_box <- end_box[end_box > start_box[1]][1]
  block_box <- css[(start_box+1):(end_box-1)]

  get_prop <- function(prop, block, default = NA) {
    line <- grep(paste0("^", prop, "\\s*:"), block, value = TRUE)
    if (length(line) == 0) return(default)
    val <- sub(paste0("^", prop, "\\s*:\\s*"), "", line[1])
    val <- sub(";.*", "", val)
    val
  }

  border_val <- get_prop("border", block_box)
  border_width <- as.numeric(sub("px.*", "", border_val))
  border_color <- sub(".*solid\\s*", "", border_val)

  box <- list(
    border_width = border_width,
    border_color = border_color,
    padding = as.numeric(sub("em.*", "", get_prop("padding", block_box))),
    background_color = get_prop("background-color", block_box)
  )

  # --- Header block (::before) ---
  start_hdr <- grep("^\\.column-margin > \\*::before\\s*\\{", css)
  end_hdr <- grep("^\\}", css)
  end_hdr <- end_hdr[end_hdr > start_hdr[1]][1]
  block_hdr <- css[(start_hdr+1):(end_hdr-1)]

  # Helper for header properties
  header <- list(
    background_color = get_prop("background-color", block_hdr),
    text_color = get_prop("color", block_hdr),
    padding = as.numeric(sub("em.*", "", get_prop("padding", block_hdr))),
    content = gsub('^["\']|["\']$', '', get_prop("content", block_hdr, "")),  # strip quotes properly
    font_weight = get_prop("font-weight", block_hdr, "")
  )

  list(box = box, header = header)
}

# iv) Helper function to extract all defaults into list, and compile metadata (.json) file of defaults
## Metadata file enables the reversion of choices back to default
read_defaults <- function(folder_html,
                          META_FILENAME) {
  meta_path <- file.path(folder_html, META_FILENAME)
  qmd_path <- file.path(folder_html, "template.qmd")
  css_path <- file.path(folder_html, "styles.css")

  # Parse current qmd and css
  banner_colour <- parse_qmd_banner_colour(qmd_path)
  callout_colours <- parse_css_colors(css_path)
  column_margin <- parse_column_margin(css_path)

  if (fs::file_exists(meta_path)) {
    meta_json <- jsonlite::fromJSON(meta_path)

    # Ensure default_logo exists
    default_logo <- meta_json$default_logo %||% default_logo_name()
    logo <- meta_json$default_logo %||% default_logo_name()

    meta <- c(list(logo = logo,
                   default_logo = default_logo,
                   banner_colour = banner_colour,
                   callout_colours = callout_colours,
                   column_margin = column_margin),
              meta_json[setdiff(names(meta_json),
                                c("logo",
                                  "default_logo",
                                  "banner_colour",
                                  "callout_colours",
                                  "column_margin"))])

  } else {
    # First-time initialization
    meta <- list(
      logo = default_logo_name(),
      default_logo = default_logo_name(),
      banner_colour = banner_colour,
      callout_colours = callout_colours,
      column_margin = column_margin
    )
    writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE), meta_path)
  }

  meta$qmd_path <- qmd_path
  meta$css_path <- css_path
  meta
}

# v) Helper function to update shiny UI based on default values
## So logo, colours are by default selected in the app
update_ui_from_defaults <- function(d,
                                    session,
                                    logo_file) {
  # Logo
  shiny::updateTextInput(session, "newname", value = d$logo)

  # Banner Colour
  colourpicker::updateColourInput(session, "banner_colour", value = d$banner_colour)

  # Callouts
  for (t in names(d$callout_colours)) {
    colourpicker::updateColourInput(session,
                                    paste0("col_", t, "_header"),
                                    value = d$callout_colours[[t]]$header)
    colourpicker::updateColourInput(session,
                                    paste0("col_", t, "_bg"),
                                    value = d$callout_colours[[t]]$background)
  }

  # Column margin — box
  shiny::updateNumericInput(session, "colmargin_border_width", value = d$column_margin$box$border_width)
  colourpicker::updateColourInput(session, "colmargin_border_color", value = d$column_margin$box$border_color)
  shiny::updateNumericInput(session, "colmargin_padding", value = d$column_margin$box$padding)
  colourpicker::updateColourInput(session, "colmargin_bg_color", value = d$column_margin$box$background_color)

  # Column margin — header (::before)
  colourpicker::updateColourInput(session, "colmargin_header_bg", value = d$column_margin$header$background_color)
  shiny::updateTextInput(session, "colmargin_header_text", value = d$column_margin$header$text_color)
  shiny::updateNumericInput(session, "colmargin_header_padding", value = d$column_margin$header$padding)
  shiny::updateTextInput(session, "colmargin_header_content", value = d$column_margin$header$content)
  shiny::updateTextInput(session, "colmargin_header_weight", value = d$column_margin$header$font_weight)

  logo_file(d$logo)
}

# vi) Helper function to update the logo
update_logo <- function(infile,
                        file_name,
                        folder_html,
                        METAFILE_NAME) {
  meta_path <- file.path(folder_html, METAFILE_NAME)

  # Save user logo in folder
  dest_html <- file.path(folder_html, file_name)
  fs::file_copy(infile, dest_html, overwrite = TRUE)

  # Also copy to parent folder if needed
  folder_parent <- fs::path_norm(fs::path(folder_html, ".."))
  dest_parent <- file.path(folder_parent, file_name)
  fs::file_copy(infile, dest_parent, overwrite = TRUE)

  # Update styles.css background-image
  css_path <- file.path(folder_html, "styles.css")
  css <- readLines(css_path, warn = FALSE)
  css_new <- gsub("background-image\\s*:\\s*url\\([^)]*\\)",
                  paste0("background-image: url(", file_name, ")"),
                  css)
  writeLines(css_new, css_path)

  # Update JSON: only change the current logo, keep default_logo untouched
  meta <- if (fs::file_exists(meta_path)) jsonlite::fromJSON(meta_path) else list()
  meta$logo <- file_name
  meta$modified_time <- format(Sys.time(), tz = Sys.timezone(), usetz = TRUE)
  writeLines(jsonlite::toJSON(meta, auto_unbox = TRUE, pretty = TRUE), meta_path)
}

# vii) Helper function to update the colours
update_colors <- function(folder_html,
                          banner_colour = NULL,
                          callout_colours = NULL,
                          column_margin = NULL) {
  css_path <- file.path(folder_html, "styles.css")
  css <- readLines(css_path, warn = FALSE)

  if (!is.null(callout_colours)) {
    for (t in names(callout_colours)) {
      in_block <- FALSE
      for (i in seq_along(css)) {
        line <- css[i]
        # detect callout block start
        if (grepl(paste0("\\.callout-", t, "\\s*\\{"), line)) {
          in_block <- TRUE
        } else if (in_block && grepl("\\}", line)) {
          in_block <- FALSE
        }
        # update background-color in block
        if (in_block && grepl("background-color\\s*:", line)) {
          css[i] <- sub(
            "background-color\\s*:\\s*#[0-9A-Fa-f]+",
            paste0("background-color: ", callout_colours[[t]]$background),
            line
          )
        }
        # update header background-color
        if (grepl(paste0("\\.callout-", t, "\\s+\\.callout-header"), line)) {
          j <- i + 1
          while(j <= length(css) && !grepl("\\}", css[j])) {
            if (grepl("background-color\\s*:", css[j])) {
              css[j] <- sub(
                "background-color\\s*:\\s*#[0-9A-Fa-f]+",
                paste0("background-color: ", callout_colours[[t]]$header),
                css[j]
              )
            }
            j <- j + 1
          }
        }
      }
    }
    #writeLines(css, css_path)
  }

  # ---- Update column-margin ----
  if (!is.null(column_margin)) {
    # box
    start_box <- grep("^\\.column-margin > \\*\\s*\\{", css)
    if (length(start_box)) {
      end_box <- grep("^\\}", css)
      end_box <- end_box[end_box > start_box[1]][1]
      block_idx <- (start_box+1):(end_box-1)
      for (i in block_idx) {
        line <- css[i]
        if (grepl("border\\s*:", line) && !is.null(column_margin$box$border_color)) {
          css[i] <- sub("border\\s*:\\s*[^;]+;",
                        paste0("border: ", column_margin$box$border_width, "px solid ", column_margin$box$border_color, ";"),
                        line)
        }
        if (grepl("padding\\s*:", line) && !is.null(column_margin$box$padding)) {
          css[i] <- sub("padding\\s*:[^;]+;",
                        paste0("padding: ", column_margin$box$padding, "em;"),
                        line)
        }
        if (grepl("background-color\\s*:", line) && !is.null(column_margin$box$background_color)) {
          css[i] <- sub("background-color\\s*:[^;]+;",
                        paste0("background-color: ", column_margin$box$background_color, ";"),
                        line)
        }
      }
    }

    # header (::before)
    start_hdr <- grep("^\\.column-margin > \\*::before\\s*\\{", css)
    if (length(start_hdr)) {
      end_hdr <- grep("^\\}", css)
      end_hdr <- end_hdr[end_hdr > start_hdr[1]][1]
      block_idx <- (start_hdr+1):(end_hdr-1)
      for (i in block_idx) {
        line <- css[i]


        #########
        if (grepl("background-color\\s*:", line)) {
          cat("Line before substitution:", line, "\n")
          cat("Value to write:", column_margin$header$background_color, "\n")
        }
        ############


        if (grepl("background-color\\s*:", line) && nzchar(column_margin$header$background_color)) {
          css[i] <- sub("background-color\\s*:[^;]+;",
                        paste0("background-color: ", column_margin$header$background_color, ";"),
                        line)
          cat("Line after substitution:", css[i], "\n")   # DEBUG
        }
        if (grepl("color\\s*:", line) && !is.null(column_margin$header$text_color)) {
          css[i] <- sub("color\\s*:[^;]+;",
                        paste0("color: ", column_margin$header$text_color, ";"),
                        line)
        }
        if (grepl("padding\\s*:", line) && !is.null(column_margin$header$padding)) {
          css[i] <- sub("padding\\s*:[^;]+;",
                        paste0("padding: ", column_margin$header$padding, "em;"),
                        line)
        }
        if (grepl("content\\s*:", line) && !is.null(column_margin$header$content)) {
          css[i] <- sub("content\\s*:[^;]+;",
                        paste0("content: \"", column_margin$header$content, "\";"),
                        line)
        }
        if (grepl("font-weight\\s*:", line) && !is.null(column_margin$header$font_weight)) {
          css[i] <- sub("font-weight\\s*:[^;]+;",
                        paste0("font-weight: ", column_margin$header$font_weight, ";"),
                        line)
        }
      }
    }
  }

  # Write updated CSS
  writeLines(css, css_path)


  # update banner colour in template.qmd
  if (!is.null(banner_colour)) {
    qmd_path <- file.path(folder_html, "template.qmd")
    qmd <- readLines(qmd_path, warn = FALSE)
    qmd <- gsub(
      "^\\s*title-block-banner\\s*:\\s*.*",
      paste0("title-block-banner: \"", banner_colour, "\""),
      qmd
    )
    writeLines(qmd, qmd_path)
  }
}

# viii) Helper function to revert selections back to defaults (as stored in metadata file)
revert_defaults <- function(folder_html,
                            META_FILENAME,
                            session,
                            logo_file) {
  meta_path <- file.path(folder_html, META_FILENAME)
  if (!fs::file_exists(meta_path)) stop("JSON defaults not found")

  d <- jsonlite::fromJSON(meta_path)

  # ---- Update template.qmd ----
  qmd_path <- file.path(folder_html, "template.qmd")
  qmd <- readLines(qmd_path, warn = FALSE)
  qmd <- gsub("^\\s*title-block-banner\\s*:\\s*.*",
              paste0("title-block-banner: \"", d$banner_colour, "\""), qmd)
  writeLines(qmd, qmd_path)

  # ---- Update styles.css ----
  css_path <- file.path(folder_html, "styles.css")
  css <- readLines(css_path, warn = FALSE)
  css <- gsub("background-image\\s*:\\s*url\\([^)]*\\)",
              paste0("background-image: url(", d$default_logo, ")"), css)
  for (t in names(d$callout_colours)) {
    css <- gsub(paste0("(\\.callout-", t, "\\s*\\{[^}]*background-color:\\s*)([^;]+)"),
                paste0("\\1", d$callout_colours[[t]]$background), css)
    css <- gsub(paste0("(\\.callout-", t, "\\s+\\.callout-header\\s*\\{[^}]*background-color:\\s*)([^;]+)"),
                paste0("\\1", d$callout_colours[[t]]$header), css)
  }
  start_box <- grep("^\\.column-margin > \\*\\s*\\{", css)
  if (length(start_box)) {
    end_box <- grep("^\\}", css)
    end_box <- end_box[end_box > start_box[1]][1]
    block_idx <- (start_box+1):(end_box-1)
    for (i in block_idx) {
      line <- css[i]
      if (grepl("border\\s*:", line)) {
        css[i] <- sub("border\\s*:[^;]+;",
                      paste0("border: ", d$column_margin$box$border_width, "px solid ", d$column_margin$box$border_color, ";"),
                      line)
      }
      if (grepl("padding\\s*:", line)) {
        css[i] <- sub("padding\\s*:[^;]+;",
                      paste0("padding: ", d$column_margin$box$padding, "em;"),
                      line)
      }
      if (grepl("background-color\\s*:", line)) {
        css[i] <- sub("background-color\\s*:[^;]+;",
                      paste0("background-color: ", d$column_margin$box$background_color, ";"),
                      line)
      }
    }
  }
  # Reset column-margin header (::before)
  start_hdr <- grep("^\\.column-margin > \\*::before\\s*\\{", css)
  if (length(start_hdr)) {
    end_hdr <- grep("^\\}", css)
    end_hdr <- end_hdr[end_hdr > start_hdr[1]][1]
    block_idx <- (start_hdr+1):(end_hdr-1)
    for (i in block_idx) {
      line <- css[i]
      if (grepl("background-color\\s*:", line)) {
        css[i] <- sub("background-color\\s*:[^;]+;\\s*",
                      paste0("background-color: ", d$column_margin$header$background_color, ";"),
                      line)
      }
      if (grepl("color\\s*:", line)) {
        css[i] <- sub("color\\s*:[^;]+;",
                      paste0("color: ", d$column_margin$header$text_color, ";"),
                      line)
      }
      if (grepl("padding\\s*:", line)) {
        css[i] <- sub("padding\\s*:[^;]+;",
                      paste0("padding: ", d$column_margin$header$padding, "em;"),
                      line)
      }
      if (grepl("content\\s*:", line)) {
        css[i] <- sub("content\\s*:[^;]+;",
                      paste0("content: \"", d$column_margin$header$content, "\";"),
                      line)
      }
      if (grepl("font-weight\\s*:", line)) {
        css[i] <- sub("font-weight\\s*:[^;]+;",
                      paste0("font-weight: ", d$column_margin$header$font_weight, ";"),
                      line)
      }
    }
  }
  writeLines(css, css_path)

  # ---- Restore default logo PNG in _extensions and remove old uploaded logo ----
  folder_parent <- fs::path_norm(fs::path(folder_html, ".."))
  dest_parent <- file.path(folder_parent, d$default_logo)

  # Copy default logo from _extensions/html to _extensions
  src_logo <- file.path(folder_html, d$default_logo)
  if (fs::file_exists(src_logo)) {
    fs::file_copy(src_logo, dest_parent, overwrite = TRUE)
  }

  # Delete previous uploaded logo if different from default
  old_logo <- file.path(folder_parent, d$logo)
  if (fs::file_exists(old_logo) && d$logo != d$default_logo) {
    fs::file_delete(old_logo)
  }

  # ---- Update Shiny reactives/UI ----
  logo_file(d$default_logo)   # <- ensures the reactive points to default
  shiny::updateTextInput(session, "newname", value = d$default_logo)
  colourpicker::updateColourInput(session, "banner_colour", value = d$banner_colour)
  for (t in names(d$callout_colours)) {
    colourpicker::updateColourInput(session, paste0("col_", t, "_bg"), value = d$callout_colours[[t]]$background)
    colourpicker::updateColourInput(session, paste0("col_", t, "_header"), value = d$callout_colours[[t]]$header)
  }
  # Update column-margin UI
  shiny::updateNumericInput(session, "colmargin_border_width", value = d$column_margin$box$border_width)
  colourpicker::updateColourInput(session, "colmargin_border_color", value = d$column_margin$box$border_color)
  shiny::updateNumericInput(session, "colmargin_padding", value = d$column_margin$box$padding)
  colourpicker::updateColourInput(session, "colmargin_bg_color", value = d$column_margin$box$background_color)
  colourpicker::updateColourInput(session, "colmargin_header_bg", value = d$column_margin$header$background_color)
  colourpicker::updateColourInput(session, "colmargin_header_text", value = d$column_margin$header$text_color)
  shiny::updateNumericInput(session, "colmargin_header_padding", value = d$column_margin$header$padding)
  shiny::updateTextInput(session, "colmargin_header_content", value = d$column_margin$header$content)
  shiny::updateTextInput(session, "colmargin_header_weight", value = d$column_margin$header$font_weight)
}

get_active_logo <- function(folder, css_file = "styles.css") {
  css_path <- file.path(folder, css_file)
  if (!fs::file_exists(css_path)) return(NULL)

  css_lines <- readLines(css_path, warn = FALSE)
  bg_lines <- grep("background-image", css_lines, value = TRUE)
  if (length(bg_lines) == 0) return(NULL)

  logo_name <- sub('.*url\\(([^)]+)\\).*', '\\1', bg_lines[1])
  file.path(folder, logo_name)
}

# Helper: revert callout colours in a CSS file based on metadata
revert_callouts_css <- function(css_path, callout_colours) {
  css <- readLines(css_path, warn = FALSE)

  for (t in names(callout_colours)) {
    # Function to update a block (generalized)
    update_block <- function(pattern_start, new_value) {
      starts <- which(grepl(pattern_start, css, perl = TRUE))
      for (start in starts) {
        if (start < length(css)) {
          tail_idx <- seq.int(start + 1, length(css))
          brace_close_rel <- which(grepl("^\\s*\\}", css[tail_idx], perl = TRUE))
          block_end_rel <- if (length(brace_close_rel)) brace_close_rel[1] - 1 else length(tail_idx)
          if (block_end_rel >= 1) {
            block_lines_idx <- tail_idx[seq_len(block_end_rel)]
            bg_rel <- which(grepl("background-color\\s*:", css[block_lines_idx], perl = TRUE))
            if (length(bg_rel)) {
              idx <- block_lines_idx[bg_rel[1]]
              css[idx] <- sub("(background-color\\s*:\\s*)[^;]+", paste0("\\1", new_value), css[idx], perl = TRUE)
            }
          }
        }
      }
    }

    # Update background
    update_block(paste0("^\\s*\\.callout-", t, "\\s*\\{\\s*$"), callout_colours[[t]]$background)
    # Update header
    update_block(paste0("^\\s*\\.callout-", t, "\\s+\\.callout-header\\s*\\{\\s*$"), callout_colours[[t]]$header)
  }

  writeLines(css, css_path)
}

# Helper: update Shiny inputs for callouts
update_callout_inputs <- function(session, callout_colours) {
  for (t in names(callout_colours)) {
    colourpicker::updateColourInput(session, paste0("col_", t, "_bg"), value = callout_colours[[t]]$background)
    colourpicker::updateColourInput(session, paste0("col_", t, "_header"), value = callout_colours[[t]]$header)
  }
}


get_current_callouts <- function(input) {
  callouts <- lapply(c("note","tip","warning","important"), function(t) {
    list(
      background = input[[paste0("col_", t, "_bg")]],
      header = input[[paste0("col_", t, "_header")]]
    )
  })
  names(callouts) <- c("note","tip","warning","important")
  callouts
}

callouts_changed <- function(current, defaults) {
  any(sapply(names(current), function(t) {
    !identical(current[[t]]$background, defaults[[t]]$background) ||
      !identical(current[[t]]$header, defaults[[t]]$header)
  }))
}

get_column_margin <- function(input) {
  list(
    box = list(
      border_color = input$colmargin_border_color,
      border_width = input$colmargin_border_width,
      padding = input$colmargin_padding,
      background_color = input$colmargin_bg_color
    ),
    header = list(
      background_color = input$colmargin_header_bg,
      text_color = input$colmargin_header_text,
      padding = input$colmargin_header_padding,
      content = input$colmargin_header_content,
      font_weight = input$colmargin_header_weight
    )
  )
}

callout_ui <- function(callout_colours) {
  shiny::tagList(
    lapply(names(callout_colours), function(t) {
      shiny::wellPanel(
        shiny::h4(paste("Callout", t)),
        colourpicker::colourInput(
          paste0("col_", t, "_header"),
          "Header colour",
          value = callout_colours[[t]]$header
        ),
        colourpicker::colourInput(
          paste0("col_", t, "_bg"),
          "Background colour",
          value = callout_colours[[t]]$background
        )
      )
    })
  )
}
