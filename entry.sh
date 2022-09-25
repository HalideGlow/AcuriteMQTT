#!/bin/sh

# Exit immediately if a command exits with a non-zero status:
set -e


export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
export LD_LIBRARY_PATH=/usr/local/lib64


# Start the listener and enter an endless loop
echo "Starting RTL_433 with parameters:"
echo "MQTT Host =" $MQTT_HOST
echo "MQTT port =" $MQTT_PORT
echo "MQTT User =" $MQTT_USERNAME
echo "MQTT Password =" $(echo $MQTT_PASSWORD | sha256sum | cut -f1 -d' ')
echo "MQTT Topic =" $MQTT_TOPIC
echo "MQTT Retain =" $MQTT_RETAIN
echo "PROTOCOL =" $PROTOCOL
echo "Whitelist Enabled =" $WHITELIST_ENABLE
echo "Whitelist =" $WHITELIST
echo "Expire After =" $EXPIRE_AFTER
echo "UNITS =" $UNITS
echo "DISCOVERY_PREFIX =" $DISCOVERY_PREFIX
echo "DISCOVERY_INTERVAL =" $DISCOVERY_INTERVAL
echo "DEBUG =" $DEBUG



rtl_433  $PROTOCOL -C $UNITS  -F mqtt://$MQTT_HOST:$MQTT_PORT,user=$MQTT_USERNAME,pass=$MQTT_PASSWORD,retain=$MQTT_RETAIN,events=$MQTT_TOPIC/events,states=$MQTT_TOPIC/states,devices=$MQTT_TOPIC[/model][/id][/channel:0]  -M time:tz:local -M protocol -M level | /scripts/rtl_433_mqtt_hass.py
