-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local cosock = require "cosock"
local socket = require "cosock.socket"

-- require custom handlers from driver package
local discovery = require "discovery"



--
-- Globals
-- 
KeepGoing = true;
LockedStatus = "UNKNOWN";







-----------------------------------------------------------------
-- local functions
-----------------------------------------------------------------
-- this is called once a device is added by the cloud and synchronized down to the hub
local function device_added(driver, device)
  log.info("[" .. device.id .. "] Adding my sliding glass door lock")

  -- set a default or queried state for each capability attribute
  -- device:emit_event(capabilities.switch.switch.on())
end



-- this is called both when a device is added (but after `added`) and after a hub reboots.
local function device_init(driver, device)

  log.info("[" .. device.id .. "] Initializing my sliding glass door lock")
  log.info("device_init(): defining cosock function");
  

  cosock.spawn(function()

    
    while KeepGoing do

      -- try creating a new tcp?
      local tcp = assert(socket.tcp())
      
      log.info("loop(): setting timeout to 60");
      tcp:settimeout(60)

      log.info("loop(): calling tcp:connect() to " .. device.preferences.lockDeviceUrl);
      local success, connectError = tcp:connect(device.preferences.lockDeviceUrl, 80)
    
      log.info("loop(): called connect(), success: " .. (success and success or "nil")  .. ", connectError: " .. (connectError and connectError or "nil"))
    
      local response;
      local err;
    
      while not err and not connectError and KeepGoing do
    
        log.info("loop(): receiving...");

        local response, err, partial = tcp:receive()
    
        if not err then

          log.info("loop(): Received from server: " .. response)

          if (response == "LOCKED" and LockedStatus ~= "LOCKED") then
            LockedStatus = "LOCKED";
            device:emit_event(capabilities.lock.lock.locked())
          elseif (response == "UNLOCKED" and LockedStatus ~= "UNLOCKED") then
            LockedStatus = "UNLOCKED";
            device:emit_event(capabilities.lock.lock.unlocked())
          end


        elseif err == "timeout" then
          log.info("loop(): We got a timeout and thus we are probably disconnected.");
          tcp:close();
          break;
    
        elseif err == "closed" then
          log.info("loop(): we are closed");
          tcp:close();
          break
        else
          log.error("loop(): Receive Error: " .. err)
        end
      end
    
      log.info("sleeping for 3 seconds...");
      socket.sleep(3)
    end
  
  end, "main_loop");

  log.info("loop(): running cosock routine...");

  cosock.run();

end




-- this is called when a device is removed by the cloud and synchronized down to the hub
local function device_removed(driver, device)
  log.info("[" .. device.id .. "] Removing sliding glass door lock sensor")
  log.debug("Setting KeepGoing to false")
  KeepGoing = false;
end




-- create the driver object
local mySlidingGlassDoorLock = Driver("mySlidingGlassDoorLock", {
  discovery = discovery.handle_discovery,
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    removed = device_removed
  }
})





-- run the driver
log.debug("Running the driver..");
mySlidingGlassDoorLock:run()


