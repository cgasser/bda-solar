## ARIMA
auto.arima(lynx)

auto.arima(lynx, trace = T)

myar = auto.arima(lynx, stepwise = F, approximation = F)

plot(forecast(myar, h = 3))


## ets
library(forecast)

# Using function ets
etsmodel = ets(nottem); etsmodel

# Plotting the model vs original
plot(nottem, lwd = 3)
lines(etsmodel$fitted, col = "red")

# Plotting the forecast
plot(forecast(etsmodel, h = 12))

# Changing the prediction interval
plot(forecast(etsmodel, h = 12, level = 95))

# Manually setting the ets model
etsmodmult = ets(nottem, model ="MZM"); etsmodmult

# Plot as comparison
plot(nottem, lwd = 3)
lines(etsmodmult$fitted, col = "red")
