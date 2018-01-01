#########################################
# Time Series Analysis
# 2017-11-24
# Author: Dr. Albert Blarer
# Demo HSLU
#########################################

######################################################
# Topic: Regular and irregular time-spaced time series
######################################################

# install.package(data.table)
library(data.table)
# install.package(xts)
library(xts)
# install.package(ggplot2)
library(ggplot2)
# install.package(plotly)
library(plotly)

# Set the time zone at the system level
Sys.setenv(TZ="Europe/Zurich")

dt <- fread("data/tweets_barcelona_082017.csv")
# The temporal data in dt is a string! Check:
class(dt$createdAt)
# Transform timestamp from character to POSIXct
dt$createdAt <- as.POSIXct(dt$createdAt,format="%Y-%m-%dT%H:%M:%SZ")
class(dt$createdAt)

# Aggregate irregular time series to regular
dt$obs <- 1
x.xts <- xts(dt$obs,dt$createdAt)
aligned.xts <- align.time(x.xts, n=3600)
agg.xts <- period.apply(aligned.xts, endpoints(aligned.xts, 'hours', 1), sum)
empty.xts <- xts(NULL,seq(start(aligned.xts),end(aligned.xts), by=3600))
out <- merge(empty.xts, agg.xts)
out.df <- fortify(out)
colnames(out.df) <- c("time", "obs")
out.df[is.na(out.df)] <- 0
# Visualize the time series
plot_ly(out.df, x=~time, y=~obs, type = "scatter", mode = 'lines')

############################################################
# The major elements of time series:
# Additive: "time series =  seasonal + trend + random"
# Multiplicative: "time series =  seasonal * trend * random"
############################################################

# Example of an additive time series
# install.packages("fpp")
library(fpp)
data(ausbeer) # data are part of the package
timeserie_beer = tail(head(ausbeer, 17*4+2),17*4-4)
plot(as.ts(timeserie_beer))

# Example of a multiplicative time series
# install.packages("Ecdat")
library(Ecdat)
data(AirPassengers)
timeserie_air = AirPassengers
plot(as.ts(timeserie_air))


# Detect the trend in an additive time series using the "centered moving average"
# using a moving average window of 4 (quarterly data)
# install.packages("forecast")
library(forecast)
trend_beer = ma(timeserie_beer, order = 4, centre = T)
plot(as.ts(timeserie_beer))
lines(trend_beer)
plot(as.ts(trend_beer))

# Detect the trend in a multiplicative time series using the "centered moving average"
# Using a moving average window of 12 (monthly data)
trend_air = ma(timeserie_air, order = 12, centre = T)
plot(as.ts(timeserie_air))
lines(trend_air)
plot(as.ts(trend_air))


# Detrending the time additive series
detrend_beer = timeserie_beer - trend_beer
plot(as.ts(detrend_beer))

# Detrending the multiplicative time series
detrend_air = timeserie_air / trend_air
plot(as.ts(detrend_air))

# Compute average seasonality in additive time series
m_beer = t(matrix(data = detrend_beer, nrow = 4))
seasonal_beer = colMeans(m_beer, na.rm = T)
plot(as.ts(rep(seasonal_beer,16)))

# Compute average seasonality in multiplicative time series
m_air = t(matrix(data = detrend_air, nrow = 12))
seasonal_air = colMeans(m_air, na.rm = T)
plot(as.ts(rep(seasonal_air,12)))

# Extract the random noise left:
# Additive time series: "random = time series - seasonal - trend"
random_beer = timeserie_beer - trend_beer - seasonal_beer
plot(as.ts(random_beer))

# Extract the random noise left:
# Multiplicative time series: "random = time series / (seasonal * trend)"
random_air = timeserie_air / (trend_air * seasonal_air)
plot(as.ts(random_air))

# Reconstruct the original signal:
# Additive time series
recomposed_beer = trend_beer+seasonal_beer+random_beer
plot(as.ts(recomposed_beer))

# Reconstruct the original signal:
# Multiplicative time series
recomposed_air = trend_air*seasonal_air*random_air
plot(as.ts(recomposed_air))

###################################################
# The decompose()-function (all in one function!!!)
# Additive
ts_beer = ts(timeserie_beer, frequency = 4)
decompose_beer = decompose(ts_beer, "additive")

