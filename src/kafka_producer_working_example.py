#!/usr/bin/env python3
# easy example for a Python Producer
# Thanks goes to the example from https://docs.confluent.io/4.0.0/clients/producer.html

from confluent_kafka import Producer
import socket
import logging

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                        level=logging.DEBUG)

topic = 'myTopic'


conf = {'bootstrap.servers': "localhost",
        'client.id': socket.gethostname(),
        'default.topic.config': {'acks': '1'}}
logging.info("Confluent Message config client.id: " + socket.gethostname())

producer = Producer(conf)


def acked(err, msg):
    if err is not None:
        print("Failed to deliver message: %s: %s" % (str(msg), str(err)))
    else:
        print("Message produced: %s" % (str(msg)))

logging.info("Send Message: " + str('Dies ist eine Testnachricht'))
producer.produce(topic, str('Dies ist eine Testnachricht'), callback=acked)


# Wait up to 1 second for events. Callbacks will be invoked during
# this method call if the message is acknowledged.
producer.poll(1)
