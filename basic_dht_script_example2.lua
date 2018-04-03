--[[
dht22.lua | Tiest van Gool
Script connects to internet through NodeMCU wifi module.
Once connection is established dht module and temperature and humidity is retrieved.
--]]

-- Load global user-defined variables
dofile("config.lua")

-- Connect to the wifi network using wifi module
wifi.setmode(wifi.STATION)
wifi.sta.config(wifi_ssid, wifi_password)
wifi.sta.connect()

-- Read out DHT22 sensor using dht module
function func_read_dht()
  status, temp, humi, temp_dec, humi_dec = dht.read(2)
  if( status == dht.OK ) then
-- Integer firmware use this code
    print("DHT Temperature: "..math.floor(temp).."."..temp_dec.." C")
    print("DHT Humidity: "..math.floor(humi).."."..humi_dec.." %")
-- Float firmware uuse this code
--    print("DHT Temperature: "..temp.." C")
--    print("DHT Humidity: "..humi.." %")
  elseif( dht_status == dht.ERROR_CHECKSUM ) then          
    print( "DHT Checksum error" )
  elseif( dht_status == dht.ERROR_TIMEOUT ) then
    print( "DHT Time out" )
  end
end

-- Execute sensor reading and enter deep sleep
function func_exec_loop()
  if wifi.sta.status() == 5 then  --STA_GOTIP
    print("Connected to "..wifi.sta.getip())
    tmr.stop(1) --Exit loop
    func_read_dht() --Retrieve sensor data
    print("Going into deep sleep mode for "..(dsleep_time/1000).." seconds.")
    node.dsleep(dsleep_time*1000)
  else
    print("Still connecting...")
  end
end

tmr.alarm(1,500,tmr.ALARM_AUTO,function() func_exec_loop() end)