#!/usr/bin/env python3
### lightweight open weather map api caller to test if this can be used to gatter data_weather

import http.client
import json
import time
import requests
import logging
import csv
import collections
import pandas as pd


def open_weather_call(zipId,appId,epoch_time):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://api.openweathermap.org/data/2.5/weather?zip="+ str(zipId) +",ch" +"&appid="+ appId + "&units=metric")
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    #data['timestamp'] = epoch_time
    logging.debug(data)
    path = '/home/claude/repo/bda-solar/data/data_weather_openweather'

    with open(path +'/open_weather_'+ str(zipId) +'_' + epoch_time + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile, indent=4, ensure_ascii=False)


    #write the same data as .csv since it is more easy to handel with hdfs..
    with open(path + '/open_weather_'+ str(zip) +'_' + epoch_time_now + '.csv', 'w') as f:
        w = csv.DictWriter(f, data.keys(), dialect=csv.excel_tab)
        w.writeheader()
        w.writerow(data)

    #Write flat not nested csv
    sorted_data = collections.OrderedDict(sorted(data.items()))
    #sorted_data = pd.io.json.json_normalize(sorted_data)

    #write the same data as .csv since it is more easy to handel with hdfs..
    with open(path + '/open_weather_'+ str(zip) +'_' + epoch_time_now + '_flat.csv', 'w') as f:
        w = csv.DictWriter(f, sorted_data.keys(), dialect=csv.excel_tab)
        w.writeheader()
        w.writerow(sorted_data)

    conn.close()

if __name__ == "__main__":
    logging.basicConfig(filename='/home/claude/repo/bda-solar/log/solar_requests.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.DEBUG)
    epoch_time_now = str(round(time.time()))
    logging.info("Start API call Open Weather Map at Time: " + epoch_time_now)
    apiKey = "01638bd216e99ac31b6b81973d2adc08"
    zip = 6340

    open_weather_call(zip,apiKey,epoch_time_now)
