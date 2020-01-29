pedContainer = PedContainer()
viewCollision = ColShape.Sphere(0, 0, 0, SPAWN_GREEN_RADIUS)

addEventHandler('onClientResourceStart', resourceRoot, function()
    viewCollision:attach(localPlayer)
end)

addEventHandler('onClientPedWasted', root, function()
    PedLogic(source, pedContainer):onWasted()
end)

addSharedEventHandler('onClientPedWastedShit', resourceRoot, function(ped)
    PedLogic(ped, pedContainer):onWasted()
end)

-- @param table control-state
local function setPedControlStateShared(ped, stateTable)
    for control, state in pairs(stateTable) do
        setPedControlState(ped, control, state)
    end
    triggerServerEvent('onPedSetControlState', resourceRoot, ped, stateTable)
end

function checkSpawn()
    -- spawn peds
    if pedContainer:getLength() < MAX_PEDS then
        triggerServerEvent('onPedRequest', resourceRoot, MAX_PEDS_PER_SPAWN)
    end
end
setTimer(checkSpawn, CHECK_TIME_SPAWN, 0)

function checkRelease()
    -- release far peds
    local toRemove = pedContainer:removeIfNotInSphere(localPlayer.position, SPAWN_GREEN_RADIUS)
    if #toRemove > 0 then
        local dict = {}
        for _, ped in pairs(toRemove) do
            dict[ped] = pedContainer:getAllData(ped)

            pedContainer:clearData(ped)
        end

        triggerServerEvent('onPedRelease', resourceRoot, dict)
    end
end
setTimer(checkRelease, CHECK_TIME_RELEASE, 0)

function checkPedKeys()
    local pedList = pedContainer:toList()
    for _, ped in pairs(pedList) do

        local logic = PedLogic(ped, pedContainer)

        logic:updateRotationTo()

        local states = {
            forwards = false,
            backwards = false,
            left = false,
            right = false,
        }
        local keys = {
            'forwards',
        }

        states[keys[math.random(1, #keys)]] = true
        states['walk'] = true

        setPedControlStateShared(ped, states)
    end
end
setTimer(checkPedKeys, CHECK_TIME_PED_KEYS, 0)

function checkPedRotation(msec)
    local pedList = viewCollision:getElementsWithin('ped')
    for _, ped in pairs(pedList) do
        local logic = PedLogic(ped, pedContainer)
        
        logic:checkAndSetSpawnRotation()
        logic:checkAndUpdateRotation(msec)
    end
end
addEventHandler('onClientPreRender', root, checkPedRotation)

function checkPedState()
    local pedList = pedContainer:toList()
    for _, ped in pairs(pedList) do

        PedLogic(ped, pedContainer):checkAndUpdateNextNode()
    end
end
setTimer(checkPedState, CHECK_TIME_PED_STATE, 0)

-- damage sync
addEventHandler('onClientPedDamage', root, function(attacker, weapon, bodypart, loss)
    if getElementType(attacker) == 'player' then
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

    -- event provided by
    -- https://github.com/multitheftauto/mtasa-blue/blob/e11685cab4beb7958ab202261f9c9d9b4ce71e58/Server/mods/deathmatch/logic/CPedSync.cpp#L240
    triggerServerEvent('onPedDamageShit', resourceRoot, source, weapon, bodypart, loss)
    cancelEvent()
end)