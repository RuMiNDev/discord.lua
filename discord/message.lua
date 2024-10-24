local HttpService = game:GetService("HttpService")
local Channel = require("discord/channel.lua")
local Author = require("discord/author.lua")
local Message = {}
Message.__index = Message

function reply(self, content, mention)
    local mentionFlag = mention ~= nil and mention or true
    self.channel:send(content, {
        reference = {
            message_id = self.id,
            allowed_mentions = {
                parse = { "users", "roles", "everyone" },
                replied_user = mentionFlag
            }
        }
    })
end

function edit(self, content)
    local url = "https://discord.com/api/v10/channels/" .. self.channel.id .. "/messages/" .. self.id

    local options = {
        Method = "PATCH",
        Url = url,
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bot " .. self.token
        },
        Body = HttpService:JSONEncode({
            content = content
        })
    }

    local response = request(options)
    return response.status_code == 200
end

function delete(self)
    local url = "https://discord.com/api/v10/channels/" .. self.channel.id .. "/messages/" .. self.id

    local options = {
        Method = "DELETE",
        Url = url,
        Headers = {
            ["Authorization"] = "Bot " .. self.token
        }
    }

    local response = request(options)
    return response.status_code == 200
end

function Message.new(data, token)
    local self = setmetatable({}, Message)
    self.id = data.id
    self.content = data.content
    self.channel = Channel.new(data.channel_id, token)
    self.author = Author.new(data.author)
    self.token = token
    self.reply = reply
    self.edit = edit
    self.delete = delete
    return self
end

return Message
