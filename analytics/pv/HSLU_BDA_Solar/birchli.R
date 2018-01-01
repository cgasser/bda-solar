######################################################
# Test Zeitrehenanalyse der Leistung einer PV-Anlage
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


########## Birchli
########## Daten (raw): Google Drive\CAS_BDA7\Daten\PV_Birchli_29_10_2017\SBEAM

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

# create a dataframe per panel
dfRaw1 <- data.frame(dt$timestampPosix, dt$power1)
dfRaw2 <- data.frame(dt$timestampPosix, dt$power2)
colnames(dfRaw1) <- c("time", "power")
colnames(dfRaw2) <- c("time", "power")

# filter outliers
df1 <- dfRaw1[dfRaw1$power < 3,]
df2 <- dfRaw2[dfRaw2$power < 3,]
colnames(df1) <- c("time", "power")
colnames(df2) <- c("time", "power")

### POWER

# Visualize the time power curve along time
plot_ly(data = df1, x=~time, y=~power, type = "scatter", mode = "lines+markers", line=list(color="darkgreen"))
plot_ly(data = df2, x=~time, y=~power, type = "scatter", mode = "lines+markers", line=list(color="green"))

### ENERGY

# add a date column
df1$date <- as.Date(df1$time)
df2$date <- as.Date(df2$time)

# sum up the 10-min power values per day to obtain a proxy value for the energy produced
dfDays1 <- aggregate(list(energy = df1$power), by = list(date = df1$date), FUN = sum)
dfDays2 <- aggregate(list(energy = df2$power), by = list(date = df2$date), FUN = sum)
plot(dfDays1)
plot(dfDays2)

# Additive Time Series
# definition ts: data which has been sampled at equispaced points in time
# use a frequency of 365 since the data contains one sample per day and is expected to repeat every year
tsEnergyPerDay1 <- ts(dfDays1, frequency = 365)
decomposeEnergy1 <- decompose(tsEnergyPerDay1, "additive")

plot(as.ts(decomposeEnergy1$seasonal))
plot(as.ts(decomposeEnergy1$trend))
plot(as.ts(decomposeEnergy1$random))
plot(decomposeEnergy1)
