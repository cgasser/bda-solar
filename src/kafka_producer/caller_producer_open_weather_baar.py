#!/usr/bin/env python3
### lightweight open weather map api caller to test if this can be used to gatter data_weather

import os
import getpass
import http.client
import json
import time
import requests
import logging
from confluent_kafka import Producer
import socket


def open_weather_call(appId,zipId):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://api.openweathermap.org/data/2.5/weather?zip="+ str(zipId) +",ch" +"&appid="+ appId)
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    logging.debug(data)
    conn.close()
    return data


def kafka_produce(data):
    topic = 'open_weather'
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
    logging.basicConfig(filename='/var/log/sopen_weather.log',
                        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.INFO)
    epoch_time_now = str(round(time.time()))
    logging.info("Start API call Open Swiss Weather Map at Time: " + epoch_time_now)

    # Call open Weather api to get Data
    apiKey = "01638bd216e99ac31b6b81973d2adc08"
    zip = 6340
    weather_data = open_weather_call(apiKey,zip)

    # Write to local store
    #path = os.path.realpath('../data/data_open_weather')
    path = '/tmp/data'
    logging.info("Write jsno to : " + path)
    with open(path + '/open_swiss_weather_'+ str(zip) +'_' + epoch_time_now + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(weather_data, outfile, indent=4, ensure_ascii=False)

    # Write to KAFKA
    kafka_produce(weather_data)
