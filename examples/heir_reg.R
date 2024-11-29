library(dplyr)
library(ggplot2)
library(readr)
album_sales <- read_csv("examples/album_sales.csv")


# airplay

model1 <- lm(Sales ~ Airplay, data = album_sales)

summary(model1)


# intercept only model (null model)
null <- lm(Sales ~ 1, data = album_sales)

# summary of null model

summary(null)
mean(album_sales$Sales)


anova(null, model1)
AIC(null,model1)



album_sales %>%
  ggplot(aes(x = Airplay, y = Sales)) +
  geom_point() +
  geom_smooth(method='lm') +
  geom_hline(aes(yintercept = mean(Sales)), linetype = "dashed")

# airplay and advertising

model2 <- lm(Sales ~ Airplay + Adverts, data = album_sales)
summary(model2)
anova(null, model1, model2)
AIC(null,model1, model2)

# multicollinearity

library(mctest)
mctest(model2)