plot(as.ts(decompose_beer$seasonal))
plot(as.ts(decompose_beer$trend))
plot(as.ts(decompose_beer$random))
plot(decompose_beer)

# Multiplicative
ts_air = ts(timeserie_air, frequency = 12)
decompose_air = decompose(ts_air, "multiplicative")

plot(as.ts(decompose_air$seasonal))
plot(as.ts(decompose_air$trend))
plot(as.ts(decompose_air$random))
plot(decompose_air)

# Using the STL( ) function (STL = Seasonal and Trend decomposition using Loess):
# Additive
ts_beer = ts(timeserie_beer, frequency = 4)
stl_beer = stl(ts_beer, "periodic")
seasonal_stl_beer   <- stl_beer$time.series[,1]
trend_stl_beer     <- stl_beer$time.series[,2]
random_stl_beer  <- stl_beer$time.series[,3]

plot(ts_beer)
plot(as.ts(seasonal_stl_beer))
plot(trend_stl_beer)
plot(random_stl_beer)
plot(stl_beer)

##############################
# Anomaly detection using STL
# Moving average decomposition
set.seed(4)
data <- read.csv("data/webTraffic.csv", sep = ",", header = T)
days = as.numeric(data$Visite)
for (i in 1:45 ) {
  pos = floor(runif(1, 1, 50))
  days[i*15+pos] = days[i*15+pos]^1.2
}
days[510+pos] = 0
plot(as.ts(days))

# Decomposition
# install.packages("FBN")
library(FBN)
decomposed_days = decompose(ts(days, frequency = 7), "multiplicative")
plot(decomposed_days)

# Normal distribution to find min & max
random = decomposed_days$random
min = mean(random, na.rm = T) - 4*sd(random, na.rm = T)
max = mean(random, na.rm = T) + 4*sd(random, na.rm = T)

plot(as.ts(as.vector(random)), ylim = c(-0.5,2.5))
abline(h=max, col="#e15f3f", lwd=2)
abline(h=min, col="#e15f3f", lwd=2)

# Plot anomalies
position = data.frame(id=seq(1, length(random)), value=random)
anomalyH = position[position$value > max, ]
anomalyH = anomalyH[!is.na(anomalyH$value), ]
anomalyL = position[position$value < min, ]
anomalyL = anomalyL[!is.na(anomalyL$value), ]
anomaly = data.frame(id=c(anomalyH$id, anomalyL$id),
                     value=c(anomalyH$value, anomalyL$value))
anomaly = anomaly[!is.na(anomaly$value), ]

plot(as.ts(days))
real = data.frame(id=seq(1, length(days)), value=days)
realAnomaly = real[anomaly$id, ]
points(x = realAnomaly$id, y =realAnomaly$value, col="#e15f3f")

# Moving median decomposition (the better method!)
library(forecast)
library(stats)

trend = runmed(days, 7)
plot(as.ts(trend))

# Normal distribution to find min & max
detrend = days / as.vector(trend)
m = t(matrix(data = detrend, nrow = 7))
seasonal = colMeans(m, na.rm = T)
random = days / (trend * seasonal)
rm_random = runmed(random[!is.na(random)], 3)

min = mean(rm_random, na.rm = T) - 4*sd(rm_random, na.rm = T)
max = mean(rm_random, na.rm = T) + 4*sd(rm_random, na.rm = T)
plot(as.ts(random))
abline(h=max, col="#e15f3f", lwd=2)
abline(h=min, col="#e15f3f", lwd=2)

# Plot anomalies
position = data.frame(id=seq(1, length(random)), value=random)
anomalyH = position[position$value > max, ]
anomalyH = anomalyH[!is.na(anomalyH$value), ]
anomalyL = position[position$value < min, ]
anomalyL = anomalyL[!is.na(anomalyL$value)]
anomaly = data.frame(id=c(anomalyH$id, anomalyL$id),
                     value=c(anomalyH$value, anomalyL$value))
points(x = anomaly$id, y =anomaly$value, col="#e15f3f")

plot(as.ts(days))
real = data.frame(id=seq(1, length(days)), value=days)
realAnomaly = real[anomaly$id, ]
points(x = realAnomaly$id, y =realAnomaly$value, col="#e15f3f")

