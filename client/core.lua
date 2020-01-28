pedContainer = PedContainer()
viewCollision = ColShape.Sphere(0, 0, 0, SPAWN_RED_RADIUS)

addEventHandler('onClientResourceStart', resourceRoot, function()
    viewCollision:attach(localPlayer)
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
        triggerServerEvent('onPedRelease', resourceRoot, toRemove)
    end
end
setTimer(checkRelease, CHECK_TIME_RELEASE, 0)

function checkPedState()
    local pedList = pedContainer:toList()
    for _, ped in pairs(pedList) do
        local states = {
            forwards = false,
            backwards = false,
            left = false,
            right = false,
        }
        local keys = {
            'forwards',
            'backwards',
            'left',
            'right',
        }

        states[keys[math.random(1, #keys)]] = true
        states['walk'] = true

        setPedControlStateShared(ped, states)
    end
end
setTimer(checkPedState, CHECK_TIME_PED_STATE, 0)
