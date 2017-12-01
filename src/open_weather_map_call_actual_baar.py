#!/usr/bin/env python3
### lightweight open weather map api caller to test if this can be used to gatter data_weather

import http.client
import json
import time
import requests
import logging


def open_weather_call(zipId,appId,epoch_time):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://api.openweathermap.org/data/2.5/weather?zip="+ str(zipId) +",ch" +"&appid="+ appId)
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    #data['timestamp'] = epoch_time
    logging.debug(data)
    with open('/home/claude/PycharmProjects/pv/data_weather_openweather/open_weather_'+ str(zipId) +'_' + epoch_time + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile, indent=4, ensure_ascii=False)
    conn.close()

if __name__ == "__main__":
    logging.basicConfig(filename='/home/claude/PycharmProjects/pv/solar_requests.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.DEBUG)
    epoch_time_now = str(round(time.time()))
    logging.info("Start API call Open Weather Map at Time: " + epoch_time_now)
    apiKey = "01638bd216e99ac31b6b81973d2adc08"
    zip = 6340

    open_weather_call(zip,apiKey,epoch_time_now)
