local PedLogicClass = {
    _ped = nil,
    _pedContainer = nil,

    remove = function(self)
        local controller = self._ped:getSyncer()
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