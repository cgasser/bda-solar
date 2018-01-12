#!/usr/bin/env python3
#
# Solarlog api caller and Kafka message producer
#
# Run the file directly on SourceHost01 with python3
# To see if data correctly can be consumed use following confluent cli:
# $ kafka_producer-console-consumer --bootstrap-server localhost:9092 --topic solarlog --from-beginning
#
# Thanks goes to the example from https://docs.confluent.io/4.0.0/clients/producer.html


import http.client
import json, csv
import time
import requests
import logging
from confluent_kafka import Producer
import socket
from hdfs import InsecureClient
import collections


def solar_log_call(epoch_time, id, plantname):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://winsun.solarlog-web.ch/api?cid=" + id + "&locale=de_ch&username=277555406&password=5a03cdf0a3ff42de09bc85361d8a2f0f&function=dashboard&format=jsonh&solarlog=9112&tiles=Yield|true,Grafic|true,Env|true,Weather|true&ctime=" + epoch_time)
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    # Remove key's in order to clean data from complex JSON structure and wrong syntax
    del data['cur_production_per_wrid']
    del data['invEnergyType']
    # Add timestamp to the daty
    data['timestamp'] = epoch_time
    data['plantname'] = plantname
    if 'decimalseperator' not in data:
        data['decimalseperator'] = ','
    if 'curr_batt_power' not in data:
        data['curr_batt_power'] = ''
    sorted_data = collections.OrderedDict(sorted(data.items()))
    logging.debug(sorted_data)
    conn.close()
    return sorted_data


def kafka_produce(data):
    topic = 'solarlog'
    conf = {'bootstrap.servers': "localhost",
            'client.id': socket.gethostname(),
            'default.topic.config': {'acks': '1'}}

    logging.info("Confluent Message config client.id: " + socket.gethostname())
    producer = Producer(conf)

    logging.info("Write message to topic : " + str(topic))
    logging.debug("Write message json" + str(data))
    producer.produce(topic, str(data), callback=acked)

    # Wait up to 1 second for events. Callbacks will be invoked during
    # this method call if the message is acknowledged.
    producer.poll(1)

def acked(err, msg):
    if err is not None:
        print("Failed to deliver message: %s: %s" % (str(msg), str(err)))
    else:
        print("Message produced: %s" % (str(msg)))


if __name__ == "__main__":
    logging.basicConfig(filename='/var/log/solarlog.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.INFO)

    epoch_time_now = str(round(time.time()))

    # Call Solarlog api to get Data
    # List of all sites to collect
    pfadheimBaarCID = "51769"
    pv_sites = {'51769': 'Pfadiheim Baar'
                , '26678': 'Winsun AG, Steg'
                , '54349': 'Meyer Rolf, Baar'
                , '48542':'Himmelrichstrasse 1ab, Baar'}

    for site_id in pv_sites:
        logging.info("Start API call for" + pv_sites[site_id] + "at Time: " + epoch_time_now)
        solar_data = solar_log_call(epoch_time_now, site_id, pv_sites[site_id] )
        # Write to local store
        path = '/home/bda/data'
        logging.info("Write JSON and CSV to : " + path)
        with open(path + '/solarlog_' + str(site_id) + '_' + epoch_time_now + '.json', 'w', encoding='utf-8') as outfile:
            json.dump(solar_data, outfile, indent=4, ensure_ascii=False)

        #write the same data as .csv since it is more easy to handel with hdfs..
        with open(path + '/solarlog_' + str(site_id) + '_' + epoch_time_now + '.csv', 'w') as f:
            w = csv.DictWriter(f, solar_data.keys(), dialect=csv.excel_tab)
            w.writeheader()
            w.writerow(solar_data)


        # write data to hdfs
        logging.info("Write csv to hdfs : /data/solarlog/")
        client = InsecureClient('http://nh-01.ip-plus.net:50070', user='hdfs')
        with client.write('/data/solarlog/solarlog_' + str(site_id) + '_' + epoch_time_now + '.csv', encoding='utf-8') as writer:
            w = csv.DictWriter(writer, solar_data.keys(), dialect=csv.excel_tab)
            w.writeheader()
            w.writerow(solar_data)


    # Write to KAFKA
    kafka_produce(solar_data)
