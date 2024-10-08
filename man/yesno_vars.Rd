% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clean_REDCap.R
\name{yesno_vars}
\alias{yesno_vars}
\title{yesno_vars}
\usage{
yesno_vars(d)
}
\arguments{
\item{d}{a data frame object}
}
\value{
a character vector of colulumn that are factors with levels: \code{c("Yes", "No")}
}
\description{
yesno_vars
}
\examples{
  \dontrun{

dat <- tibble(var = factor(c("Yes", "Yes", "No", "Yes"), levels = c("Yes", "No")))

yesno_vars(dat)

mutate(dat, across(yesno_vars(dat), ~case_when(. == "Yes" ~ TRUE, . == "No" ~ FALSE, TRUE ~ NA)))

}

}
