# AcuriteMQTT Container

## Fork of acurite2mqtt by Matt Coleman (colemamd) : [Acurite2mqtt](https://github.com/colemamd/acurite2mqtt)
A standalone container for a software defined radio tuned to listen for 433MHz RF transmissions from Acurite Weather Sensors and republish the data via MQTT, specifically for consumption in Home Assistant.

## Configuration


Sample docker-compose:

```yaml 
version: "3.6"
    services:
        acurite2mqtt:
        container_name: acurite
        image: halideglow/acuritemqtt
        devices:
         - "/dev/bus/usb"
        environment:
            MQTT_HOST: "192.168.0.50"
            MQTT_PORT: "1883"
            MQTT_USER: "user"
            MQTT_PASSWORD: "password"
            MQTT_RETAIN: "true"
            MQTT_TOPIC: "rtl_433"
            PROTOCOL: "-R 11 -R 40 -R 41 -R 55 -R 74"
            UNITS: "customary"
            EXPIRE_AFTER: 60
            DISCOVERY_PREFIX: "homeassistant"
            DISCOVERY_INTERVAL: 600
            WHITELIST_ENABLE: "false"
            WHITELIST: ""
            DEBUG: "false"
        restart: unless-stopped
```

### Option: `mqtt_host`

The `mqtt_host` option is the ip address of your mqtt server. If you are using the embeded server in Home Assistant just use your instances ip address.

### Option: `mqtt_port`

The `mqtt_port` option is the port of your mqtt server. If you are using the embeded server in Home Assistant just leave this as 1883.

### Option: `mqtt_user`

This is the username required to access your mqtt server.

### Option: `mqtt_password`

The password of the mqtt user account.

### Option: `mqtt_topic`

This si the topic your devices will use.

### Option: `mqtt_retain`

Setting this to `true` means the mqtt server will keep your last value 
until it is changed. Setting it to `false` means the server will forget values after a period of time, 
so you will onyl see a valus it one has been sent recently.

### Option: `protocol`

This determines what devices the software listens to. `-R 11 -R 40 -R 41 -R 55 -R 74` 
is the Accurite sensors. If the protocol is blank it will listen for all devices
which may be noisy.

For all possible protocols visit <https://clglb.ddns.net/HalideGlow/AcuriteMQTT/-/blob/main/PROTOCOLS.md>

### Option: `whitelist_enable`

Set to `true` to enable filtering to allow only the delcared device id's to be processed.  You may turn this off periodically
to scan/acquire new device id's.  But be cautious... any undesirable devices will need to be deleted from your configuration.

### Option: `whitelist`

This is a `space separated` list of device id's that are desired to be received and processed.  Any devices that are not in this
list will be ignored (if whitelist_enables is set to true).

### Option: `expire_after`

This is a `integer` value that will set an individual sensor entity to `unknown` if no payload is received within the specified seconds. The default value of 0 disables this feature.

### Option: `units`

Sets the meansurement units. 
- `si` = Metric
- `customary` = Imperial / Customary  

### Option: `discovery_prefix`

The mqtt prefix for autodiscovery. `homeassistant` should work. If you use another autodiscovery may not work.

### Option: `discovery_interval`

`600` means Home Assisatnt will check for new devices every 600 seconds. 

### Option: 'debug'

Set debug to `true` if you want to see extra logging. This is noisy though, so I would only run it when actively troubleshooting. Leave at false all other times. 

## Known issues and limitations

- This container is totally beta. 
