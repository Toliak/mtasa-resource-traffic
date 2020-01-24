local PedDataClass = {
    controller = nil
}

function PedData()
    return setmetatable({}, {
        __index = PedDataClass
    })
end

local PedContainerClass = {
    _table = nil, -- acts like HashMap<Player (controller), HashSet (peds)>

    getLength = function(self, controller)
        local length = 0
        if controller == nil then
            for _, insideTable in pairs(self._table) do
                for _, _ in pairs(insideTable) do
                    length = length + 1
                end
            end
            return length
        end

        for _, _ in pairs(self._table[controller] or {}) do
            length = length + 1
        end
        return length
    end,

    append = function(self, controller, ped)
        assert(isElement(controller), 'PedList.append expected Player at argument 2')
        assert(isElement(ped), 'PedList.append expected Ped at argument 3')
        assert(getElementType(ped) == 'ped', 'PedList.append expected Ped at argument 3')

        if self._table[controller] == nil then
            self._table[controller] = {}
        end
        self._table[controller][ped] = ped
    end,

    createPed = function(self, controller, pedSkin, pathNode)
        assert(isElement(controller), 'PedList.createPed expected Player at argument 2')

        local ped = Ped(pedSkin, pathNode:getPosition())
        data = data or PedData()

        self:append(controller, ped)
        return ped
    end,

    destroy = function(self, controller, ped)
        assert(isElement(controller), 'PedList.destroy expected Player at argument 2')
        assert(isElement(ped), 'PedList.destroy expected Ped at argument 3')
        assert(getElementType(ped) == 'ped', 'PedList.append expected Ped at argument 3')

        assert(self._table[controller] ~= nil, 'No controller')
        assert(self._table[controller][ped] ~= nil, 'No ped')

        self._table[controller][ped] = nil
        ped:destroy()
    end,

    changePedController = function(self, oldController, ped, newController)
        assert(isElement(oldController), 'PedList.changePedController expected Ped at argument 2')
        assert(isElement(newController), 'PedList.changePedController expected Ped at argument 4')
        assert(isElement(ped), 'PedList.changePedController expected Ped at argument 2')
        assert(getElementType(ped) == 'ped', 'PedList.changePedController expected Ped at argument 2')

        self._table[oldController][ped] = nil
        self:append(newController, ped)
    end

}

-- Get player, who can take control on the Ped
function getPedStreamablePlayer(self, maxDistance, exclude)
    local players = Element.getAllByType('player')

    for _, player in pairs(players) do
        local distance = (player.position - self.position):getLength()

        if exclude ~= player and distance <= maxDistance then
            return player
        end
    end

    return nil
end

function PedContainer()
    local object = setmetatable({}, {
        __index = PedContainerClass,
    })

    object._table = {}

    return object
end