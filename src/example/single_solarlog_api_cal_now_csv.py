#!/usr/bin/env python3
### lightweight solarlog api polling script to collect pv-data

import http.client
import json
import time
import csv
import requests
import logging


def solarLog_call(epoch_time):
    conn = http.client.HTTPConnection("")
    r = requests.get(" http://winsun.solarlog-web.ch/api?cid=" + pfadheimBaarCID + "&locale=de_ch&username=277555406&password=5a03cdf0a3ff42de09bc85361d8a2f0f&function=dashboard&format=jsonh&solarlog=9112&tiles=Yield|true,Grafic|true,Env|true,Weather|true&ctime=" + epoch_time)
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    data['timestamp'] = epoch_time
    logging.debug(data)
    with open('/home/claude/repo/bda-solar/data/data_timestamp/pfadibaar_solarlog_' + epoch_time + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile, indent=4, ensure_ascii=False)

    conn.close()

if __name__ == "__main__":
    logging.basicConfig(filename='/home/claude/repo/bda-solar/log/solar_requests.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.DEBUG)
    epoch_time_now = str(round(time.time()))
    logging.info("Start API call Pfadiheim Baar at Time: " + epoch_time_now)
    pfadheimBaarCID = "51769"

    solarLog_call(epoch_time_now)
