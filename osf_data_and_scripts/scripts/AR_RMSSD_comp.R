set.seed(789)  # for reproducibility

n <- 100  # number of time points

simulate_mood <- function(ar_coeff = 0.8, noise_sd = 1) {
  arima.sim(n = n, model = list(ar = ar_coeff), sd = noise_sd)
}

# Scenarios
mood_HighAR_HighRMSSD <- simulate_mood(ar_coeff = 0.9, noise_sd = 2)  # strong inertia + big changes
mood_HighAR_LowRMSSD  <- simulate_mood(ar_coeff = 0.9, noise_sd = 0.5)  # strong inertia + small changes
mood_LowAR_HighRMSSD  <- simulate_mood(ar_coeff = 0.1, noise_sd = 2)  # weak inertia + big changes
mood_LowAR_LowRMSSD   <- simulate_mood(ar_coeff = 0.1, noise_sd = 0.5)  # weak inertia + small changes

# Combine into data frame for plotting
library(tibble)
library(ggplot2)
df <- tibble(
  time = rep(1:n, 4),
  mood = c(mood_HighAR_HighRMSSD, mood_LowAR_HighRMSSD, mood_HighAR_LowRMSSD,mood_LowAR_LowRMSSD),
  condition = rep(c("High AR + High RMSSD", "Low AR + High RMSSD", "High AR + Low RMSSD", 
                    "Low AR + Low RMSSD"), each = n)
)

# Plot
ggplot(df, aes(x = time, y = mood, color = condition)) +
  geom_line() +
  facet_wrap(~condition, ncol = 2) +
  theme_minimal() +
  labs(title = "Simulated Mood Time Series",
       y = "Mood",
       x = "Time")



######## RMSSD and SE

set.seed(123)

library(tibble)
library(ggplot2)

n <- 100

# Function to compute RMSSD
rmssd <- function(x) {
  sqrt(mean(diff(x)^2))
}

# Function to compute SE
se <- function(x) {
  sd(x) / sqrt(length(x))
}

# Generate time series
# High RMSSD: random noise around 0
high_rmssd <- rnorm(n, mean = 0, sd = 1)

# Low RMSSD: smooth drift using cumulative sum of small noise
low_rmssd <- cumsum(rnorm(n, mean = 0, sd = 0.2))
low_rmssd <- scale(low_rmssd) * sd(high_rmssd)  # standardize to match SD

# Check that they have similar SE but different RMSSD
metrics <- tibble(
  Series = c("High RMSSD", "Low RMSSD"),
  RMSSD = c(rmssd(high_rmssd), rmssd(low_rmssd)),
  SE = c(se(high_rmssd), se(low_rmssd))
)

print(metrics)

# Combine for plotting
df <- tibble(
  time = rep(1:n, 2),
  mood = c(high_rmssd, low_rmssd),
  series = rep(c("High RMSSD", "Low RMSSD"), each = n)
)

# Plot
ggplot(df, aes(x = time, y = mood, color = series)) +
  geom_line() +
  facet_wrap(~series, ncol = 1, scales = "free_y") +
  theme_minimal() +
  labs(title = "Same SE, Different RMSSD in Mood Time Series",
       y = "Mood", x = "Time")
