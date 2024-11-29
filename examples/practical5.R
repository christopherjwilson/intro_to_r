## moderation analysis

library(gvlma)
library(mctest)
library(rockchalk)

### Import data
practical5_data <- read_csv("examples/practical5_data.csv")

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
