#!/usr/bin/env python3
# easy example for a Python Producer
# Thanks goes to the example from https://github.com/confluentinc/confluent-kafka-python

from confluent_kafka import Producer

p = Producer({'bootstrap.servers': 'mybroker,mybroker2'})
for data in some_data_source:
    p.produce('mytopic', data.encode('utf-8'))
p.flush()