#!/usr/bin/env python3
### lightweight winsun api caller to test if this can be used to gatter solarlog data, store it and produce kafka message

import os
import http.client
import json
import time
import requests
import logging
from confluent_kafka import Producer
import socket


def solar_log_call(epoch_time):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://winsun.solarlog-web.ch/api?cid=" + pfadheimBaarCID + "&locale=de_ch&username=277555406&password=5a03cdf0a3ff42de09bc85361d8a2f0f&function=dashboard&format=jsonh&solarlog=9112&tiles=Yield|true,Grafic|true,Env|true,Weather|true&ctime=" + epoch_time)
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    data['timestamp'] = epoch_time
    logging.debug(data)
    conn.close()
    return data


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
    logging.info("Start API call Pfadiheim Baar at Time: " + epoch_time_now)
    pfadheimBaarCID = "51769"
    solar_data = solar_log_call(epoch_time_now)

    # Write to local store
    path = os.path.realpath('../data/data_timestamp')
    logging.info("Write JSON to : " + path)
    with open(path + '/pfadibaar_solarlog_' + str(pfadheimBaarCID) + '_' + epoch_time_now + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(solar_data, outfile, indent=4, ensure_ascii=False)

    # Write to KAFKA
    kafka_produce(solar_data)
