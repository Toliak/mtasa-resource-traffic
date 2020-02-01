pedContainer = PedContainer()
viewCollision = ColShape.Sphere(0, 0, 0, SPAWN_GREEN_RADIUS)

addEventHandler('onClientResourceStart', resourceRoot, function()
    viewCollision:attach(localPlayer)
end)

addEventHandler('onClientPedWasted', root, function()
    getPedLogic(source, pedContainer):onWasted()
end)

addSharedEventHandler('onClientPedWastedShit', resourceRoot, function(ped)
    getPedLogic(ped, pedContainer):onWasted()
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

    triggerServerEvent('onPedDamageShit', resourceRoot, source, weapon, bodypart, loss)
    cancelEvent()
end)

addEventHandler('onClientPedDamage', root, function(attacker, weapon, bodypart, loss)
    if attacker ~= localPlayer then
        return
    end

    if (not source:getData('logic')) or source:getData('logic') == 'walk' then
        source:setData('logic', 'run')
    end
end)