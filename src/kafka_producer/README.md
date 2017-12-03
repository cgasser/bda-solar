# API Caller & KAFKA Producer
The available scripts in this folder helping to collect data over a REST API call from the listed sources:

- Open Weather Map (https://openweathermap.org/current)
- Swiss Weather (http://opendata.netcetera.com/smn/swagger#!/smn/getSmnRecord_get_2)

And Solar Data from:

- Solarlog - reverse engineered from (http://winsun.solarlog-web.ch)

For each source we gather the data we write them directly to KAFKA and store the response JSON directly in data in /data/
The following topic are written for the different sources:
- topic: solarlog
- topic: swiss_weather
- topic: open_weather

## Logs
Every caller_producer has a log file with the name of the kafka topic in /var/logs.
Exp: /var/log/solarlog.log

## Cronjop
In order to collect frequently new data (current) we have setup a cronjop to call the the python scripts:

- caller_producer_solarlog_pfadiheim_baar.py for SOLARLOG
- caller_producer_swiss_weather_einsiedeln.py for Swiss Weather
- caller_producer_open_weather_baa from Open Weather

### Settings on SH-01
Cronjop is available on SH-01 in XX