-- httpserver-conf.lua
-- Part of nodemcu-httpserver, contains static configuration for httpserver.
-- Edit your server's configuration below.
-- Author: Sam Dieck

local conf = {}

-- General server configuration.
conf.general = {}
-- TCP port in which to listen for incoming HTTP requests.
conf.general.port = 80

-- WiFi configuration
conf.wifi = {}

-- Check if we need to start as station or access point
print(" Check if we need to start as station or access point")
if file.exists("wifi_station_config.lc") then
	print("Station confing found...")
	conf.wifi.mode = wifi.STATION
	conf.wifi.station = dofile("wifi_station_config.lc")
else
	print("Config for AP used...")
	conf.wifi.mode = wifi.SOFTAP
	conf.wifi.accessPoint = {}
	conf.wifi.accessPoint.config = {}
	conf.wifi.accessPoint.config.ssid = "ESP-"..node.chipid() -- Name of the WiFi network to create.
	conf.wifi.accessPoint.config.pwd = "ESP-"..node.chipid() -- WiFi password for joining - at least 8 characters
	conf.wifi.accessPoint.net = {}
	conf.wifi.accessPoint.net.ip = "192.168.111.1"
	conf.wifi.accessPoint.net.netmask="255.255.255.0"
	conf.wifi.accessPoint.net.gateway="192.168.111.1"
end

-- Basic HTTP Authentication.
conf.auth = {}
-- Set to true if you want to enable.
conf.auth.enabled = true
-- Displayed in the login dialog users see before authenticating.
conf.auth.realm = "admin"
-- Add users and passwords to this table. Do not leave this unchanged if you enable authentication!
conf.auth.users = {admin = "admin"}

return conf
