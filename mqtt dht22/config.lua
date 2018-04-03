--wifi module
wifi_ssid = "YOUR NETWORK"
wifi_password = "YOUR PASSWORD"

--mqtt module
mqtt_broker_ip = "YOUR LOCALHOST IP"     
mqtt_broker_port = 1883
mqtt_username = ""
mqtt_password = ""
mqtt_client_id = ""

--dht module
dht_pin = 2  -- Pin connected to DHT22 sensor
dht_temp_calc = 0  -- Calculated temperature
dht_humi_calc = 0  -- Calculated humidity
mqtt_temp = 0      -- Temperature for publication
mqtt_humi = 0      -- Humidity for publication

--sensor reading interval
dsleep_time = 60000 --sleep time in us

--sensor name
sensor_name="IN-HOUSE"
sensor_id=node.chipid()
sensor_pin=2 --WeMos D1 mini pin D4 is GPIO2 in ESP8266
-- Status Message
print("Global variables loaded")