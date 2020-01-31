addSharedEventHandler('onClientPedRequestAnswer', resourceRoot, function(pedDict)
    for ped, data in pairs(pedDict) do
        pedContainer:append(ped)

        for key, value in pairs(data) do
            pedContainer:setData(ped, key, value)
        end

        local logic = PedLogic(ped, pedContainer)
        logic:checkAndUpdateDirection()
        logic:updateNextNode()
        logic:updateNextNodeHelper()
        logic:updateRotationTo(true)
    end
end)

addSharedEventHandler('onClientPedKey', resourceRoot, function(ped, stateTable)
    for control, state in pairs(stateTable) do
        setPedControlState(ped, control, state)
    end
end)

local function checkSpawn()
    -- spawn peds
    if pedContainer:getLength() < MAX_PEDS then
        triggerServerEvent('onPedRequest', resourceRoot, MAX_PEDS_PER_SPAWN)
    end
end
setTimer(checkSpawn, CHECK_TIME_SPAWN, 0)

local function checkRelease()
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