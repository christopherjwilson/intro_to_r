## moderation analysis

library(gvlma)
library(mctest)
library(rockchalk)
library(car)

### Import data
practical5_data <- read_csv("examples/practical5_data.csv")

### mean centering

practical5_data$attention <- scale(practical5_data$attention, center = TRUE, scale = FALSE)

### model moderation

mod1 <- lm(depression ~ anxiety * attention, data = practical5_data)

### check assumptions 

gvlma(mod1)
mctest(mod1)

### check model summary
summary(mod1)

### plot the interaction
ps <- plotSlopes(mod1, plotx = "anxiety", modx = "attention", interval = "confidence", modxVals = "std.dev")


### test the slopes

ts <- testSlopes(ps)

plot(ts)


### bootstrapping

mod1_boot <- Boot(mod1, R = 1000)

confint(mod1)
confint(mod1_boot)
summary(mod1_boot)
hist(mod1_boot)

## plot the moderated relationship simple slopes using ggplot 
## use a red to green colour scale for attention
## add a line of best fit for the mean of attention and a line of best fit for 1 standard deviation above and below the mean of attention

library(tidyverse)
practical5_data %>%
  ggplot(aes(x = anxiety, y = depression, color = attention)) +
  geom_point() +
  geom_smooth(method = "lm") +
  geom_smooth(aes(group = attention), method = "lm", linetype = "dashed") +
  scale_color_gradient(low = "red", high = "green") +
  labs(title = "Moderated relationship between anxiety and depression", x = "Anxiety", y = "Depression")

