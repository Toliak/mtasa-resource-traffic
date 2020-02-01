function getPedLogic(ped, ...)
    local logicName = ped:getData('logic')

    if type(logicName) ~= 'string' or logicName == 'walk' then
        return PedLogicWalk(ped, ...)

    elseif logicName == 'run' then
        return PedLogicRun(ped, ...)

    elseif logicName == 'attack' then
        return PedLogicAttack(ped, ...)
        
    end

    return PedLogicWalk(ped, ...)
end