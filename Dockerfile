FROM alpine:latest

ENV LANG C.UTF-8

LABEL Description="This image is used to start the RTL433 to HASS script that will monitor for 433Mhz devices and send the data to an MQTT server"

# install rtl_433, rtl-sdr, libusb, mosquitto-clients, python3 and py-pip
# python and pip deps of rtl_433_mqtt_hass.py
RUN apk add --no-cache rtl-sdr rtl_433 libusb mosquitto-clients python3 py3-paho-mqtt

WORKDIR /data

# Copy scripts, make executable
COPY entry.sh rtl_433_mqtt_hass.py /scripts/
RUN chmod +x /scripts/entry.sh
RUN chmod +x /scripts/rtl_433_mqtt_hass.py

# Define environment variables
# Use this variable when creating a container to specify the MQTT broker host.
ENV MQTT_HOST=127.0.0.1 MQTT_PORT=1883 MQTT_USERNAME="" MQTT_PASSWORD="" MQTT_RETAIN="True" MQTT_TOPIC=rtl_433 PROTOCOL="" WHITELIST_ENABLE=False EXPIRE_AFTER=0 WHITELIST="" DISCOVERY_PREFIX=homeassistant DISCOVERY_INTERVAL=600 DEBUG=False

# Execute entry script
ENTRYPOINT [ "/scripts/entry.sh" ]
