--[[
init.lua

Init.lua is automatically executed on bootup of the NodeMCU. This launcher file loads the actual init_XYZ file only when everything has been tested and debugged. 
A 15 second delay has been added in case of error and enable abort.
--]]


-- Set local variable
FileToExecute="mqtt_dht22.lua"

-- Set timer to abort initialization of actual program
print("You have 30 second to enter file.remove('init.lua') to abort")
tmr.alarm(0, 30000, 0, function()
  print("Executing: ".. FileToExecute)
  dofile(FileToExecute)
end)