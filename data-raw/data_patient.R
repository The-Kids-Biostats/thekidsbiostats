## code to prepare `data_patients` dataset goes here

data_patient <- data.frame(
  "Patient ID#"         = 101:105,
  "DOB [YYYY-MM-DD]"    = as.Date(c("1980-05-12", "1992-08-03", "1975-12-25", "2000-01-01", "1985-07-07")),
  "Sex (0=Male, 1=Female)" = c("0", "1", "1", "0", "1"),
  "WHAT IS YOUR HEIGHT? (cm)"         = c(175, 160, 180, 165, 170),
  "WHAT IS YOUR CURRENT WEIGHT? (kg)"         = c(70, 55, 80, 60, 75),
  "Do you currently smoke any form of tobacco products, including cigarettes, cigars, or pipes, on a regular basis?" = c(TRUE, FALSE, FALSE, TRUE, FALSE),
  "bp (mmHg)"           = c("120/80", "110/70", "130/85", "115/75", "125/82"),
  "Cholesterol / mmolL" = c(5.2, 4.8, 6.1, 5.0, 5.5),
  check.names = FALSE  # setting this to FALSE to highlight problems with bad names
  )

usethis::use_data(data_patient, overwrite = TRUE)
