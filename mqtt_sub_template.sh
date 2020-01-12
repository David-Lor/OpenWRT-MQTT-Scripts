#!/bin/sh

# Template for a shell script with a callback executed whenever a new MQTT message is received.

LOOP_FREQ=5

while true
do
  mosquitto_sub -h localhost -t test -v | while read -r topic payload
  do
	  echo "Rx @ ${topic}: ${payload}"
  done
  
  # external loop to reconnect if mosquitto_sub fails
  sleep $LOOP_FREQ
done
