practical6_data <- read.csv("practical6_data.csv")
library(mediation) #Mediation package

library(multilevel) #Sobel Test

library(bda) #Another Sobel Test option

library(gvlma) #Testing Model Assumptions 

library(stargazer) #Handy regression tables


# baron and kenny
fitxy <- lm(reaction ~ cond, data = practical6_data)
fitmy <- lm(reaction ~ pmi, data = practical6_data)
fitxm <- lm(pmi ~ cond, data = practical6_data)
fitymx <- lm(cond ~ reaction + pmi, data= practical6_data)

library(sjPlot)
tab_model(fitxy, fitxm, fitmy, fitymx)

# mediate

fitm <- lm(pmi ~ cond, data = practical6_data)
fity <- lm(reaction ~ cond + pmi, data= practical6_data)


set.seed(234)
fitmed <- mediate(fitm, fity, treat="cond", mediator = "pmi", sims = 5000)

summary(fitmed)

plot(fitmed)


