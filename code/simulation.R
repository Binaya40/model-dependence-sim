library(dplyr)
set.seed(4242)

# Define Parameters and True Causal Effects ---
N <- 2000 

# True Causal Effect (tau_0) for the reference group (Unmarried, X4=0)
tau_0 <- 0.20 
# Interaction Effect (gamma) - large and positive for Married (X4=1)
gamma <- 0.30 
# True Causal Effect for Married group (X4=1)
tau_1 <- tau_0 + gamma 

# Coefficients for covariates in the outcome equation (ln(Y))
beta_1 <- 0.30 # Effect of baseline earnings (X1)
beta_2 <- 0.05 # Effect of true schooling (X2) - strong confounder
beta_3 <- -0.15 # Effect of Female (X3) - negative and strong confounder
beta_4 <- 0.05 # Effect of Married (X4)
beta_5 <- 0.05 # Effect of Urban (X6)
intercept <- 6.0

# Generate Baseline Covariates ---

data <- tibble(
  id = 1:N,
  
  # X1: Baseline monthly earnings (log-normal distribution)
  ln_x1 = rnorm(N, mean = 3.5, sd = 0.3),
  
  # X3: Female indicator (50/50 split)
  x3 = rbinom(N, 1, 0.5),
  
  # X4: Married indicator (60% married)
  x4 = rbinom(N, 1, 0.6),
  
  # X6: Urban indicator (70% urban)
  x6 = rbinom(N, 1, 0.7),
  
  # X2: Actual Years of schooling (discrete, highly multimodal 0-20)
  # Mix of distributions to create multimodal data:
  x2 = round(
    case_when(
      runif(N) < 0.30 ~ rnorm(N, 9, 2),   # High School
      runif(N) < 0.65 ~ rnorm(N, 13, 1),  # Some College
      TRUE ~ rnorm(N, 16, 2)              # College Degree
    )
  ) %>% pmax(0) %>% pmin(20) # Bounded at 0-20
)

# Generate Treatment Assignment (T)

# T is non-random, driven by observed covariates (selection-on-observables)
# CRITICAL: We ensure T is strongly correlated with X3 (Female) to set up OVB.
# Women (X3=1) are more likely to attend training.

logit_t <- -2.5 + # Intercept for low baseline probability
  0.5 * data$ln_x1 + # Higher baseline earnings -> slightly more likely
  0.2 * data$x2 + # More schooling -> more likely
  1.5 * data$x3 - # **STRONG positive effect of X3 (Female)**
  0.5 * data$x4 + # Married -> slightly less likely
  0.5 * data$x6 # Urban -> more likely

prob_t <- 1 / (1 + exp(-logit_t))
data$T <- rbinom(N, 1, prob_t)

# Generate the Outcome Variable (Y)

# Log-normal outcome with heterogeneous truth
# CRITICAL: Include the interaction T * X4 to model heterogeneity.
# Married (X4=1) get the larger effect (tau_0 + gamma).

# Structural equation for ln(Y)
ln_y_potential <- intercept + 
  tau_0 * data$T + 
  beta_1 * data$ln_x1 +
  beta_2 * data$x2 +
  beta_3 * data$x3 + 
  beta_4 * data$x4 +
  beta_5 * data$x6 +
  gamma * (data$T * data$x4)

# Error term (heterogenous truth setup: error magnitude depends on treatment/urban status)
# This slightly complicates the error but makes the data more realistic.
# Standard deviation of 0.5 to keep effects visible.
error <- rnorm(N, 0, 0.5) 
data$ln_y <- ln_y_potential + error 
data$y <- exp(data$ln_y) # Monthly earnings


# Generate Measurement Error Variable (X5)

# X5: Self-reported Years of Schooling. Noisy proxy for X2.
# Noise: Positive mean measurement error (integer error).
data$x5 <- data$x2 + 
  round(rnorm(N, mean = 2, sd = 3)) %>% pmax(-data$x2) # Ensure X5 is non-negative
data$x5 <- data$x5 %>% pmin(20) %>% pmax(0)

# Generate Selection Indicator (S) for Selection Bias

# S: Observed selection/follow-up indicator (S=1 if observed in analysis)
# CRITICAL: Selection depends on T AND the outcome potential (e.g., higher X1/X2, or T=1).
# We simulate a selection process that favors treated units (T=1) and those with higher baseline earnings (X1).
logit_s <- -1.0 + # Intercept for selection probability
  1.0 * data$T + # Treated units are highly likely to be observed/follow-up
  0.5 * data$ln_x1 + # Higher baseline earnings -> more likely to be selected
  0.1 * data$x2 - 
  0.5 * data$x3 +
  0.5 * data$x6

prob_s <- 1 / (1 + exp(-logit_s))
data$S <- rbinom(N, 1, prob_s) # S=1 means observed in the dataset (Selection Bias scenario)

# Save CSV
write.csv(data, "tdata.csv", row.names = FALSE)