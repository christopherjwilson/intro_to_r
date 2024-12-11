# Generate data for practical 1
# Gender is a factor: Male or Female
# Age is a numeric variable
# ID is a numeric variable from 1 to 20
# The object should be stored as practical1_data.

id <- 1:20
age <- rnorm(20, mean = 20, sd = 1.5) |> round(0)
gender <- sample(c("female","male"), 20, replace=TRUE, prob = c(0.53, 0.47))

practical1_data <- data.frame(id, gender, age)
write.csv(practical1_data, "practical1_data.csv", row.names = FALSE)



