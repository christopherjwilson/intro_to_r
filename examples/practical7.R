library(psych)
library(tidyverse)



data("bfi")
bfidata <- bfi[1:25] %>% na.omit()
describe(bfidata)
bfidata %>% complete.cases() %>% sum()
