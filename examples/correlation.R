data(mtcars)

## plot data

plot(mtcars$mpg, mtcars$hp)

## correlation
cor.test(mtcars$mpg, mtcars$hp)

## histograms
hist(mtcars$mpg)
hist(mtcars$hp)

## spearman's correlation
cor.test(mtcars$mpg, mtcars$hp, method ="spearman")
