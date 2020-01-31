function getPedLogic(ped, ...)
    local logicName = ped:getData('logic')
    if type(logicName) ~= 'string' or logicName == 'walk' then
        return PedLogicWalk(ped, ...)
    end

    return PedLogicWalk(ped, ...)
end