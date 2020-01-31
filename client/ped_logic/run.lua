PedLogicRunClass = classCopy(PedLogicWalkClass)

PedLogicRunClass.getControlStatesDefault = function()
    local result = PedLogicWalkClass:getControlStatesDefault()

    result['walk'] = false
    result['sprint'] = true

    return result
end

PedLogicRunClass.checkAndUpdateWait = function(self, waitTime)
    if self._ped:getData('waiting') then
        self._ped:setData('waiting', false)
    end
end

function PedLogicRun(ped, pedContainer)
    local object = setmetatable({}, {
        __index = PedLogicRunClass,
    })

    object._ped = ped
    object._pedContainer = pedContainer

    if not customData[ped] then
        customData[ped] = {}
    end

    return object
end