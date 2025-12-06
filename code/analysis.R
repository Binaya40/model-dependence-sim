library(tidyverse)
library(ggplot2)
library(sandwich)
library(lmtest)
library(broom)
library(dplyr)

data_file <- "training_data.csv"
data <- read_csv(data_file, show_col_types = FALSE)

# Run the Analyses ---

# Baseline Model: We assume this model to capture the true effect
m1 <- lm(ln_y ~ T + ln_x1 + x2 + x3 + x4 + x6, data = data)
r1 <- coeftest(m1, vcov = vcovHC(m1, type = "HC1"))

# Source 1: Omitted Variable Bias (x3 - Female)
m2 <- lm(ln_y ~ T + ln_x1 + x2 + x4 + x6, data = data)
r2 <- coeftest(m2, vcov = vcovHC(m2, type = "HC1"))

# Source 2: Interaction / Heterogeneity
m3 <- lm(ln_y ~ T + ln_x1 + x2 + x3 + x4 + T*x4 + x6, data = data)
r3 <- coeftest(m3, vcov = vcovHC(m3, type = "HC1"))

# Source 3: Measurement Error
m4 <- lm(ln_y ~ T + ln_x1 + x5 + x3 + x4 + x6, data = data) # Using mismeasured x5
r4 <- coeftest(m4, vcov = vcovHC(m4, type = "HC1"))

# Source 4A: Sample Composition (Urban vs. Full)
m5 <- lm(ln_y ~ T + ln_x1 + x2 + x3 + x4, data = data, subset = data$x6 == 1) # Urban only
r5 <- coeftest(m5, vcov = vcovHC(m5, type = "HC1"))

# Source 4B: Selection Bias
m6 <- lm(ln_y ~ T + ln_x1 + x2 + x3 + x4 + x6, data = data, subset = data$S == 1) # Selected sample only
r6 <- coeftest(m6, vcov = vcovHC(m6, type = "HC1"))

# Tidy each model and combine them, adding the model name
all_models_data <- bind_rows(
  tidy(r1) %>% mutate(model = "Baseline Model"),
  tidy(r2) %>% mutate(model = "Omitted Variable Bias"),
  tidy(r3) %>% mutate(model = "With Interaction Term"),
  tidy(r4) %>% mutate(model = "Measurement Error"),
  tidy(r5) %>% mutate(model = "Sub Sample (Urban)"),
  tidy(r6) %>% mutate(model = "Selected Bias")
)

# Filter for only the 'T' coefficient
T_coef_data <- all_models_data %>%
  filter(term == "T") %>%
  # Rename the model variable and reorder for the plot
  mutate(
    model = factor(model, levels = rev(c("Baseline Model", "Omitted Variable Bias", "With Interaction Term", 
                                         "Measurement Error", "Sub Sample (Urban)", "Selected Bias"))),
    
    # For fixest, broom uses std.error. We calculate 95% CIs manually:
    conf.low = estimate - 1.96 * std.error,
    conf.high = estimate + 1.96 * std.error,

    # Create the label for the point estimate (centered)
    center_label = format(round(estimate, 3), nsmall = 3),

    # Create the label for the lower CI bound (left arm)
    low_label = format(round(conf.low, 3), nsmall = 3),

    # Create the label for the upper CI bound (right arm)
    high_label = format(round(conf.high, 3), nsmall = 3)

  )

# Define a general font size
base_font_size <- 12

coef_plot <- ggplot(T_coef_data, aes(x = estimate, y = model)) +

  # Error Bars
  geom_errorbar(
    aes(xmin = conf.low, xmax = conf.high),
    width = 0.3, 
    linewidth = 1, 
    orientation = "y",
    color = "#1f78b4" 
  ) +

  # Point Estimates
  geom_point(size = 4, color = "#1f78b4") +

  # Add Numerical Labels
  geom_text(
    aes(label = low_label, x = conf.low),
    vjust = -2, 
    size = base_font_size * 0.35,
    color = "black"
  ) +
  geom_text(
    aes(label = center_label, x = estimate),
    vjust = -2, 
    size = base_font_size * 0.35,
    fontface = "bold",
    color = "black"
  ) +
  geom_text(
    aes(label = high_label, x = conf.high),
    vjust = -2, 
    size = base_font_size * 0.35,
    color = "black"
  ) +

  # Labels and Titles
  labs(
    x = "Treatment Effect with 95% CI",
    y = NULL
  ) +

  # Final Design 
  theme_gray(base_size = base_font_size) + 
  theme(
    axis.text = element_text(size = base_font_size * 1.1),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "gray", fill = NA, linewidth = 0.5),
    plot.margin = unit(c(1, 1, 1, 1), "cm")
  )

# Display the final plot
print(coef_plot)

ggsave(
  filename = "tcoeff.png", 
  plot = coef_plot,             
  device = "png",                            
  width = 8,                                 
  height = 6,                               
  dpi = 300                                  
)