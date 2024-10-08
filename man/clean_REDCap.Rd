% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clean_REDCap.R
\name{clean_REDCap}
\alias{clean_REDCap}
\title{clean_REDCap}
\usage{
clean_REDCap(
  d,
  dict,
  numeric_date = FALSE,
  yesno_to_bool = FALSE,
  quiet = FALSE
)
}
\arguments{
\item{d}{REDCap (data frame)}

\item{dict}{REDCap data dictionary (data frame)}

\item{numeric_date}{(default FALSE) set to TRUE if MS Excel has \emph{helpfully} converted to a numeric date}

\item{yesno_to_bool}{(default FALSE) convert factors with levels \code{c("Yes", "No")} to logical objects?}

\item{quiet}{(default FALSE) pass quiet argument to lubridate functions}
}
\value{
cleaned data frame
}
\description{
Clean a REDCap extract by applyly factor levels and convert column classes
per the REDCap data dictionary.
}
\examples{
\dontrun{

dat <- tibble(var = c("0", "1"))

dictionary <- tibble(`Variable / Field Name` = "var",
  `Field Type` = "radio",
  `Field Label` = "Label",
  `Choices, Calculations, OR Slider Labels` = "0, No | 1, Yes",
  `Text Validation Type OR Show Slider Number` = NA)

(dat_clean <- clean_REDCap(dat, dictionary))

}

}
