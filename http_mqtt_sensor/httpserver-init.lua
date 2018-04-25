-- httpserver-init.lua
-- Part of nodemcu-httpserver, launches the server.
-- Author: Marcos Kirsch

-- Function for starting the server.
-- If you compiled the mdns module, then it will also register with mDNS.
local startServer = function(ip)
   local conf = dofile('httpserver-conf.lc')
   if (dofile("httpserver.lc")(conf['general']['port'])) then
      print("nodemcu-httpserver running at:  ")
      print("http://" .. ip .. ":" ..  conf['general']['port'])
   end
   conf = nil
end

if (wifi.getmode() == wifi.STATION) or (wifi.getmode() == wifi.STATIONAP) then

   -- Connect to the WiFi access point and start server once connected.
   -- If the server loses connectivity, server will restart.
   wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(args)
      print("Connected to WiFi Access Point. Got IP: " .. args["IP"])
      startServer(args["IP"])
      wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(args)
         print("Lost connectivity! Restarting...")
         node.restart()
      end)
	  -- Launch MQTT script
	  dofile("mqtt_sensor.lua")
   end)

   -- What if after a while (30 seconds) we didn't connect? Restart and keep trying.
   local watchdogTimer = tmr.create()
   watchdogTimer:register(30*1000, tmr.ALARM_SINGLE, function (watchdogTimer)
      local ip = wifi.sta.getip()
      if (not ip) then ip = wifi.ap.getip() end
      if ip == nil then
         print("No IP after a while. Clean config and restart...")
		 file.remove("wifi_station_config.lc")
         node.restart()
      else
         print("Successfully got IP. Good, no need to restart.")
         watchdogTimer:unregister()
      end
   end)
   watchdogTimer:start()


else

   startServer(wifi.ap.getip())

end
