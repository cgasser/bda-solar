#################################################################
# Zeitrehenanalyse / Regression mit der Leistung einer PV-Anlage
#################################################################

library(data.table)
library(xts)
library(ggplot2)
library(plotly)
library(lubridate)
library(tseries)
library(zoo)

# set time zone environment variable
Sys.setenv(TZ="GMT")

########## Birchli
########## Daten (raw): Google Drive\CAS_BDA7\Daten\PV_Birchli_29_10_2017\SBEAM
########## Missing data 2015-10-10..2016-02-29

dt <- fread("data/birchli.csv")

### DATA

# attribute TIMESTAMP
# The temporal data in dt is an integer. Check:
class(dt$timestamp)
# Transform timestamp from character to POSIXct
# https://stackoverflow.com/questions/27408131/convert-unix-timestamp-into-datetime-in-r
dt$timestampPosix <- as.POSIXct(as.numeric(as.character(dt$timestamp)), origin='1970-01-01', tz='GMT')
class(dt$timestampPosix)

# attribute POWER1, POWER2
class(dt$power1)
class(dt$power2)

# select panel
currentAttribute <- dt$power1
#currentAttribute <- dt$power2

# create a dataframe
dfRaw <- data.frame(dt$timestampPosix, currentAttribute)
colnames(dfRaw) <- c("time", "power")

# filter outliers
df <- dfRaw[dfRaw$power < 3,]
colnames(df) <- c("time", "power")

# filter for complete months
useEntireTimespan <- TRUE
if (useEntireTimespan) {
  startDate <- ymd_hms("2010-12-01 00:00:00")
  endDate <- ymd_hms("2015-10-01 00:00:00")
  df1 <- df[df$time >= startDate & df$time < endDate,]
  startDate <- ymd_hms("2016-03-01 00:00:00")
  endDate <- ymd_hms("2017-10-01 00:00:00")
  df2 <- df[df$time >= startDate & df$time < endDate,]
  df <- rbind(df1, df2)
} else {
  #startDate <- ymd_hms("2011-01-01 00:00:00")
  #endDate <- ymd_hms("2015-01-01 00:00:00")
  startDate <- ymd_hms("2010-12-01 00:00:00")
  endDate <- ymd_hms("2014-12-01 00:00:00")
  #startDate <- ymd_hms("2014-07-01 00:00:00")
  #endDate <- ymd_hms("2014-07-04 00:00:00")
  df <- subset(df, df$time >= startDate)
  df <- subset(df, df$time < endDate)
}

### POWER

# Visualize the power measurements along time
#plot(df, xlab = "Datum und Zeit", ylab = "Leistung [kW]", main = "Leistung", type = "b", pch = 20, col = 20)
plot_ly(data = df, x=~time, y=~power, type = "scatter", mode = "lines+markers", line=list(color="darkgreen")) %>%
  layout(title = 'Leistung Photovoltaik-Anlage',
         xaxis = list(title = 'Zeit'),
         yaxis = list(title = 'Leistung [kW]')) # range = c(0, 2.5)

### ENERGY

# add a date column
df$date <- as.Date(df$time)
df$month <- as.Date(format(df$time, "%Y-%m-01"), format = "%Y-%m-%d")
class(df$date)

# sum up the 10-min power values per day to obtain a proxy value for the energy produced
dfDays <- aggregate(list(energy = df$power), by = list(date = df$date), FUN = sum)
dfMonths <- aggregate(list(energy = df$power), by = list(date = df$month), FUN = sum)
class(dfMonths$date)

# filter out zero days
#dfDays <- dfDays[dfDays$energy > 0,]
#dfMonths <- dfMonths[dfMonths$energy > 0,]

# select aggregation level
#dfCum <- dfDays
dfCum <- dfMonths

# visualize the energy along time (date)
?plot
plot(dfCum, xlab = "Jahr", ylab = "Energie (proxy)", main = "Monatliche Produktion")

# add an obs column
dfCum$obs <- 1:nrow(dfCum)

# visualize the energy along time (obs)
plot(dfCum$obs, dfCum$energy)

# Linear Regression
linearModel = lm(dfCum$energy ~ dfCum$obs)
summary(linearModel)
abline(linearModel)

# loess(): Local Polynomial Regression Fitting
?loess
loessEnergy <- loess(dfCum$energy ~ dfCum$ob)
plot(loessEnergy)
lines(loessEnergy$x, loessEnergy$fitted)

# Additive Time Series
# definition ts: data which has been sampled at equispaced points in time
# per day: use a frequency of 365 since the data contains one sample per day and is expected to repeat every year
?ts
tsEnergyPerDay <- ts(dfDays$energy, start = c(2010, 12), end = c(2015, 01), frequency = 365)
time(tsEnergyPerDay)
print(tsEnergyPerDay)
plot(tsEnergyPerDay)
# per month: use a frequency of 365 since the data contains one sample per day and is expected to repeat every year
tsEnergyPerMonth <- ts(dfMonths$energy, start = c(2010, 12), frequency = 12)
time(tsEnergyPerMonth)
print(tsEnergyPerMonth)
plot(tsEnergyPerMonth)

# decompose(): Classical Seasonal Decomposition by Moving Averages
?decompose
decomposeEnergy <- decompose(tsEnergyPerDay, type = "additive")
decomposeEnergy <- decompose(tsEnergyPerMonth, type = "additive")

plot(as.ts(decomposeEnergy$seasonal))
plot(as.ts(decomposeEnergy$trend))
plot(as.ts(decomposeEnergy$random))
plot(decomposeEnergy)

# stl(): Seasonal Decomposition of Time Series by Loess
?stl

### MISSING DATA - basis: days

