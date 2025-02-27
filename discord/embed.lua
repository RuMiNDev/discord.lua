local Embed = {}
Embed.__index = Embed

function Embed.new(options)
    local self = setmetatable({}, Embed)
    self.title = options.title or ""
    self.description = options.description or ""
    self.color = options.color or 0xFFFFFF
    self.fields = {}
    self.footer = nil
    self.image = nil
    self.thumbnail = nil
    self.author = nil
    self.timestamp = nil

    function Embed:add_field(options)
        table.insert(self.fields, {
            name = options.name or "",
            value = options.value or "",
            inline = options.inline or false
        })
        return self
    end
    
    function Embed:set_footer(options)
        self.footer = {
            text = options.text or "",
            icon_url = options.icon_url or ""
        }
        return self
    end
    
    function Embed:set_image(url)
        self.image = { url = url }
        return self
    end
    
    function Embed:set_thumbnail(url)
        self.thumbnail = { url = url }
        return self
    end
    
    function Embed:set_author(options)
        self.author = {
            name = options.name or "",
            url = options.url or "",
            icon_url = options.icon_url or ""
        }
        return self
    end
    
    function Embed:set_timestamp(timestamp)
        self.timestamp = timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ")
        return self
    end
    
    function Embed:to_table()
        return {
            title = self.title,
            description = self.description,
            color = self.color,
            fields = self.fields,
            footer = self.footer,
            image = self.image,
            thumbnail = self.thumbnail,
            author = self.author,
            timestamp = self.timestamp
        }
    end

    return self
end

return Embed
