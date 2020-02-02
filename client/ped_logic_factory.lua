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

function changePedLogic(ped)
    local logicName = ped:getData('logic')
    if logicName == 'attack' then
        local target = ped:getData('attackTarget')
        
        if not isElement(target) or target:isDead() then
            ped:setData('logic', 'walk')
            ped:setData('attackTarget', false)
        end
    end
end