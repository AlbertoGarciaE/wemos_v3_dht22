-- Load global user-defined variables
dofile("config.lua")

-- Connect to the wifi network using wifi module
wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_ssid, wifi_password)
wifi.sta.connect()

-- Establish MQTT client
m = mqtt.Client(node.chipid(), 120, mqtt_username, mqtt_password)

-- Read out DHT22 sensor using dht module
function func_read_dht()
  status, temp, humi, temp_dec, humi_dec = dht.read(2)
  if( status == dht.OK ) then
-- Integer firmware using this example
    print("DHT Temperature: "..math.floor(temp).."."..temp_dec.." C")
    mqtt_temp = math.floor(temp).."."..temp_dec
    print("DHT Humidity: "..math.floor(humi).."."..humi_dec.." %")
    mqtt_humi = math.floor(humi).."."..humi_dec
-- Float firmware using this example
--    print("DHT Temperature: "..temp.." C")
--    print("DHT Humidity: "..humi.." %")
  elseif( dht_status == dht.ERROR_CHECKSUM ) then          
    print( "DHT Checksum error" )
  elseif( dht_status == dht.ERROR_TIMEOUT ) then
    print( "DHT Time out" )
  end
end

-- Publish temperature readings and activate deep sleep
function func_mqtt_pub()
  m:connect(mqtt_broker_ip, mqtt_broker_port, 0, function(client) print("Connected to MQTT broker")
    m:publish("ESP8266/temp",mqtt_temp,0,0, function(client) print("Temp message published")
      m:publish("ESP8266/humi",mqtt_humi,0,0, function(client) print("Humi message published")
        print("Going into deep sleep mode for "..(dsleep_time/1000).." seconds.")
        node.dsleep(dsleep_time*1000)
      end)
    end)
  end)
end

-- Capture and publish sensor reading and enter deep sleep
function func_exec_loop()
  if wifi.sta.status() == 5 then  --STA_GOTIP
    print("Connected to "..wifi.sta.getip())
    func_read_dht() --Retrieve sensor data
    func_mqtt_pub() --Publish MQTT messages and go to sleep
    tmr.stop(1) --Exit loop
  else
    print("Still connecting...")
  end
end

tmr.alarm(1,500,tmr.ALARM_AUTO,function() func_exec_loop() end)