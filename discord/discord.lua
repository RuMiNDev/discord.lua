if not getgenv()["old_require"] then
    getgenv().services = setmetatable({},{
        __index=function(self,index)
            return game:GetService(index)
        end
    })    
    getgenv()["old_require"] = require
    getgenv()['require'] = function(asset)
        if typeof(asset) == "string" then
            if not isfile(asset) then
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/xsinew/discord.lua/refs/heads/main/"..asset))()
            else
                return loadfile(asset)()
            end
        else
            return old_require(asset)
        end
    end
end

local Client = require("discord/client.lua")
local Embed = require("discord/embed.lua")

return {
    Client = Client.new;
    Embed = Embed.new
}
