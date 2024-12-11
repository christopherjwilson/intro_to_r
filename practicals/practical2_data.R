# Generate a dataset with two columns called Group and Outcome
# The group variable is a factor with 2 levels (Treatment and Control)
# The outcome variable is a numeric vector with 40 values for each group
# The mean of the Treatment group is 10 and the mean of the Control group is 5
# The standard deviation of both groups is 2

# Generate the data

treatment <- rnorm(40, 10, 2)
control <- rnorm(40, 5, 2)
age <- rnorm(80, 24, 3) |> round(0)

# Combine the data into a single data frame
practical2_data <- data.frame(treatment_group = c(rep("Treatment", 40), rep("Control", 40)), outcome = c(treatment, control), age = age)

write.csv(practical2_data, "practical2_data.csv", row.names = FALSE)
