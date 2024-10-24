local old_require = require
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

local Client = require("discord/client.lua")

return {
    Client = Client.new
}
