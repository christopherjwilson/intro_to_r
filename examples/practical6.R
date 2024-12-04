## Mediation practical

library(readr)
practical6_data <- read_csv("practical6_data.csv")

practical6_data$cond <- as.factor(practical6_data$cond)

#1. Total Effect of X on Y
fit <- lm(reaction ~ cond, data=practical6_data)

#2. Path A (X on M)
fita <- lm(pmi ~ cond, data=practical6_data)

#3. Path B (M on Y)
fitb <- lm(reaction ~ pmi, data=practical6_data)

#4. Reversed Path C (Y on X, controlling for M)
fitc <- lm(cond ~ reaction + pmi, data=practical6_data)

library(stargazer)

stargazer(fit, fita, fitb, fitc, type = "text", title = "Baron and Kenny Method")



#Mediate package
library(mediation)

fitM <- lm(pmi ~ cond,     data=practical6_data) #IV on M; 
fitY <- lm(reaction ~ cond + pmi, data=practical6_data) #IV and M on DV; 

set.seed(123)
fitMed <- mediate(fitM, fitY, treat="cond", mediator="pmi", sims = 1000)
summary(fitMed)

plot(fitMed)

gvlma(fitM)
plot(fitM)
gvlmafit
gvlma(fitY)
