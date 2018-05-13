return function (connection, req, args)
    dofile("httpserver-header.lc")(connection, 200, 'html')
    connection:send([===[
		<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Sensor configuration</title></head><body><h1>Sensor configuration</h1>
	]===])

    if req.method == "GET" then
        print ("Configuration form requested")
        connection:send([===[
			<form method="POST">
				<b>Wi-Fi settings</b><br>
				SSID:<br><input type="text" name="wifi_ssid"><br>
				Password:<br><input type="text" name="wifi_password"><br>
				<br><b>Sensor settings</b><br>
				Sensor name:<br><input type="text" name="sensor_name"><br>
				<br><b>MQTT broker settings</b><br>
				MQTT broker´s IP:<br><input type="text" name="mqtt_broker_ip"><br>
				MQTT broker´s port:<br><input type="text" name="mqtt_broker_port"><br>
				MQTT user:<br><input type="text" name="mqtt_username"><br>
				MQTT password:<br><input type="text" name="mqtt_password"><br>
				<br><input type="submit" name="submit" value="Submit"><br>
			</form>
			</body></html>
        ]===])

    elseif req.method == "POST" then
        local rd = req.getRequestData()
	    -- save config to file
		file.open("wifi_station_config.lua", "w")
		file.writeline('local station={}')
		file.writeline('station.ssid="' .. tostring(rd.wifi_ssid) .. '"')
		file.writeline('station.pwd="' .. tostring(rd.wifi_password) .. '"')
		file.writeline('return station')
		file.close()
		node.compile("wifi_station_config.lua")
		file.remove("wifi_station_config.lua")
		file.open("mqtt_client_config.lua", "w")
		file.writeline('local mqtt_conf={}')
		file.writeline('mqtt_conf.sensor_name="' .. tostring(rd.sensor_name) .. '"')
		file.writeline('mqtt_conf.broker_ip="' .. tostring(rd.mqtt_broker_ip) .. '"')
		file.writeline('mqtt_conf.broker_port=' .. tostring(rd.mqtt_broker_port) )
		file.writeline('mqtt_conf.username="' .. tostring(rd.mqtt_username) .. '"')
		file.writeline('mqtt_conf.password="' .. tostring(rd.mqtt_password) .. '"')
		file.writeline('return mqtt_conf')
		file.close()
		node.compile("mqtt_client_config.lua")
		file.remove("mqtt_client_config.lua")
		
        connection:send('<h2>Saved the following values:</h2>')
        connection:send("<ul>\n")
        for name, value in pairs(rd) do
            connection:send('<li><b>' .. name .. ':</b> ' .. tostring(value) .. "<br></li>\n")
        end
        connection:send("</ul>\n")
		connection:send('</body></html>')
		tmr.create():alarm(30 * 1000, tmr.ALARM_SINGLE, function () node.restart() end)
    else
        connection:send("ERROR  request method is ", req.method)
		connection:send('</body></html>')
    end   
end