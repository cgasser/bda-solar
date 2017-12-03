#!/usr/bin/env python3
# easy example for a Python Producer
# Thanks goes to the example from https://docs.confluent.io/4.0.0/clients/producer.html

from confluent_kafka import Producer
import socket

topic = 'myTopic'


conf = {'bootstrap.servers': "localhost",
        'client.id': socket.gethostname(),
        'default.topic.config': {'acks': '1'}}


producer = Producer(conf)


def acked(err, msg):
    if err is not None:
        print("Failed to deliver message: %s: %s" % (str(msg), str(err)))
    else:
        print("Message produced: %s" % (str(msg)))


producer.produce(topic, str('Dies ist eine Testnachricht'), callback=acked)

# Wait up to 1 second for events. Callbacks will be invoked during
# this method call if the message is acknowledged.
producer.poll(1)
