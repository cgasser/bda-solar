# test interpolation of missing values
# source of the example: https://stackoverflow.com/questions/27368195/r-ts-with-missing-values

# packages for imputation: imputeTS, zoo, forecast

library(zoo)
library(lubridate)

allDates <- seq.Date(as.Date("2010-01-05"), as.Date("2010-01-11"), "day")
values <- c(-0.6041787, 0.2274668, -1.2751761, -0.8696818, NA, NA, -0.3486378)

df <- data.frame(allDates, values)
colnames(df) <- c("Date", "Value")
df

zooValues <- zoo(df$Value, df$Date)
head(zooValues, 7)
plot(zooValues)

approxValues <- na.approx(zooValues)
head(approxValues, 7)
plot(approxValues)




##
t0 <- "2010-01-04"
Dates <- as.Date(ymd(t0))+1:120
weekDays <- Dates[!(weekdays(Dates) %in% c("Saturday","Sunday"))]
##
set.seed(123)
values <- data.frame(Date=weekDays,Value=rnorm(length(weekDays)))
values
