#!/usr/bin/env python3
#
# Swiss weather api caller and Kafka message producer
#
# Run the file directly on SourceHost01 with python3
# To see if data correctly can be consumed use following confluent cli:
# $ kafka_producer-console-consumer --bootstrap-server localhost:9092 --topic swiss_weather --from-beginning
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


def open_weather_call(station_id):
    conn = http.client.HTTPConnection("")
    r = requests.get("http://opendata.netcetera.com:80/smn/smn/" + str(station_id))
    logging.info("Response: " + str(r.status_code) + " " + r.reason)

    data = r.json()  # This will return entire content.
    # Remove key's in order to clean data from complex JSON structure and wrong syntax

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
    path = '/home/bda/data'
    logging.info("Write JSON to : " + path)
    with open(path + '/swiss_weather_'+ str(stationIdEinsiedeln) +'_' + epoch_time_now + '.json', 'w', encoding='utf-8') as outfile:
        json.dump(weather_data, outfile, indent=4, ensure_ascii=False)

    #write the same data as .csv since it is more easy to handel with hdfs..
    with open(path + '/swiss_weather_'+ str(stationIdEinsiedeln) +'_' + epoch_time_now + '.csv', 'w') as f:
        w = csv.DictWriter(f, weather_data.keys(), dialect=csv.excel_tab)
        w.writeheader()
        w.writerow(weather_data)

    # write data to hdfs
    logging.info("Write csv to hdfs : /data/swiss_weather/")
    client = InsecureClient('http://nh-01.ip-plus.net:50070', user='hdfs')
    with client.write('/data/swiss_weather/swiss_weather_'+ str(stationIdEinsiedeln) +'_' + epoch_time_now + '.csv', encoding='utf-8') as writer:
        w = csv.DictWriter(writer, weather_data.keys(), dialect=csv.excel_tab)
        w.writeheader()
        w.writerow(weather_data)

    # Write to KAFKA
    kafka_produce(weather_data)
