
# Example from the ts() docs
?ts

require(graphics)

ts(1:10, frequency = 4, start = c(1959, 2)) # 2nd Quarter of 1959
print( ts(1:10, frequency = 7, start = c(12, 2)), calendar = TRUE)
# print.ts(.)
## Using July 1954 as start date:
gnp <- ts(cumsum(1 + round(rnorm(100), 2)),
          start = c(1954, 7), frequency = 12)
plot(gnp) # using 'plot.ts' for time-series plot

## Multivariate
z <- ts(matrix(rnorm(300), 100, 3), start = c(1961, 1), frequency = 12)
class(z)
head(z) # as "matrix"
plot(z)
plot(z, plot.type = "single", lty = 1:3)

## A phase plot:
plot(nhtemp, lag(nhtemp, 1), cex = .8, col = "blue",
     main = "Lag plot of New Haven temperatures")



# Smoothing
# https://stackoverflow.com/questions/11474039/applying-a-loess-smoothing-to-a-time-series

?loess

mydat <- runif(50)
day1 <- as.POSIXct("2012-07-13", tz = "UTC")
day2 <- day1 + 49*3600*24
pdays <- seq(day1, day2, by = "days")
lo <- loess(mydat ~ as.numeric(pdays))

# And then if you want to plot the result:
plot(pdays,mydat)
lines(pdays, lo$fitted)
