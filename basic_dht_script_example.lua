-- pin = 3 -- GPIO0
pin = 4 -- GPIO2

FLOAT_FIRMWARE = (1/3) > 0

function readDht()
  status, temp, humi, temp_dec, humi_dec = dht.read(pin)
  if status == dht.OK then
    if FLOAT_FIRMWARE then
      -- Float firmware using this example
      print(string.format("DHT Temperature: %.1f - Humidity: %.1f",temp, humi))
    else
      -- Integer firmware using this example
      print(string.format("DHT Temperature:%d.%03d - Humidity:%d.%03d",
        temp,temp_dec,humi,humi_dec))
    end
  elseif status == dht.ERROR_CHECKSUM then
    print( "DHT Checksum error." )
  elseif status == dht.ERROR_TIMEOUT then
    print( "DHT timed out." )
  end
end

-- max sample rate of DHT22 is 0.5Hz -> timeout 2000
-- max sample rate of DHT11 is 1Hz   -> timeout 1000
tmr.alarm(0, 2000, tmr.ALARM_AUTO, readDht)