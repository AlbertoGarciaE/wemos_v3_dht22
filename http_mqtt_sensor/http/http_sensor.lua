--dht module
--WeMos D1 mini pin D4 is GPIO2 in ESP8266 but in nodeMCU is IOindex 4
dht_pin = 4  -- Pin connected to DHT22 sensor
format_temp = 0      -- Temperature for publication
format_humi = 0      -- Humidity for publication

return function (connection, req, args)
    dofile("httpserver-header.lc")(connection, 200, 'html')
    connection:send([===[
	<!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>Sensor configuration</title></head><body><h1>Sensor configuration</h1>
	]===])

    if req.method == "GET" then
		status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)
        if( status == dht.OK ) then
			-- Integer firmware
			format_temp = math.floor(temp).."."..string.sub(tostring(temp_dec),1,2)
			print("DHT Temperature: "..format_temp.." C")
			format_humi = math.floor(humi).."."..string.sub(tostring(humi_dec),1,2)
			print("DHT Humidity: "..format_humi.." %")
			connection:send("<p><b>Sensor data</b><br>Temperature: "..format_temp.." C <br>Humidity: "..format_humi.." % <br></p>")
        elseif( status == dht.ERROR_CHECKSUM ) then          
            print( "DHT Checksum error" )
		    connection:send("ERROR  DHT Checksum error ")
        elseif( status == dht.ERROR_TIMEOUT ) then
            print( "DHT Time out" )
		    connection:send("ERROR  DHT Time out")
        end
    else
        connection:send("ERROR  request method is ", req.method)
    end
    connection:send('</body></html>')
end

