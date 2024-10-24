-- channel.lua
local HttpService = game:GetService("HttpService")
local Channel = {}
Channel.__index = Channel

function send(self, content, options)
    local url = "https://discord.com/api/v10/channels/" .. self.id .. "/messages"

    local body = {
        content = content
    }
    
    if options and options.reference then
        body.message_reference = {
            message_id = options.reference.message_id
        }
        body.allowed_mentions = options.reference.allowed_mentions
    end

    local requestOptions = {
        Method = "POST",
        Url = url,
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bot " .. self.token
        },
        Body = HttpService:JSONEncode(body)
    }

    local response = request(requestOptions)
    return response.status_code == 200
end

function Channel.new(channel_id, token)
    local self = setmetatable({}, Channel)
    self.id = channel_id
    self.token = token
    self.send = send
    return self
end

return Channel
