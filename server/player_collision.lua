local PlayerCollisionClass = {
    _table = nil,           -- acts like HashMap
    _collision_constructor_args = nil,
    _collision_constructor = nil,

    createCollision = function(self, player)
        assert(self._table[player] == nil, 'Collision for player already exists')

        local position = player.position
        local collision = self._collision_constructor(position, unpack(self._collision_constructor_args))
        collision:attach(player)

        self._table[player] = collision
        return collision
    end,

    getCollision = function(self, player)
        return self._table[player]
    end,

    getOrCreateCollision = function(self, player)
        local collision = self:getCollision(player)
        if collision ~= nil then
            return collision
        end

        return self:createCollision(player)
    end,

    destroyCollision = function(self, player)
        assert(self._table[player] ~= nil, 'Collision for player does not exists')

        self._table[player]:detach(player)
        self._table[player]:destroy()
        self._table[player] = nil
    end,
}

function PlayerCollision(constructor, constructor_args)
    assert(constructor ~= nil)

    local object = setmetatable({},{
        __index = PlayerCollisionClass,
    })

    object._table = {}
    object._collision_constructor = constructor
    object._collision_constructor_args = constructor_args or {}

    return object
end