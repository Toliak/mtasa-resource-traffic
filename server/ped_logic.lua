local PedLogicClass = {
    _ped = nil,
    _pedContainer = nil,

    remove = function(self)
        if not isElement(self._ped) then
            return      -- ped is already removed
        end

        local controller = self._ped:getSyncer()
        if not isElement(controller) then
            return      -- ped is already removed
        end

        self._pedContainer:destroy(controller, self._ped)
    end,
}

function PedLogic(ped, pedContainer)
    local object = setmetatable({}, {
        __index = PedLogicClass,
    })

    object._ped = ped
    object._pedContainer = pedContainer

    return object
end