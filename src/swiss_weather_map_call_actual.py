#!/usr/bin/env python3
### lightweight open weather map api caller to test if this can be used to gatter data_weather

import http.client
import json
import time
import requests
import logging


def open_weather_call(stationId,epoch_time):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://opendata.netcetera.com:80/smn/smn/"+ str(stationId))
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    #data['timestamp_collect'] = epoch_time
    logging.debug(data)
    with open('/home/claude/repo/bda-solar/data/data_weather/open_swiss_weather_'+ str(stationId) +'_' + epoch_time + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile, indent=4, ensure_ascii=False)
    conn.close()

if __name__ == "__main__":
    logging.basicConfig(filename='/home/claude/repo/bda-solar/log/solar_requests.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.DEBUG)
    epoch_time_now = str(round(time.time()))
    logging.info("Start API call Open Swiss Weather Map at Time: " + epoch_time_now)
    stationIdEinsiedeln = "EIN"

    open_weather_call(stationIdEinsiedeln,epoch_time_now)

