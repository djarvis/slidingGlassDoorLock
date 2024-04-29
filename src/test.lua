

 print()
print()
print()
print("***********************************")

local socket = require("socket")
local http = require("socket.http")
local ltn12 = require "ltn12"
local https = require ('ssl.https')
local json = require('dkjson')

local function sleep(n)
  socket.select(nil, nil, n)
end

print("***********************************")
print("**********************************")

local tcp = assert(socket.tcp())




while true do
  print "connecting..."
  tcp:settimeout(60)
  local success, connectError = tcp:connect("192.168.1.60", 80)

  print("called connect, success: " .. (success and success or "nil")  .. ", connectError: " .. (connectError and connectError or "nil"))

  local response;
  local err;

  while not err and not connectError do

    print "receiving..."
    local response, err, partial = tcp:receive()

    if not err then
      print("Received from server: " .. response)
    elseif err == "timeout" then
      print("We got a timeout and thus we are probably disconnected.");
      tcp:close();
      break;

    elseif err == "closed" then
      print "we are closed"
      tcp:close();
      break
    else
      print("Error: " .. err)
    end
  end

  print "sleeping for 3..."
  sleep(3)
  print "slept for 3"
end

-- Close the connection
tcp:close()

print("AND WE ARE DONE")


