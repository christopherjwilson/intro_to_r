  library(tidyverse)

  library(readr)
  practical2_data <- read_csv("~/GitHub/intro_to_r/docs/practicals/practical2_data.csv")
  View(practical2_data)
  
  data_over18 <- practical2_data |> filter(age > 18)
  
  data_over18 |> group_by(treatment_group) |> summarise(mean_age = mean(age), sd_age = sd(age))
  
  
  power.t.test(d = 0.23, sig.level = 0.05, power = 0.8, type = "two.sample")
  