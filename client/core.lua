pedContainer = PedContainer()
viewCollision = ColShape.Sphere(0, 0, 0, SPAWN_GREEN_RADIUS)

addEventHandler('onClientResourceStart', resourceRoot, function()
    viewCollision:attach(localPlayer)
end)

addEventHandler('onClientPedWasted', root, function()
    getPedLogic(source, pedContainer):onWasted()
end)

-- @param table control-state
local function setPedControlStateShared(ped, stateTable)
    for control, state in pairs(stateTable) do
        setPedControlState(ped, control, state)
    end
    triggerServerEvent('onPedSetControlState', resourceRoot, ped, stateTable)
end

function checkPedKeys()
    local peds = pedContainer._table
    for ped, _ in pairs(peds) do
        local logic = getPedLogic(ped, pedContainer)

        logic:updateRotation()

        local states = logic:getControlStates()
        setPedControlStateShared(ped, states)
    end
end
setTimer(checkPedKeys, CHECK_TIME_PED_KEYS, 0)

function checkPedRotation(msec)
    local pedList = viewCollision:getElementsWithin('ped')
    for _, ped in pairs(pedList) do
        local logic = getPedLogic(ped, pedContainer)
        
        logic:checkAndSetSpawnRotation()
        logic:checkAndUpdateRotation()
    end
end
addEventHandler('onClientPreRender', root, checkPedRotation)

function checkPedTarget(msec)
    local pedList = viewCollision:getElementsWithin('ped')
    for _, ped in pairs(pedList) do
        local logic = getPedLogic(ped, pedContainer)

        logic:checkAndUpdateTarget()
    end
end
addEventHandler('onClientRender', root, checkPedTarget)

function checkPedState()
    local peds = pedContainer._table
    for ped, _ in pairs(peds) do
        local logic = getPedLogic(ped, pedContainer)

        logic:checkAndUpdateNextNode()
        logic:updateNextNodeHelper()

        logic:checkAndUpdateSight()
        
        changePedLogic(ped)     -- check logic change
    end
end
setTimer(checkPedState, CHECK_TIME_PED_STATE, 0)

-- damage sync
addEventHandler('onClientPedDamage', root, function(attacker, weapon, bodypart, loss)
    if isElement(attacker) and getElementType(attacker) == 'player' then
        if attacker ~= localPlayer and pedContainer:isPedInContainer(source) then
            cancelEvent()
        end
    end

    if getElementType(source) ~= 'ped' then
        return
    end
    if attacker ~= localPlayer or pedContainer:isPedInContainer(source) then
        return
    end

    if bodypart == 9 then
        loss = 1000
    end
    triggerServerEvent('onPedDamageShit', resourceRoot, source, weapon, bodypart, loss)
    cancelEvent()
end)

-- headshot
addEventHandler('onClientPedDamage', root, function(attacker, weapon, bodypart, loss)
    if attacker ~= localPlayer then
        return
    end

    if bodypart ~= 9 then
        return
    end
    
    triggerServerEvent('onPedHeadshotShit', resourceRoot, source)
end)

-- TODO: should it work for all (include not cotrolled) peds ??
addEventHandler('onClientPedDamage', root, function(attacker, weapon, bodypart, loss)
    if isElement(attacker) and attacker:getType() == 'player' and attacker ~= localPlayer then
        return
    end

    if (not source:getData('logic')) or source:getData('logic') == 'walk' then
        if source:getWeapon() ~= 0 then
            local target = nil
            if isElement(attacker) and attacker:getType() == 'vehicle' and attacker:getOccupant(0) then
                target = attacker:getOccupant(0)
            elseif isElement(attacker) and (attacker:getType() == 'player' or attacker:getType() == 'ped') then
                target = attacker
            end
            
            if isElement(target) then
                source:setData('attackTarget', target)
                source:setData('logic', 'attack')
            end
            
            return
        end

        source:setData('logic', 'run')
    end
end)