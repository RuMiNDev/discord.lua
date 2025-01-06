local HttpService = game:GetService("HttpService")
local Message = require("discord/message.lua")
local Channel = require("discord/channel.lua")
local Client = {}
Client.__index = Client

function Client.new(token)
    local self = setmetatable({}, Client)
    self.token = token
    self.ws = nil
    self.heartbeatInterval = 0
    self.lastHeartbeatSent = os.time()
    self.event_objects = {
        on_ready = Instance.new("BindableEvent");
        on_message = Instance.new("BindableEvent");
    }
    self.events = {
        on_ready = self.event_objects.on_ready.Event;
        on_message = self.event_objects.on_message.Event;
    }
    return self
end

function Client:connect()
    self.ws = WebSocket.connect("wss://gateway.discord.gg/?v=10&encoding=json")

    self.ws.OnMessage:Connect(function(data)
        local jsonData = HttpService:JSONDecode(data)

        if jsonData.op == 10 then
            self.heartbeatInterval = jsonData.d.heartbeat_interval
            self:startHeartbeat()
        elseif jsonData.op == 0 then
            if jsonData.t == "READY" and self.events.on_ready then
                self.event_objects.on_ready:Fire()
            elseif jsonData.t == "MESSAGE_CREATE" and self.events.on_message then
                local messageObj = Message.new(jsonData.d, self.token)
                self.event_objects.on_message:Fire(messageObj)
            end
        end
    end)

    self:identify()
end

function Client:fetch_channel(channel_id)
    return Channel.new(channel_id, self.token)
end

function Client:startHeartbeat()
    spawn(function()
        while true do
            wait(self.heartbeatInterval / 1000)

            self:sendHeartbeat()
        end
    end)
end

function Client:sendHeartbeat()
    local heartbeatPayload = HttpService:JSONEncode({
        op = 1,
        d = os.time()
    })

    self.ws:Send(heartbeatPayload)
    print("Heartbeat sent at: " .. os.time())
end

function Client:identify()
    local identifyPayload = HttpService:JSONEncode({
        op = 2,
        d = {
            token = self.token,
            properties = {
                ["$os"] = "linux",
                ["$browser"] = "roblox",
                ["$device"] = "roblox"
            },
            intents = 33349
        }
    })

    self.ws:Send(identifyPayload)
    print("Identify payload sent")
end

function Client:on(event, callback)
    if self.events[event] then
        self.events[event]:Connect(callback)
    else
        error("Unsupported event: " .. event)
    end
end

function Client:reconnect()
    self.ws:Close()
    print("Reconnecting to Discord Gateway...")
    self:connect()
end

return Client
