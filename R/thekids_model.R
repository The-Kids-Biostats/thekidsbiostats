#' Fit a Statistical Model and Pass to Output Handler
#'
#' This function fits a statistical model to the given dataset using a specified formula
#' based on the dependent (`y`) and independent (`x` and `formula`) variables.
#' After fitting, the model is passed to a dedicated output handler (`thekids_model_output`)
#' for further processing or customization. Supported model types include linear regression,
#' negative binomial regression, and quantile regression.
#'
#' @param data A data frame containing the variables to be used in the model.
#' @param y Character string specifying the name of the dependent variable.
#' @param x Character string specifying the name of the primary independent variable.
#' @param formula Optional character string specifying additional terms to include in the formula.
#'   If not provided, the formula will be auto-generated as \code{y ~ x}.
#' @param model Character string specifying the type of model to fit.
#'   Currently supported are \code{"linear"}, \code{"negbin"}, or \code{"quantile"}.
#' @param ... Additional arguments passed to the underlying modeling functions.
#'
#' @return Model output relating to the appropriate modeling function
#'   (e.g., \code{\link[stats]{lm}}, \code{\link[MASS]{glm.nb}}, or \code{\link[quantreg]{rq}}).
#'   This is the same object returned by \code{\link{thekids_model_output}} if the latter is
#'   called directly.
#'
#' @details
#' This function validates the specified model type and constructs a formula based
#' on the supplied arguments. The data is reduced to complete cases for the
#' variables included in the formula before fitting the model. The fitted model
#' is passed to \code{\link{thekids_model_output}} for further handling, allowing
#' for streamlined customization of model outputs.
#'
#' For a more thorough example, see the \href{../doc/model_output.html}{vignette}.
#'
#' @examples
#' # Example 1: Linear model
#' data(mtcars)
#' thekids_model(mtcars, y = "mpg", x = "wt", model = "linear")
#'
#' # Example 2: Linear model with factor
#' thekids_model(mtcars %>% mutate(cyl = as.factor(cyl)), y = "mpg", x = "cyl", model = "linear")
#'
#' # Example 3: Quantile regression
#' library(quantreg)
#' data(engel)
#' thekids_model(engel, y = "foodexp", x = "income", model = "quantile", tau = 0.5)
#'
#' @seealso \code{\link{thekids_model_output}}
#'
#' @export
thekids_model <- function(data, y, x, formula = "", model = "linear", ...){

  # Check for valid model
  if(!model %in% c(
    "linear"#,
    # "negbin",
    # "quantile",
    # "ordinal"
    )) {
    stop("Model type not yet supported.")
  }

  # Create formula from y, x, and formula arguments
  if(formula == ""){
    form <- as.formula(paste0("`", y, "` ~ `", x, "`"))
  } else {
    form <- as.formula(paste0("`", y, "` ~ `", x, "` + ", formula))
  }

  # Reduce data to only columns used in analysis and only complete-case rows.
  vars <- formula %>%
    str_split("\\+") %>%
    flatten_chr() %>%
    str_trim()

  dat_mod <- data %>%
    select({{y}}, {{x}}, any_of(vars)) %>%
    na.omit()

  # Run model
  if(model == "linear") {
    mod <- lm(formula = form, data = dat_mod, ...)
  }
  if(model == "negbin") {
    mod <- MASS::glm.nb(formula = form, data = dat_mod, ...)
  }
  if(model == "quantile") {
    mod <- quantreg::rq(formula = form, data = dat_mod, ...)
  }
  if(model == "ordinal") {
    mod <- ordinal::clm(formula = form, data = dat_mod, ...)
  }

  thekids_model_output(mod, by = x, dat_mod, ...)
}


