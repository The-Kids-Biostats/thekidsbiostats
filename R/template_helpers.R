#' Allows modifying text within .html and .qmd report files
#'
#' Internal function for modify a .qmd file
#'
#' @param lines The lines read from the qmd file.
#' @param title The report Title
#' @param subtitle The report Subtitle
#' @param author The name of the author
#' @param affiliation The affiliation of the author
#' @param include_reproducibility Boolean controlling whether the Reproducibility Information Section is included.
#' @param echo Boolean controlling whether code is shown in the rendered report.
#' @param code_fold Boolean controlling whether shown code is folded by default.
#' @param code_tools Boolean controlling whether the code tools menu is included.
#' @return Modified lines to write out to new qmd file
#' @noRd
update_qmd_template <- function(lines, title = NULL, subtitle = NULL,
                                author = NULL, affiliation = NULL,
                                include_reproducibility = TRUE,
                                echo = FALSE, code_fold = TRUE, code_tools = TRUE) {

  # Title
  if (!is.null(title)) {
    lines <- sub('^title:.*$', paste0('title: "', title, '"'), lines)
  }

  # Subtitle
  if (!is.null(subtitle)) {
    lines <- sub('^subtitle:.*$', paste0('subtitle: "', subtitle, '"'), lines)
  }

  # Author name (usually inside 'author:\n  - name: "J Smith"')
  if (!is.null(author)) {
    lines <- sub('^(\\s*)name:.*$', paste0('\\1name: "', author, '"'), lines)
  }

  # Affiliation (multi-line block)
  if (!is.null(affiliation)) {
    aff_index <- grep("^\\s*affiliation:", lines)

    if (length(aff_index) == 1 && aff_index + 1 <= length(lines)) {
      lines[aff_index + 1] <- paste0('  - "', affiliation, '"')
    }
  }

  # Code chunk options (YAML keys; chunk-level '#|' options are left alone)
  lines <- sub('^(\\s*)echo:.*$', paste0('\\1echo: ', tolower(echo)), lines)
  lines <- sub('^(\\s*)code-fold:.*$', paste0('\\1code-fold: ', tolower(code_fold)), lines)
  lines <- sub('^(\\s*)code-tools:.*$', paste0('\\1code-tools: ', tolower(code_tools)), lines)

  # Remove reproducibility section if needed
  if (!include_reproducibility) {
    repro_start <- grep("^# Reproducibility Information", lines)
    if (length(repro_start) > 0) {
      # Remove through the closing ':::' of the callout wrapping the session info
      closers <- grep("^:::\\s*$", lines)
      block_end <- closers[closers > repro_start[1]][1]

      if (!is.na(block_end)) {
        lines <- lines[-(repro_start[1]:block_end)]
      }
    }
  }

  return(lines)
}


#' Internal function for modify a .html file
#'
#' @param lines The lines read from the html file.
#' @param title The report Title
#' @param subtitle The report Subtitle
#' @param author The name of the author
#' @param affiliation The affiliation of the author
#' @param include_reproducibility Boolean controlling whether the Reproducibility Information Section is included.
#' @param show_code Boolean controlling whether the analysis code chunk is shown. When FALSE the chunk is removed.
#' @param code_fold Boolean controlling whether shown code is collapsed. When FALSE the code is expanded.
#' @param code_tools Boolean controlling whether the code tools menu is included. When FALSE the menu is removed.
#'
#' @return Modified lines to write out to new qmd file
#' @noRd
update_html_template <- function(lines, title, subtitle, author, affiliation, include_reproducibility,
                                 show_code = TRUE, code_fold = TRUE, code_tools = TRUE) {
  # Replace the line with the title
  if (!is.null(title)) {
    lines <- sub('<h1 class="title">.*?</h1>',
                      sprintf('<h1 class="title">%s</h1>', title),
                      lines)
  }

  if (!is.null(subtitle)) {
    lines <- sub('<p class="subtitle lead">.*?</p>',
                      sprintf('<p class="subtitle lead">%s</p>', subtitle),
                      lines)
  }


  # Replace the line with the author
  if (!is.null(author)) {
    lines <- sub(
      pattern = '<p class="author">.*?</p>',
      replacement = sprintf('<p class="author">%s</p>', author),
      lines
    )
  }

  # Replace the line with the author
  # The affiliation element can span several lines, so replace the whole range
  if (!is.null(affiliation)) {
    start <- grep('<p class="affiliation">', lines, fixed = TRUE)
    if (length(start) == 1) {
      end <- start - 1 + which(grepl("</p>", lines[start:length(lines)], fixed = TRUE))[1]
      if (!is.na(end)) {
        lines <- c(lines[seq_len(start - 1)],
                   sprintf('<p class="affiliation">%s</p>', affiliation),
                   lines[-seq_len(end)])
      }
    }
  }

  if (!include_reproducibility) {
    # Remove every marked reproducibility block (TOC entry and section)
    starts <- grep("<!-- START REPRODUCIBILITY -->", lines)
    ends <- grep("<!-- END REPRODUCIBILITY -->", lines)
    keep <- rep(TRUE, length(lines))
    for (i in seq_len(min(length(starts), length(ends)))) {
      if (starts[i] < ends[i]) keep[starts[i]:ends[i]] <- FALSE
    }
    lines <- lines[keep]
  }

  # Analysis code chunk: remove when hidden (as Quarto does with echo: false)
  code_start <- grep('^<div class="cell">$', lines)
  code_start <- code_start[code_start < length(lines) & lines[code_start + 1] == '<details class="code-fold">']
  if (length(code_start) > 0) {
    start <- code_start[1]
    details_end <- which(lines == "</details>")
    details_end <- details_end[details_end > start][1]
    if (!is.na(details_end) && lines[details_end + 1] == "</div>") {
      if (!show_code) {
        lines <- lines[-(start:(details_end + 1))]
      } else if (!code_fold) {
        # Unfolded code has no <details> wrapper or summary in Quarto output
        lines[details_end] <- "</div>"
        lines[start + 1] <- '<div class="code-unfolded">'
        lines <- lines[-(start + 2)]  # drop the "Code" summary
      }
    }
  }

  # Code tools menu (dropdown in the title block)
  if (!code_tools) {
    lines <- sub('<button type="button" class="btn code-tools-button dropdown-toggle" id="quarto-code-tools-menu".*?</ul>',
                 "", lines)
  }

  return(lines)

}

render_preview <-  function(html_lines){

  # Save to temp file
  new_html <- tempfile(fileext = ".html")
  writeLines(html_lines, new_html)

  return(new_html)

}
