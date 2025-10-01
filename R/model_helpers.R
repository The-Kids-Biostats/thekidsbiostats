#' Generate Model Output for Specified Model Type
#'
#' This function identifies the type of the fitted model and chooses the appropriate
#' method to produce model output.
#'
#' @param model A fitted model object produced by \code{thekids_model} or another modeling function.
#' @param by The main predictor of interest.
#' @param data A data frame containing the variables to be used in the model.
#' @param ... Additional arguments passed to the output method for the specific model type.
#'
#' @return Output specific to the fitted model type, as determined by the appropriate
#'   output method (e.g., summary or custom output).
#'
#' @details
#' This function acts as a wrapper, delegating the call to the appropriate
#' output method based on the class of the model object. The actual behaviour
#' is determined by the specific method implementation for the model type.
#'
#' @import patchwork
#' @importFrom rlang .data
#'
#' @examples
#' # Assuming `model` is a fitted model object
#' # thekids_model_output(model)
#'
#' @export
thekids_model_output <- function(model, by = NULL, data = NULL, ...) {

  UseMethod("thekids_model_output", model)

}

#' Handle output for Linear Models
#'
#' Internal function to handle the output for objects of class \code{lm}.
#'
#' @param model A fitted linear model object of class \code{lm}.
#' @param by Required. The main predictor of interest. Behaviour will
#' differ when variable is continuous vs categorical
#' @param ... Additional arguments (currently unused).
#'
#' @details
#' Output derived from `mod_dat` which is supplied by `thekids_model`.
#'
#' @return A list of model-specific output.
#'
#' @method thekids_model_output lm
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.lm <- function(model, by, data = NULL, ...) {

  if (!requireNamespace("patchwork", quietly = TRUE)) {
    stop("The 'patchwork' package is required.")
  }

  if(is.null(data)) {
    mod_dat <- model$model
  } else mod_dat <- data

  y <- all.vars(stats::formula(model))[1]

  if(is.character(mod_dat[[by]]) | is.factor(mod_dat[[by]])) {
    mod_desc <- mod_dat %>%
      gtsummary::tbl_summary(by = by,
                  type = list(where(is.numeric) ~ "continuous"),
                  statistic = list(gtsummary::all_continuous() ~ "{mean} ({sd}) [{N_nonmiss}]")) %>%
      gtsummary::modify_header(label = by) %>%
      gtsummary::add_p() %>%
      gtsummary::bold_labels() %>%
      suppressMessages() %>% suppressWarnings()

    mod_desc_plot <- mod_dat %>%
      dplyr::mutate(x = factor(.data[[by]])) %>%
      ggplot2::ggplot(ggplot2::aes(x = .data$x, y = .data[[y]],
                 colour = .data$x, group = .data$x, fill = .data$x)) +
      ggplot2::geom_violin(alpha = 0.1, width = 0.5) +
      ggplot2::geom_jitter(height = 0, width = 0.05, alpha = 0.3) +
      ggplot2::stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.05, colour = "red") +
      ggplot2::stat_summary(fun = mean, colour = "red", geom="point", size = 4) +
      ggplot2::stat_summary(fun = mean, colour = "black", geom="point", size = 3, shape = 4) +
      thekids_theme() +
      ggplot2::theme(plot.caption = ggplot2::element_text(size = 12, face = "italic"),
            legend.position = "none") +
      ggplot2::labs(title = "Jittered dot and violin distribution plot",
           subtitle = paste0(y, " plotted by ", by),
           caption = "Black 'X' on red circle indicates mean (\u00B1SE)",
           x = by)
  } else {
    mod_desc <- mod_dat %>%
      gtsummary::tbl_summary(type = list(where(is.numeric) ~ "continuous"),
                  statistic = list(gtsummary::all_continuous() ~ "{mean} ({sd}) [{N_nonmiss}]")) %>%
      gtsummary::bold_labels() %>%
      suppressMessages() %>% suppressWarnings()

    mod_desc_plot <- mod_dat %>%
      dplyr::mutate(x = .data[[by]]) %>%
      ggplot2::ggplot(aes(x = .data$x, y = .data[[y]])) +
      ggplot2::geom_jitter(width = 0.05, height = 0.05, alpha = 0.5, size = 3,col = thekidsbiostats::thekids_colours[[3]]) +
      ggplot2::geom_smooth(fill = thekidsbiostats::thekids_colours[[1]], col = thekidsbiostats::thekids_colours[[1]],
                  method = "lm") +
      thekids_theme() +
      ggplot2::theme(plot.caption = ggplot2::element_text(size = 12, face = "italic"),
            legend.position = "none") +
      ggplot2::labs(title = "Scatterplot with line of best bit (method = \"lm\")",
           subtitle = paste0(y, " plotted by ", by),
           x = by)
  }

  mod_diag <- ggfortify:::autoplot.lm(model)

  mod_diag <- purrr::map(mod_diag, function(p) p + thekids_theme())

  mod_diag <- patchwork::wrap_plots((mod_diag[[1]] + mod_diag[[2]]) / (mod_diag[[3]] + mod_diag[[4]]),
                                    ncol = 1)

  mod_output <- model %>%
    gtsummary::tbl_regression(intercept = T,
                   estimate_fun = function(x) gtsummary::style_number(x, digits = 1),
                   pvalue_fun = function(x) gtsummary::style_number(x, digits = 3)) %>%
    gtsummary::modify_column_merge(
      pattern = "{estimate} ({conf.low}, {conf.high})",
      rows = !is.na(.data$estimate)
    )


  return(list(mod_dat = mod_dat,
              mod_desc = mod_desc,
              mod_desc_plot = mod_desc_plot,
              mod_diag = mod_diag,
              model = model,
              mod_output = mod_output))
}

#' Handle Output for Negative Binomial Models
#'
#' Internal function to handle the output for objects of class \code{negbin}.
#'
#' @param model A fitted negative binomial model object of class \code{negbin}.
#' @param ... Additional arguments (currently unused).
#'
#' @return A list of model-specific output.
#'
#' @method thekids_model_output negbin
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.negbin <- function(model, ...) {
  print(paste("Model class:", class(model)))
}

#' Handle Output for Quantile Regression Models
#'
#' Internal function to handle the output for objects of class \code{rq}.
#'
#' @param model A fitted quantile regression model object of class \code{rq}.
#' @param ... Additional arguments (currently unused).
#'
#' @return A list of model-specific output.
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.rq <- function(model, ...) {
  print(paste("Model class:", class(model)))
}

#' Handle Output for Unsupported Model Types
#'
#' Internal function to handle cases where the model type is unsupported.
#'
#' @param model A model object of an unsupported class.
#' @param ... Additional arguments (currently unused).
#'
#' @return Stops execution with an error message indicating the unsupported model type.
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.default <- function(model, ...) {
  stop("Unsupported model type: ", class(model))
}


