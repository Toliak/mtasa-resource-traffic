local PathNodeClass = {
    x = nil,
    y = nil,
    z = nil,
    id = nil,
    _links = nil,
    _cooldownTable = nil,

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

    addLink = function(self, linkName, id)
        if not self._links[linkName] then
            self._links[linkName] = {}
        end

        table.insert(self._links[linkName], id)
    end,

    getLink = function(self, linkName)
        return self._links[linkName]
    end,

    getPlayerCooldown = function(self, player)
        if not self._cooldownTable[player] then
            return 0
        end

        return self._cooldownTable[player]
    end,

    -- Returns false if cooldown time is now
    isPlayerCooldownActive = function(self, player)
        if not self._cooldownTable[player] then
            return false
        end

        return self._cooldownTable[player] >= getTickCount()
    end,

    setPlayerCooldown = function(self, player, time)
        self._cooldownTable[player] = getTickCount() + time
    end,
}

function PathNode(x, y, z, links)
    local object = setmetatable({}, {
        __index = PathNodeClass,
    })

    object:setPosition(x, y, z)
    object._links = links or {}
    object._cooldownTable = {}

    return object
end