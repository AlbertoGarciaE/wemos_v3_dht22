return function ()
	--dht module
	--WeMos D1 mini pin D4 is GPIO2 in ESP8266 but in nodeMCU is IOindex 4
	dht_pin = 4  -- Pin connected to DHT22 sensor
	calc_temp = 0      -- Temperature for publication
	calc_humi = 0      -- Humidity for publication
	
	--sensor reading interval
	dsleep_time = 58000 --sleep time in μs
	
	-- MQTT client start
	if file.exists("mqtt_client_config.lc") then
		print("MQTT client config found, start MQTT client...")
		conf.mqtt = dofile("mqtt_client_config.lc")
		conf.mqtt.client_id = mqtt.sensor_name.."_".. node.chipid()
		conf.mqtt.topic = mqtt.sensor_name.."/state"
		conf.mqtt.pub_period = 60
		conf.mqtt.retry_period = 10
		-- Establish MQTT client
		m = mqtt.Client(conf.mqtt.client_id, 120, conf.mqtt.username, conf.mqtt.password)
		tmr.alarm(1,conf.mqtt.pub_period * 1000,tmr.ALARM_AUTO,function() func_exec_loop() end)
	else
		print("MQTT client config not found, imposible to start client")
	end
	
	-- Read out DHT22 sensor using dht module
	local function func_read_dht()
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
	
	-- Publish temperature readings and activate deep sleep
	local function func_mqtt_pub(data)
		m:connect(conf.mqtt.broker_ip, conf.mqtt.broker_port, 0,0, function(client) print("Connected to MQTT broker")
			m:publish(conf.mqtt.topic,data,0,0, function(client) print("Temp and Humi  published")
				m:close()
				-- print("Going into deep sleep mode for "..(dsleep_time/1000).." seconds.")
				-- node.dsleep(dsleep_time*1000)  -- This function can only be used in the condition that esp8266 PIN32(RST) and PIN8(XPD_DCDC aka GPIO16) are connected together.
			end)
		end,
		function(client, reason) print("Connect to MQTT broker failed with reason: " .. reason)
			tmr.alarm(2,conf.mqtt.retry_period * 1000, tmr.ALARM_SINGLE, func_mqtt_pub(data))
		end)
	end
	
	-- Capture and publish sensor reading
	local function func_exec_loop()
		print("Retrieve sensor data")
		temp, humi = func_read_dht() --Retrieve sensor data
		data = "{'temperature': "..temp.. ",'humidity': "..humi.." }"
		print("Publish MQTT messages and go to sleep")
		func_mqtt_pub(data) --Publish MQTT messages and go to sleep
	end
end