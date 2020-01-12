#!/bin/bash

# Monitorize a interface and publish its "status" on a MQTT topic (polling-based)
# (status = if is available on ifconfig)

MQTT_SETTINGS=(-h localhost -u "admin" -P "admin" -p 8883 --cafile "/root/ca.crt")
MQTT_PUB_TOPIC="home/wrt/stat"
MQTT_LOG_TOPIC="home/wrt/log/lan2mqtt"
INTERFACE="br-lan"
LOOP_FREQ=3

status_last=""
status_now=""

function log() {
    echo "[$(date)] $1"
}

function publish_stat() {
    log "Tx @ ${MQTT_PUB_TOPIC}: $1"
    mosquitto_pub ${MQTT_SETTINGS[@]} -t "${MQTT_PUB_TOPIC}" -m "$1" -r || log "Error publishing to MQTT"
}

while true
do
    ifconfig "${INTERFACE}" 2> /dev/null && status_now="ON" || status_now="OFF"

    if [[ "${status_now}" != "${status_last}" ]]
    then
        publish_stat "${status_now}"
        status_last="${status_now}"
    fi

    sleep $LOOP_FREQ
done
