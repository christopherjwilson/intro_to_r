# simulate some data: 
# 2 groups, treatment and control
# wellbeing outcome mesasure with different means

n = 20 # number of participants in each group
m1 = 20 # mean of group 1
m2 = 30 # mean of group 2



sim_data <- function(n, m1,m2){
  

# create outcome data for each group

outcome1 <- rnorm(n, m1, sd =1)
outcome2 <- rnorm(n, m2, sd = 1)

# combine both of these groups into a single vector

outcome <- c(outcome1,outcome2)

# create the grouping variable

group1 <- rep("treatment", n)
group2 <- rep("control", n)

# combine both groups into a single vector

group <- c(group1,group2)

# put both variables into a dataframe

data <- data.frame(group, outcome)

# run a t-test

test <- t.test(data$outcome ~ data$group)

# get the p value and other results

pval <- test$p.value
ci_low <- test$conf.int[1]
ci_high <- test$conf.int[2]
is_sig <- test$p.value < 0.05

# make a data frame

 data.frame(
  pval,
  ci_low,
  ci_high,
  is_sig )
  


# return the results

}

  # an empty list to hold the simulated results data
  
  results_data <- list()
  
  # sim the data n_sims number of times
  
  for (i in 1:10){
    simdata <- sim_data(n,m1,m2)
    results_data[[i]] <- simdata
  }

  # bind the rows
  results_data <- bind_rows(results_data)

  # calculate the proportion of significant results
  
  power <- mean(results_data$is_sig)
  
  