# represent missing data as NA (2015-10-10..2016-02-29)
# https://stackoverflow.com/questions/28689428/pad-data-frame-with-missing-dates-in-a-series

missingDates <- data.frame(date = seq(from = as.Date("2015-10-11"), to = as.Date("2016-03-01"), by = "day"))
# add a date column
missingDates$energy <- NA

# concatenate data with missing dates containing NA as energy value
dfFilledUp <- rbind(dfDays, missingDates)
# order by date
dfFilledUp <- dfFilledUp[order(dfFilledUp$date),]
nrow(dfDays) + nrow(missingDates)
nrow(dfFilledUp)

# test "filling up" missing data
# source of the example: https://stackoverflow.com/questions/27368195/r-ts-with-missing-values

testZoo <- zoo(dfDays$energy, dfDays$date)
plot(testZoo)

zooValues <- zoo(dfFilledUp$energy, dfFilledUp$date)
plot(zooValues)

approxValues <- na.approx(zooValues)
plot(approxValues)

locfValues <- na.locf(zooValues)
plot(locfValues)

### SMOOTHING using smooth.spline() for smoothing and imputing - basis: days

# dfDays lacks values in the period 2015-10-11..2016-02-28
# create a data frame with NA values for this period
missingDays <- data.frame(date = seq(from = as.Date("2015-10-11"), to = as.Date("2016-02-28"), by = "day"))
# add a date column
missingDays$energy <- NA

# concat the NA data frame with the original data frame and sort by date again
dfDaysWithNa <- rbind(dfDays, missingDays)
dfDaysWithNa <- dfDaysWithNa[order(dfDaysWithNa$date),]

# create a time series
tsDaysWithNa <- ts(dfDaysWithNa$energy, start = c(2010, 12), end = c(2017, 09), frequency = 365)
time(tsDaysWithNa)
print(tsDaysWithNa)
plot(tsDaysWithNa)

# find the NA values
pos.na <- which(is.na(tsDaysWithNa))

# extract the time axis values
x.time <- time(tsDaysWithNa)
x.time

# apply a smooting function to the data excluding the missing section 
x <- x.time[-pos.na]
y <- tsDaysWithNa[-pos.na]
xy.smooth1 <- smooth.spline(x, y)
# try another smoothing parameter
xy.smooth2 <- smooth.spline(x, y, spar = 0.8)

# plot the smoothed curve
plot(tsDaysWithNa)
lines(xy.smooth1, col = "red")
lines(xy.smooth2, col = "blue")

# use the smoothed curve to predict y values for the missing section
pred.times <- x.time[pos.na]
pred.energy <- predict(xy.smooth, pred.times)$y

# copy the original time series and fill in the predicted values for the missing section
imp.tsDaysWithNa <- tsDaysWithNa
imp.tsDaysWithNa[pos.na] <- round(pred.energy)

# imputed values
plot(imp.tsDaysWithNa)
lines(xy.smooth, col = "green")

### SMOOTHING using smooth.spline() for smoothing and imputing - basis: months

# dfMonths lacks values in the period 2015-10-01..2016-02-29
# create a data frame with NA values for this period
missingMonths <- data.frame(date = seq(from = as.Date("2015-10-01"), to = as.Date("2016-02-1"), by = "month"))
# add a date column
missingMonths$energy <- NA

# concat the NA data frame with the original data frame and sort by date again
dfMonthsWithNa <- rbind(dfMonths, missingMonths)
dfMonthsWithNa <- dfMonthsWithNa[order(dfMonthsWithNa$date),]

# create a time series
tsMonthsWithNa <- ts(dfMonthsWithNa$energy, start = c(2010, 12), end = c(2017, 09), frequency = 12)
time(tsMonthsWithNa)
print(tsMonthsWithNa)
plot(tsMonthsWithNa, xlab = "Jahr", ylab = "Energie (proxy)", main = "Monatliche Produktion")

# find the NA positions
pos.na <- which(is.na(tsMonthsWithNa))

# extract the time axis values
x.time <- time(tsMonthsWithNa)
x.time

# apply a smooting function to the data excluding the missing section 
x <- x.time[-pos.na]
y <- tsMonthsWithNa[-pos.na]
xy.smooth1 <- smooth.spline(x, y)
# try different smoothing parameters
xy.smooth2 <- smooth.spline(x, y, spar = 0.5)
xy.smooth3 <- smooth.spline(x, y, spar = 0)

# plot the smoothed curve
plot(tsMonthsWithNa, xlab = "Jahr", ylab = "Energie (proxy)", main = "Monatliche Produktion")
lines(xy.smooth1, col = "red")
lines(xy.smooth2, col = "blue") # strong smoothing
lines(xy.smooth3, col = "orange") # weak smoothing

# select smoothing parameters
xy.smooth = xy.smooth3

# use the smoothed curve to predict y values for the missing section
pred.times <- x.time[pos.na]
pred.energy <- predict(xy.smooth, pred.times)$y

# copy the original time series and fill in the predicted values for the missing section
imp.tsMonthsWithNa <- tsMonthsWithNa
imp.tsMonthsWithNa[pos.na] <- round(pred.energy)

# imputed values
plot(imp.tsMonthsWithNa, xlab = "Jahr", ylab = "Energie (proxy)", main = "Monatliche Produktion")
lines(xy.smooth, col = "green")

# Additive Time Series - repeat time series analysis on time series with imputed values
# decompose(): Classical Seasonal Decomposition by Moving Averages
?decompose
decomposeEnergy <- decompose(imp.tsMonthsWithNa, type = "additive")

plot(as.ts(decomposeEnergy$seasonal))
plot(as.ts(decomposeEnergy$trend))
plot(as.ts(decomposeEnergy$random))
plot(decomposeEnergy)
