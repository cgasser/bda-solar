######################################################
# Test Visualisierung der Leistung einer PV-Anlage
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


########## pfadibaar.csv
########## Daten: Google Drive\CAS_BDA7\Daten\temp\test.csv

dt <- fread("data/pfadibaar.csv")

# attribute TIMESTAMP
# The temporal data in dt is an integer. Check:
class(dt$timestamp)
# Transform timestamp from character to POSIXct
# https://stackoverflow.com/questions/27408131/convert-unix-timestamp-into-datetime-in-r
dt$timestampPosix <- as.POSIXct(as.numeric(as.character(dt$timestamp)), origin='1970-01-01', tz='GMT')
class(dt$timestampPosix)

# order by timestamp
dt <- dt[order(dt$timestampPosix),]

# attribute POWER
class(dt$cur_yield_watt)

# create a dataframe
df <- data.frame(dt$timestampPosix, dt$cur_yield_watt)
colnames(df) <- c("time", "power")

# Visualize the time series
plot_ly(data = df, x=~time, y=~power, type = "scatter", mode = "lines+markers", line=list(color="darkred"))
