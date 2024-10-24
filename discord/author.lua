local Author = {}
Author.__index = Author

function Author.new(data)
    local self = setmetatable({}, Author)
    self.id = data.id
    self.username = data.username
    self.discriminator = data.discriminator
    self.avatar = data.avatar
    return self
end

return Author
