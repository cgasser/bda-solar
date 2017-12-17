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
    # Remove key's with complex JSON structure
    del data['cur_production_per_wrid']
    del data['invEnergyType']
    del data['decimalseperator']
    logging.debug(data)

    #write data to .json
    with open('/home/claude/repo/bda-solar/data/data_timestamp/pfadibaar_solarlog_' + epoch_time + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(data, outfile, indent=4, ensure_ascii=False)

    #write the same data as .csv since it is more easy to handel with hdfs..
    with open('/home/claude/repo/bda-solar/data/data_timestamp/pfadibaar_solarlog_' + epoch_time + '.csv', 'w') as f:  # Just use 'w' mode in 3.x
        w = csv.DictWriter(f, data.keys())
        w.writeheader()
        w.writerow(data)

    conn.close()

if __name__ == "__main__":
    logging.basicConfig(filename='/home/claude/repo/bda-solar/log/solar_requests.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.DEBUG)
    epoch_time_now = str(round(time.time()))
    logging.info("Start API call Pfadiheim Baar at Time: " + epoch_time_now)
    pfadheimBaarCID = "51769"

    solarLog_call(epoch_time_now)
