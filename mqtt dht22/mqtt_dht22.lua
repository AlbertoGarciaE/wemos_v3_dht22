-- Load global user-defined variables
dofile("config.lua")

-- Connect to the wifi network using wifi module
wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_cfg)
wifi.sta.connect()

-- Establish MQTT client
m = mqtt.Client(mqtt_client_id, 120, mqtt_username, mqtt_password)

-- Read out DHT22 sensor using dht module
function func_read_dht()
  status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)
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
  m:connect(mqtt_broker_ip, mqtt_broker_port, 0,0, function(client) print("Connected to MQTT broker")
    m:publish(mqtt_topic_temp,mqtt_temp,0,0, function(client) print("Temp message published")
      m:publish(mqtt_topic_humi,mqtt_humi,0,0, function(client) print("Humi message published")
        -- print("Going into deep sleep mode for "..(dsleep_time/1000).." seconds.")
        -- node.dsleep(dsleep_time*1000)  -- This function can only be used in the condition that esp8266 PIN32(RST) and PIN8(XPD_DCDC aka GPIO16) are connected together.
      end)
    end)
  end,
  function(client, reason) print("Connect to MQTT broker failed with reason: " .. reason)
      tmr.alarm(2,10 * 1000, tmr.ALARM_SINGLE, func_mqtt_pub)
  end)
end

-- Capture and publish sensor reading and enter deep sleep
function func_exec_loop()
  if wifi.sta.status() == 5 then  --STA_GOTIP
    print("Connected to "..wifi.sta.getip())
    print("Retrieve sensor data")
    func_read_dht() --Retrieve sensor data
    print("Publish MQTT messages and go to sleep")
    func_mqtt_pub() --Publish MQTT messages and go to sleep
    -- print("Exit loop, remove it for continuous running state")
    -- tmr.stop(1) --Exit loop
  else
    print("Still connecting...")
  end
end

tmr.alarm(1,10 * 1000,tmr.ALARM_AUTO,function() func_exec_loop() end)
