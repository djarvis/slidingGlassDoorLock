-- require st provided libraries
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local cosock = require "cosock"
local http = cosock.asyncify "socket.http"
local ltn12 = require('ltn12')
local myPresence = require('myPresence')
local json = require('dkjson')

-- require custom handlers from driver package
local discovery = require "discovery"

-----------------------------------------------------------------
-- local functions
-----------------------------------------------------------------
-- this is called once a device is added by the cloud and synchronized down to the hub
local function device_added(driver, device)
  log.info("[" .. device.id .. "] Adding my sliding glass door lock")

  -- set a default or queried state for each capability attribute
  -- device:emit_event(capabilities.switch.switch.on())
end

Device1Presence = "nil"
Device2Presence = "nil"

-- this is called both when a device is added (but after `added`) and after a hub reboots.
local function device_init(driver, device)
  log.info("[" .. device.id .. "] Initializing my sliding glass door lock")

  --
  -- Make a global for this device
  --
  TheDevice = device;

  -- 
  -- Kick off the polling timer
  --
  log.debug("kicking off the polling timer...")
  local num = tonumber(device.preferences.refreshInterval);
  log.debug("device preferences refreshInterval is " .. num);

   PollingTimer = driver:call_on_schedule(
    num,
    myPresence.query,
    "queryPresences")

  --
  -- TEMP
  --
  -- log.debug("***********************************")
  -- log.debug("**********************************")
  -- local res_payload = {}
  --   local url1 = TheDevice.preferences.presenceServiceUrl
  --   log.debug("**************(): url is " .. url1)
  --   local _, code = http.request({
  --       url = url1,
  --       sink = ltn12.sink.table(res_payload),
  --       method='GET',
  --       headers = {
  --           ["content-type"] = "application/json",
  --           ["connection"] = 'Keep-Alive'
  --       },
  --   })

  --   log.debug("*******************(): got code of " .. code);
  --   log.debug(res_payload[1])

  --   local o, pos, err = json.decode(res_payload[1])

  --   local size = 0
  --   for k,v in pairs(o) do
  --     log.debug(k .. "    " .. v)
  --       size = size + 1
  --   end

  --   log.debug("calling emit_event()")
  --   device:emit_event(capabilities.presenceSensor.presence.present())
  --   device.profile.components["main2"]:emit_event(capabilities.presenceSensor.presence("not present"))
  --   log.debug("CALLED emit_event")

  --   log.debug("now retrieving the value... ");


end

-- this is called when a device is removed by the cloud and synchronized down to the hub
local function device_removed(driver, device)
  log.info("[" .. device.id .. "] Removing my presence sensor")
  log.debug("killing the PollingTimer")
  if (PollingTimer ~= nil) then
    driver:cancel_timer(PollingTimer)
    PollingTimer = nil
  end
end

-- create the driver object
local myPresenceSensorDriver = Driver("myPresenceSensor", {
  discovery = discovery.handle_discovery,
  lifecycle_handlers = {
    added = device_added,
    init = device_init,
    removed = device_removed
  }
})



-- run the driver
log.debug("Running the driver..");
myPresenceSensorDriver:run()


