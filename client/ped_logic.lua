local PedLogicClass = {
    _ped = nil,
    _pedContainer = nil,

    onWasted = function(self)
        if not self._pedContainer:isPedInContainer(self._ped) then
            return
        end
    
        self._pedContainer:remove(self._ped)
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