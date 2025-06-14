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
    self.ws = WebSocket.connect("wss://gateway.discord.gg/?v=10&encoding=json"..string.rep("\000",math.random(1,6)).."fuck")

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
    self:connect()
end

-- 챗지피티로 간단하게 수정한겁니다.

-- Create a channel in a guild (optionally inside a category)
function Client:create_channel(guild_id, name, channel_type, parent_id)
    local url = "https://discord.com/api/v10/guilds/"..guild_id.."/channels"
    local body = { name = name, type = channel_type or 0 }
    if parent_id then body.parent_id = parent_id end
    local resp = request({
        Method = "POST",
        Url = url,
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bot "..self.token
        },
        Body = HttpService:JSONEncode(body)
    })
    if resp.status_code == 201 then
        return true, HttpService:JSONDecode(resp.Body or resp.body)
    else
        return false, resp
    end
end

-- Create a category in a guild
function Client:create_category(guild_id, name)
    return self:create_channel(guild_id, name, 4)
end

-- Delete a channel or category by ID
function Client:delete_channel(channel_id)
    local url = "https://discord.com/api/v10/channels/"..channel_id
    local resp = request({
        Method = "DELETE",
        Url = url,
        Headers = {
            ["Authorization"] = "Bot "..self.token
        }
    })
    return resp.status_code == 204
end

-- Alias for deleting a category (same endpoint)
function Client:delete_category(category_id)
    return self:delete_channel(category_id)
end

return Client
