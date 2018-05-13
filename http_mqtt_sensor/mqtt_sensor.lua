--dht module
print("MQTT client module")

-- MQTT client start
if file.exists("mqtt_client_config.lc") then
	print("MQTT client config found, start MQTT client...")
	local mqtt_conf = dofile("mqtt_client_config.lc")
	mqtt_conf.client_id = mqtt_conf.sensor_name.."_".. node.chipid()
	mqtt_conf.topic = mqtt_conf.sensor_name.."/state"
	mqtt_conf.pub_period = 60
	-- Establish MQTT client
	m = mqtt.Client(mqtt_conf.client_id, 120, mqtt_conf.username, mqtt_conf.password)
	
	-- Read out DHT22 sensor using dht module
	local function func_read_dht()
    --WeMos D1 mini pin D4 is GPIO2 in ESP8266 but in nodeMCU is IOindex 4
	    local dht_pin = 4  -- Pin connected to DHT22 sensor
	    status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)
	    if( status == dht.OK ) then
	    	-- Integer firmware
	    	format_temp = math.floor(temp).."."..string.sub(tostring(temp_dec),1,2)
	    	print("DHT Temperature: "..format_temp.." C")
	    	format_humi = math.floor(humi).."."..string.sub(tostring(humi_dec),1,2)
	    	print("DHT Humidity: "..format_humi.." %")
	    elseif( status == dht.ERROR_CHECKSUM ) then          
	    	print( "DHT Checksum error" )
	    elseif( status == dht.ERROR_TIMEOUT ) then
	    	print( "DHT Time out" )
	    end
	    return format_temp, format_humi
    end

    -- Publish temperature readings
    local function func_mqtt_pub(data)
     -- local dsleep_time = 58000 --sleep time in micro seconds
    	local retry_period=10
    	m:connect(mqtt_conf.broker_ip, mqtt_conf.broker_port, 0,0, function(client) print("Connected to MQTT broker")
    		m:publish(mqtt_conf.topic,data,0,0, function(client) print("Temp and Humi  published")
    			m:close()
    			-- print("Going into deep sleep mode for "..(dsleep_time/1000).." seconds.")
    			-- node.dsleep(dsleep_time*1000)  -- This function can only be used in the condition that esp8266 PIN32(RST) and PIN8(XPD_DCDC aka GPIO16) are connected together.
    		end)
    	end,
    	function(client, reason) print("Connect to MQTT broker failed with reason: " .. reason)
    		tmr.alarm(2,retry_period * 1000, tmr.ALARM_SINGLE, func_mqtt_pub(data))
    	end)
    end
    
    -- Read and publish sensor reading
    local function func_exec_loop()
    	print("Retrieve sensor data")
    	temp, humi = func_read_dht() --Retrieve sensor data
    	data = "{'temperature': "..temp.. ",'humidity': "..humi.." }"
    	print("Publish MQTT messages and go to sleep")
    	func_mqtt_pub(data) --Publish MQTT messages and go to sleep
    end
	
	tmr.alarm(1,mqtt_conf.pub_period * 1000,tmr.ALARM_AUTO,function() func_exec_loop() end)
else
	print("MQTT client config not found, imposible to start client")
end	