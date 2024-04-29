-- new
local capabilities = require "st.capabilities"
local utils = require('st.utils')
local neturl = require('net.url')
local log = require('log')
local json = require('dkjson')
local cosock = require "cosock"
local http = cosock.asyncify "socket.http"
local ltn12 = require('ltn12')


-- old
-- local http = require("socket.http")
-- local ltn12 = require "ltn12"
-- local https = require ('ssl.https')

return {

    query = function(timeout, url, theDevice)
        http.TIMEOUT = timeout
        log.debug("query(): begin");
        local res_payload = {}
        local url1 = TheDevice.preferences.presenceServiceUrl
        log.debug("**************(): url is " .. url1)
        local body, statusCode, headers, statusText = http.request({
            url = url1,
            sink = ltn12.sink.table(res_payload),
            method='GET',
            headers = {
                ["content-type"] = "application/json",
                ["connection"] = 'Keep-Alive'
            },
        })

    --
    -- Only do the following if we were successful
    --
    if (statusCode == 200) then
        log.debug(res_payload[1])

        local o, pos, err = json.decode(res_payload[1])

        local newDevice1Presence = "not present";
        local newDevice2Presence = "not present";

        for k,v in pairs(o) do
            if (v:upper() == TheDevice.preferences.macAddress1:upper()) then
                newDevice1Presence = "present"
            end
            if (v:upper() == TheDevice.preferences.macAddress2:upper()) then
                newDevice2Presence = "present"
            end
            log.debug(k .. "    " .. v)
        end


        --
        -- Set the presence indicators if they are different from what was before
        --
        if (Device1Presence ~= newDevice1Presence) then
            Device1Presence = newDevice1Presence
            TheDevice.profile.components["main"]:emit_event(capabilities.presenceSensor.presence(Device1Presence))
        end
        
        if (Device2Presence ~= newDevice2Presence) then
            Device2Presence = newDevice2Presence
            TheDevice.profile.components["main2"]:emit_event(capabilities.presenceSensor.presence(Device2Presence))
        end
    else
        log.debug("Tried to retrieve presences from service but got this as a status code: " .. statusCode)
    end

    end,


}