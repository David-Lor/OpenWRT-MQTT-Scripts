#!/bin/bash

# Bring up/down a set of network interfaces (in this case "lan")
# In this case the interface has a VLAN and the WIFI interface

MQTT_SETTINGS=(-h "localhost" -u "admin" -P "admin" -p 8883 --cafile "/root/ca.crt")
MQTT_SUB_TOPIC="home/wrt/cmd"
MQTT_LOG_TOPIC="home/wrt/log/mqtt2lan"
LOOP_FREQ=10

PAYLOADS_ON=("ON" "on" "1" "UP" "up")
PAYLOADS_OFF=("OFF" "off" "0" "DOWN" "down")

function log() {
    echo "[$(date)] $1"
    mosquitto_pub ${MQTT_SETTINGS[@]} -t "${MQTT_LOG_TOPIC}" -m "$1"
}

function lan_disable() { # $1 = "1" (set OFF) || "0" (set ON)
    uci set network.lan.disabled="$1" && /etc/init.d/network reload
    if [[ "$1" == "0" ]]
    then
        # When enabling the interfaces, the wifi must set up or it will remain disconnected
        wifi up
    fi
}

while true
do
    mosquitto_sub -v ${MQTT_SETTINGS[@]} -t "${MQTT_SUB_TOPIC}" | while read -r topic payload
    do
        log "Rx @ ${topic}: ${payload}"

        if [[ "${PAYLOADS_ON[@]}" =~ "${payload}" ]]
        then
            lan_disable 0 \
                && log "LAN set ON" \
                || log "LAN could not set ON"
        elif [[ "${PAYLOADS_OFF[@]}" =~ "${payload}" ]]
        then
            lan_disable 1 \
                && log "LAN set OFF" \
                || log "LAN could not set OFF"
        fi
    done

    log "mosquitto_sub ended, will run again in $LOOP_FREQ sec ..."
    sleep $LOOP_FREQ
done
