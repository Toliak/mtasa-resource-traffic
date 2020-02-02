PedLogicRunClass = classCopy(PedLogicWalkClass)

PedLogicRunClass.getControlStatesDefault = function()
    local result = PedLogicWalkClass:getControlStatesDefault()

    result['walk'] = false
    result['sprint'] = true

    return result
end

PedLogicRunClass.getWaitTime = function(self)
    return 0
end

PedLogicRunClass.getGoAroundTime = function(self)
    return PED_GO_AROUND_TIME / 2
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