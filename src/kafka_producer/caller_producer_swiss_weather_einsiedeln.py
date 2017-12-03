#!/usr/bin/env python3
### lightweight open weather map api caller to test if this can be used to gatter data_weather

import os
import http.client
import json
import time
import requests
import logging
from confluent_kafka import Producer
import socket


def open_weather_call(stationId):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://opendata.netcetera.com:80/smn/smn/" + str(stationId))
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    logging.debug(data)
    conn.close()
    return data


def kafka_produce(data):
    topic = 'swiss_weather'
    conf = {'bootstrap.servers': "localhost",
            'client.id': socket.gethostname(),
            'default.topic.config': {'acks': '1'}}

    logging.info("Confluent Message config client.id: " + socket.gethostname())
    producer = Producer(conf)

    logging.info("Send message to topic : " + str(topic))
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
    logging.basicConfig(filename='/var/log/swiss_weather.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.INFO)
    epoch_time_now = str(round(time.time()))
    logging.info("Start API call Open Swiss Weather Map at Time: " + epoch_time_now)

    # Call open Weather api to get Data
    stationIdEinsiedeln = "EIN"
    weather_data = open_weather_call(stationIdEinsiedeln)

    # Write to local store
    path = '/tmp/data'
    logging.info("Write jsno to : " + path)
    with open(path + '/swiss_weather_'+ str(stationIdEinsiedeln) +'_' + epoch_time_now + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(weather_data, outfile, indent=4, ensure_ascii=False)

    # Write to KAFKA
    kafka_produce(weather_data)
