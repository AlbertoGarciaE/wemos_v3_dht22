--wifi module
wifi_cfg={}
wifi_cfg.ssid="YOUR NETWORK"
wifi_cfg.pwd="YOUR PASSWORD"

--dht module
--WeMos D1 mini pin D4 is GPIO2 in ESP8266 but in nodeMCU is IOindex 4
dht_pin = 4  -- Pin connected to DHT22 sensor
dht_temp_calc = 0  -- Calculated temperature
dht_humi_calc = 0  -- Calculated humidity
mqtt_temp = 0      -- Temperature for publication
mqtt_humi = 0      -- Humidity for publication

--sensor reading interval
dsleep_time = 8000 --sleep time in μs

--sensor name
sensor_name="inhouse"

--mqtt module
mqtt_broker_ip = "192.168.1.82"     
mqtt_broker_port = 1883
mqtt_username = "mqtt_username"
mqtt_password = "mqtt_password"
mqtt_client_id = sensor_name.."_"..node.chipid()
mqtt_topic_temp = sensor_name.."/temp"
mqtt_topic_humi = sensor_name.."/humi"

-- Status Message
print("Global variables loaded")
