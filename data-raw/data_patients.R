# ## code to prepare `data_patients` dataset goes here

# data_patient <- data.frame(
#   "Patient ID#"         = 101:105,
#   "DOB [YYYY-MM-DD]"    = as.Date(c("1980-05-12", "1992-08-03", "1975-12-25", "2000-01-01", "1985-07-07")),
#   "Sex (0=Male, 1=Female)" = c("0", "1", "1", "0", "1"),
#   "WHAT IS YOUR HEIGHT? (cm)"         = c(175, 160, 180, 165, 170),
#   "WHAT IS YOUR CURRENT WEIGHT? (kg)"         = c(70, 55, 80, 60, 75),
#   "Do you currently smoke any form of tobacco products, including cigarettes, cigars, or pipes, on a regular basis?" = c(TRUE, FALSE, FALSE, TRUE, FALSE),
#   "bp (mmHg)"           = c("120/80", "110/70", "130/85", "115/75", "125/82"),
#   "Cholesterol / mmolL" = c(5.2, 4.8, 6.1, 5.0, 5.5),
#   check.names = FALSE  # setting this to FALSE to highlight problems with bad names
#   )

# usethis::use_data(data_patient, overwrite = TRUE)


# Mock blood pressure trial dataset ------------------------------------------
set.seed(2026)
n <- 120

# Identifiers & design
patient_id <- sprintf("BP-%03d", seq_len(n))
site <- sample(c("Perth", "Sydney", "Melbourne", "Brisbane"), n,
               replace = TRUE, prob = c(0.35, 0.25, 0.25, 0.15))

treatment <- sample(rep(c("Control", "5 mg/day", "10 mg/day"), each = n / 3))
treatment <- factor(treatment, levels = c("Control", "5 mg/day", "10 mg/day"))
rand_date <- as.Date("2025-02-01") + sample(0:240, n, replace = TRUE)

# Covariates
age <- pmin(pmax(round(rnorm(n, 58, 10)), 30), 85)
sex <- sample(c("Female", "Male"), n, replace = TRUE)

# Height (cm) depends on sex; weight (kg) is derived from height and a latent BMI
height <- round(ifelse(sex == "Male", rnorm(n, 176, 7), rnorm(n, 163, 6.5)), 1)
bmi_latent <- rnorm(n, 29, 4.5)  # internal only
weight <- round(bmi_latent * (height / 100)^2, 1)
bmi <- weight / (height / 100)^2  # used for the simulation, not output

smoking <- sample(c("Never", "Former", "Current"), n,
                     replace = TRUE, prob = c(0.5, 0.3, 0.2))
diabetes <- rbinom(n, 1, plogis(-1.6 + 0.08 * (bmi - 29) + 0.03 * (age - 58)))
chol_total <- round(rnorm(n, 5.2, 0.9), 1)                       # mmol/L
egfr <- round(pmin(rnorm(n, 85 - 0.5 * (age - 58), 15), 120))
heart_rate <- round(rnorm(n, 72, 9))

# Sex-specific treatment effects (mmHg reduction vs Control) -----------------
#                 Control  Low dose  High dose
sbp_effect_male   <- c(0,   -8,      -14)
sbp_effect_female <- c(0,   -1,       -2)    # marginal
dbp_effect_male   <- c(0,   -3,       -5)
dbp_effect_female <- c(0,   -0.5,     -1)

dose_idx <- as.integer(treatment) # 1 = Control, 2 = Low, 3 = High
sbp_effect <- ifelse(sex == "Male", sbp_effect_male[dose_idx], sbp_effect_female[dose_idx])
dbp_effect <- ifelse(sex == "Male", dbp_effect_male[dose_idx], dbp_effect_female[dose_idx])

# Outcomes: baseline and week 12
sbp_base <- round(150 + 0.4 * (age - 58) + 0.8 * (bmi - 29) + 4 * diabetes + rnorm(n, 0, 10))
dbp_base <- round(0.55 * sbp_base + rnorm(n, 10, 5))
sbp_wk12 <- round(sbp_base - 5 + sbp_effect + rnorm(n, 0, 8))
dbp_wk12 <- round(dbp_base - 2 + dbp_effect + rnorm(n, 0, 5))

# The outlier: one patient with an extreme baseline SBP
outlier_row <- 47
sbp_base[outlier_row] <- 262

# Clean version ---------------------------------------------------------------
patients <- data.frame(
  patient_id     = patient_id,
  site           = site,
  treatment      = treatment,
  rand_date      = rand_date,
  age            = age,
  sex            = sex,
  height_cm      = height,
  weight_kg      = weight,
  smoking_status = smoking,
  diabetes       = ifelse(diabetes == 1, "Y", "N"),
  chol_total     = chol_total,
  egfr           = egfr,
  heart_rate     = heart_rate,
  sbp_baseline   = sbp_base,
  dbp_baseline   = dbp_base,
  sbp_week12     = sbp_wk12,
  dbp_week12     = dbp_wk12,
  stringsAsFactors = FALSE
)

raw_names <- c(
  patient_id     = "Patient ID",
  site           = "Site Name",
  treatment      = "trt_grp",
  rand_date      = "randomisation date",
  age            = "AGE_yrs",
  sex            = "Sex",
  height_cm      = "Height (cm)",
  weight_kg      = "WEIGHT_kg",
  smoking_status = "Do you smoke any form of tabacco product?",
  diabetes       = "Diabetes (Y/N)",
  chol_total     = "Cholesterol-Total",
  egfr           = "eGFR",
  heart_rate     = "HR_bpm",
  sbp_baseline   = "SBP_baseline_mmHg",
  dbp_baseline   = "DBP Baseline (mmHg)",
  sbp_week12     = "sbp.wk12",
  dbp_week12     = "DBP_Week12"
)

stopifnot(identical(names(raw_names), names(patients))) 

patients_raw <- patients
names(patients_raw) <- unname(raw_names[names(patients)])

usethis::use_data(patients, patients_raw, overwrite = TRUE)
