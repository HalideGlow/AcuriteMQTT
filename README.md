# AcuriteMQTT Container

## Based on the Home Assistant Add-on by Jeffery Stone : [Acurite2mqtt](https://github.com/thejeffreystone/hassio_addons/tree/main/acurite2mqtt)
A standalone container for a software defined radio tuned to listen for 433MHz RF transmissions from Acurite Weather Sensors and republish the data via MQTT, specifically for consumption in Home Assistant.

## Configuration
This is more or less notes of everything it took to get this working consistently. I will update this as frequently as I can and hope to polish it into a proper guide. 
Before we start: if you already have a MQTT broker setup and just want to see an examble compose file: [click here](#sample-docker-compose).


There is a docker compose included in the repository that can be used with Home Assistant Core. It builds a Docker stack with AcuriteMQTT and Mosquitto containers and configure the AcuriteMQTT container. Mosquitto uses a configuration file that most be setup manually. Because of the way the official Eclipse Mosquitto container works, you need to configure AcuriteMQTT with the MQTT username and password before it is set in Mosquitto. Make sure to set these value in the ```docker-compose.yml``` before bringing the stack up. 

**Note:** All usb devices are allowed inside the container by default. You can use ```lsusb``` to track down where the device in enumerated. Update the ```docker-compose.yml```
with a more specific path to the device in the format of ```/dev/bus/usb/"Bus ###"/"Device ###" ```
```yaml
       devices:
        - "/dev/bus/usb"
```

The included docker-compose maps the volumes for Mosquitto as follows.

```- mosquitto-config:/mosquitto/config - mosquitto-data:/mosquitto/data - mosquitto-log:/mosquitto/log```

There will be a mosquitto.config file under this directory: ```/var/lib/docker/volumes/acuritemqtt_mosquitto-config/_data```

Your directory may vary a little depending how docker was installed. My setup is Debian Bullseye without Snap or Flatpack.
You can edit the existing config if you want, but there are a lot of options to go over. For simplicity, I've listed the options I used below. Move the example config to a new file and create a file with these settings.
```
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
listener 1883

## Authentication ##
#allow_anonymous false
#password_file /mosquitto/config/password.txt
```

Bring the docker stack up with: ```docker-compose up``` 

Now we can setup a user to authenticate to Mosquitto. Make sure to use whatever was used in the ```docker-compose.yml``` earlier. 
Below is an example commmand.

```mosquitto_passwd -c /mosquitto/config/password.txt user```

With that, the stack can be restarted. Check the log output of AcuriteMQTT and make sure it's authenticating with Mosquitto. 

If all is well, you will see this in the log.
**Note:** ignore the line in this example about no supported devices found. I did not have a rtl-sdr dongle plugged in while testing this part.

```
mosquitto  | 1664385839: mosquitto version 1.6.15 starting
mosquitto  | 1664385839: Config loaded from /mosquitto/config/mosquitto.conf.
mosquitto  | 1664385839: Opening ipv4 listen socket on port 1883.
mosquitto  | 1664385839: Opening ipv6 listen socket on port 1883.
mosquitto  | 1664385839: mosquitto version 1.6.15 running
acurite    | Starting RTL_433 with parameters:
acurite    | MQTT Host = mosquitto
acurite    | MQTT port = 1883
acurite    | MQTT Username = user
acurite    | MQTT Password = 6b3a55e0261b0304143f805a24924d0c1c44524821305f31d9277843b8a10f4e
acurite    | MQTT Topic = rtl_433
acurite    | MQTT Retain = true
acurite    | PROTOCOL = -R 11 -R 40 -R 41 -R 55 -R 74
acurite    | Whitelist Enabled = false
acurite    | Whitelist =
acurite    | Expire After = 60
acurite    | UNITS = customary
acurite    | DISCOVERY_PREFIX = homeassistant
acurite    | DISCOVERY_INTERVAL = 600
acurite    | DEBUG = false
acurite    | rtl_433 version v3.16.0_rc4-53-g5aaa980138 branch master at 202205211529 inputs file rtl_tcp RTL-SDR with TLS
acurite    | Use -h for usage help and see https://triq.org/ for documentation.
acurite    | Trying conf file at "rtl_433.conf"...
acurite    | Trying conf file at "/root/.config/rtl_433/rtl_433.conf"...
acurite    | Trying conf file at "/usr/local/etc/rtl_433/rtl_433.conf"...
acurite    | Trying conf file at "/etc/rtl_433/rtl_433.conf"...
acurite    | Publishing MQTT data to mosquitto port 1883
acurite    | Publishing device info to MQTT topic "rtl_433[/model][/id][/channel:0]".
acurite    | Publishing events info to MQTT topic "rtl_433/events".
acurite    | Publishing states info to MQTT topic "rtl_433/states".
acurite    | Registered 5 out of 207 device decoding protocols [ 11 40-41 55 74 ]
acurite    | No supported devices found.
mosquitto  | 1664385839: New connection from 172.27.99.7 on port 1883.
mosquitto  | 1664385839: New client connected from 172.27.99.7 as auto-D602B549-F5BA-95BE-AF54-74C54896C56D (p2, c1, k60, u'user').

```



## Sample docker-compose

```yaml 
version: "3.6"
    services:
        acuritemqtt:
        container_name: acurite
        image: halideglow/acuritemqtt
        devices:
         - "/dev/bus/usb"
        environment:
            MQTT_HOST: "192.168.x.x"
            MQTT_PORT: "1883"
            MQTT_USERNAME: "user"
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
