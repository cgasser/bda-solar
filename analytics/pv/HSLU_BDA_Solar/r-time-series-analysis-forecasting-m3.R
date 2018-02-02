## Simple Models

testts <- ts(rnorm(300), start = c(1919,1), frequency = 4)
plot(testts)

library(forecast)
meanmodel <- meanf(testts, h=20)
naivemodel <- naive(testts, h=20)
driftmmodel <- rwf(testts, h=20, drift = T)

plot(meanmodel, main = "")
lines(naivemodel$mean, col=123, lwd = 2)
lines(driftmmodel$mean, col=22, lwd = 2)
legend("topleft",lty=1,col=c(4,123,22),
       legend=c("Mean method","Naive method","Drift Method"))


##

## Accuracy and model comparison
set.seed(95)
myts <- ts(rnorm(400), start = c(1919,1), frequency = 4)

# Training set (80% of whole time series)
mytstrain <- window(myts, start = 1919, end = 1999)

plot(mytstrain)

# The 3 models we want to test
library(forecast)
meanmodel <- meanf(mytstrain, h=80)
naivemodel <- naive(mytstrain, h=80)
driftmodel <- rwf(mytstrain, h=80, drift = T)

# Extracting the test set
mytstest <- window(myts, start = 2000)

accuracy(meanmodel, mytstest)
accuracy(naivemodel, mytstest)
accuracy(driftmodel, mytstest)




## Residual

# Our dataset
set.seed(95)
myts <- ts(rnorm(200), start = (1919))

# Setting up our simple models
library(forecast)
meanm <- meanf(myts, h=20)
naivem <- naive(myts, h=20)
driftm <- rwf(myts, h=20, drift = T)

# Variance and mean of the mean model
var(meanm$residuals)
plot(meanm$residuals)
mean(meanm$residuals)

# Deleting the NA at the front of the vector
naivwithoutNA <- naivem$residuals
naivwithoutNA <- naivwithoutNA[2:200]
var(naivwithoutNA)
mean(naivwithoutNA)


driftwithoutNA <- driftm$residuals
driftwithoutNA <- driftwithoutNA[2:200]
var(driftwithoutNA)
mean(driftwithoutNA)

# Histogram of distribution
hist(meanm$residuals)

# Autcorrelation
acf(meanm$residuals)
