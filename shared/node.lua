local PathNodeClass = {
    x = nil,
    y = nil,
    z = nil,
    id = nil,
    _links = nil,

    getPosition = function(self)
        return Vector3(self.x, self.y, self.z)
    end,

    setPosition = function(self, x, y, z)
        self.x = x
        self.y = y
        self.z = z
    end,

    setLink = function(self, linkName, id)
        assert(self._links[linkName] == nil, 'link with name "' .. linkName .. '" already exists')

        self._links[linkName] = id
    end,

    getLink = function(self, linkName)
        return self._links[linkName]
    end
}

function PathNode(x, y, z, links)
    links = links or {}

    local object = setmetatable({}, {
        __index = PathNodeClass,
    })

    object:setPosition(x, y, z)
    object._links = links

    return object
end