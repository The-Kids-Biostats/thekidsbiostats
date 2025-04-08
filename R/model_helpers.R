#' Generate Model Output for Specified Model Type
#'
#' This function identifies the type of the fitted model and chooses the appropriate
#' method to produce model output.
#'
#' @param model A fitted model object produced by \code{thekids_model} or another modeling function.
#' @param ... Additional arguments passed to the output method for the specific model type.
#'
#' @return Output specific to the fitted model type, as determined by the appropriate
#'   output method (e.g., summary or custom output).
#'
#' @details
#' This function acts as a wrapper, delegating the call to the appropriate
#' output method based on the class of the model object. The actual behavior
#' is determined by the specific method implementation for the model type.
#'
#' @import patchwork
#'
#' @examples
#' # Assuming `mod` is a fitted model object
#' # thekids_model_output(mod)
#'
#' @export
thekids_model_output <- function(model, ...) {

  UseMethod("thekids_model_output", model)

}

#' Handle output for Linear Models
#'
#' Internal function to handle the output for objects of class \code{lm}.
#'
#' @param mod A fitted linear model object of class \code{lm}.
#' @param by Required. The main predictor of interest. Behaviour will
#' differ when variable is continuous vs categorical
#' @param mod_dat The data used to fit the model, passed from thekids_model
#' @param ... Additional arguments (currently unused).
#'
#' @return A list of model-specific output.
#'
#' @method thekids_model_output lm
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.lm <- function(mod, by, data = NULL, ...) {

  if(is.null(data)) {
    mod_dat <- mod$model
  } else mod_dat <- data

  y <- all.vars(formula(mod))[1]

  if(is.character(mod_dat[[by]]) | is.factor(mod_dat[[by]])) {
    mod_desc <- mod_dat %>%
      tbl_summary(by = by,
                  type = list(where(is.numeric) ~ "continuous"),
                  statistic = list(all_continuous() ~ "{mean} ({sd}) [{N_nonmiss}]")) %>%
      modify_header(label = by) %>%
      add_p() %>%
      bold_labels() %>%
      suppressMessages() %>% suppressWarnings()

    mod_desc_plot <- mod_dat %>%
      mutate(x = factor(.[[by]])) %>%
      ggplot(aes(x = x, y = .data[[y]],
                 colour = x, group = x, fill = x)) +
      geom_violin(alpha = 0.1, width = 0.5) +
      geom_jitter(height = 0, width = 0.05, alpha = 0.3) +
      stat_summary(fun.data = mean_se, geom = "errorbar", width = 0.05, colour = "red") +
      stat_summary(fun = mean, colour = "red", geom="point", size = 4) +
      stat_summary(fun = mean, colour = "black", geom="point", size = 3, shape = 4) +
      thekids_theme() +
      theme(plot.caption = element_text(size = 12, face = "italic"),
            legend.position = "none") +
      labs(title = "Jittered dot and violin distribution plot",
           subtitle = paste0(y, " plotted by ", by),
           caption = "Black 'X' on red circle indicates mean (±SE)",
           x = by)
  } else {
    mod_desc <- mod_dat %>%
      tbl_summary(type = list(where(is.numeric) ~ "continuous"),
                  statistic = list(all_continuous() ~ "{mean} ({sd}) [{N_nonmiss}]")) %>%
      bold_labels() %>%
      suppressMessages() %>% suppressWarnings()

    mod_desc_plot <- mod_dat %>%
      mutate(x = .[[by]]) %>%
      ggplot(aes(x = x, y = .data[[y]])) +
      geom_jitter(width = 0.05, height = 0.05, alpha = 0.5, size = 3,col = thekids_colours[[3]]) +
      geom_smooth(fill = thekids_colours[[1]], col = thekids_colours[[1]],
                  method = "lm") +
      thekids_theme() +
      theme(plot.caption = element_text(size = 12, face = "italic"),
            legend.position = "none") +
      labs(title = "Scatterplot with line of best bit (method = \"lm\")",
           subtitle = paste0(y, " plotted by ", by),
           x = by)
  }

  mod_diag <- ggfortify:::autoplot.lm(mod)

  mod_diag <- map(mod_diag, ~. + thekids_theme())

  library(patchwork)
  mod_diag <- (mod_diag[[1]] + mod_diag[[2]]) /
    (mod_diag[[3]] + mod_diag[[4]])

  mod_output <- mod %>%
    tbl_regression(intercept = T,
                   estimate_fun = function(x) style_number(x, digits = 1),
                   pvalue_fun = function(x) style_number(x, digits = 3)) %>%
    modify_column_merge(
      pattern = "{estimate} ({conf.low}, {conf.high})",
      rows = !is.na(estimate)
    )


  return(list(mod_dat = mod_dat,
              mod_desc = mod_desc,
              mod_desc_plot = mod_desc_plot,
              mod_diag = mod_diag,
              mod = mod,
              mod_output = mod_output))
}

#' Handle Output for Negative Binomial Models
#'
#' Internal function to handle the output for objects of class \code{negbin}.
#'
#' @param mod A fitted negative binomial model object of class \code{negbin}.
#' @param ... Additional arguments (currently unused).
#'
#' @return A list of model-specific output.
#'
#' @method thekids_model_output negbin
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.negbin <- function(mod, ...) {
  print(paste("Model class:", class(mod)))
}

#' Handle Output for Quantile Regression Models
#'
#' Internal function to handle the output for objects of class \code{rq}.
#'
#' @param mod A fitted quantile regression model object of class \code{rq}.
#' @param ... Additional arguments (currently unused).
#'
#' @return A list of model-specific output.
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.rq <- function(mod, ...) {
  print(paste("Model class:", class(mod)))
}

#' Handle Output for Unsupported Model Types
#'
#' Internal function to handle cases where the model type is unsupported.
#'
#' @param mod A model object of an unsupported class.
#' @param ... Additional arguments (currently unused).
#'
#' @return Stops execution with an error message indicating the unsupported model type.
#'
#' @keywords internal
#'
#' @exportS3Method thekidsbiostats::thekids_model_output
thekids_model_output.default <- function(mod, ...) {
  stop("Unsupported model type: ", class(mod))
}


