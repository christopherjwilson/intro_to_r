## Power simulation for independent two-sample t-test

# Load necessary libraries
library(tidyverse)

# Step 1: Some parameters
alpha <- 0.05  # Significance level
n1 <- 30       # Sample size for group 1
n2 <- 30       # Sample size for group 2
sd1 <- 20      # Standard deviation for group 1
sd2 <- 20     # Standard deviation for group 2
mean1 <- 100   # Mean for group 1
mean2 <- 105   # Mean for group 2

# Step 2: Calculate effect size

effect_size <- (mean2 - mean1) / sqrt((sd1^2 + sd2^2) / 2)

# Step 3: Simulate data 

set.seed(123)  # For reproducibility

simulated_data <- list()

sim_data <- function(nsims) {
  
  for (i in 1:nsims) {
    group1 <- rnorm(n1, mean = mean1, sd = sd1)
    group2 <- rnorm(n2, mean = mean2, sd = sd2)
    
    data <- data.frame(
      value = c(group1, group2),
      group = factor(rep(c("Group 1", "Group 2"), each = n1))
    )
    
    t_test_result <- t.test(value ~ group, data = data)
    
    simulated_data[[i]] <- list(
      t_statistic = t_test_result$statistic,
      p_value = t_test_result$p.value,
      conf_int = t_test_result$conf.int,
      mean_diff = mean(group2) - mean(group1)
    )
  }
  
# return the results as a data frame using tidyverse approach
  results_df <- bind_rows(simulated_data) %>%
    as_tibble()

}

# run the simulation for a certain number of simulations

results <- sim_data(10) 

# Step 4: Calculate power

power <- results %>%
  summarise(power = mean(p_value < alpha))
