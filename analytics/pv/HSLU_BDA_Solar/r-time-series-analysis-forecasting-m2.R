## Time Series Vectors and Lags

head(lynx)

# extracting time stamps
time(lynx)

# how longs is the dataset?
length(lynx)

mean(lynx); median(lynx)

plot(lynx)

sort(lynx)

# quantiles
quantile(lynx)

# getting the deciles
quantile(lynx, prob = seq(0, 1, length = 11), type = 5)

## Preparing Class ts

head(lynx)

plot(lynx)

# random uniform data between 10 and 45
mydata = runif(n = 50, min = 10, max = 45)

# packing it into a quarterly time series
# data: plain vector
# start: first value of the x-axis
#    c: concatenate; 3 indicates the quarter
# frequency: 4 values per 'season'; here, a yeary season is expected
mytimeseries = ts(data = mydata, start = c(1956,3), frequency = 4)
# data not equally spaced in time: use xts as an alternative

plot(mytimeseries)

class(mytimeseries)

class(lynx)

# a typical mts dataset
class(EuStockMarkets); head(EuStockMarkets)

## ts plots

plot(nottem)

# decompose to single components
plot(decompose(nottem))

# if the dataset is a plain vector, not a time series, plot.ts() uses time dummies for the x-axis
# example with random data
plot.ts(cumsum(rnorm(500)))

# Season Plot (requires package forecast) to compare the yearly intervals
# to compare seasons across the years
library(forecast)
ggseasonplot(nottem)

## Stationarity

test = ts(c(rnorm(100,2,1), rnorm(100,50,1)), start = 1)

plot(test)

plot(diff(test))

# Unit Root Tests

x = rnorm(1000) # random normal data

library(tseries)
adf.test(x)

plot(nottem) # seasonal data

adf.test(nottem)

## Autocorrelation

plot.ts(rnorm(200))

plot(lynx)

acf(lynx, lag.max = 20) 
pacf(lynx, lag.max = 20)

acf(rnorm(500), lag.max = 20) 
pacf(rnorm(500), lag.max = 20)



## Differencing
# 1 different section
test = ts(c(rnorm(100,2,1), rnorm(100,50,1)), start = 1)
plot(test)
plot(diff(test))

# 2 different sections
test = ts(c(rnorm(100,2,1), rnorm(100,50,1), rnorm(100,80,1)), start = 1)
plot(test)
plot(diff(test))
