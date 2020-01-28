pedContainer = PedContainer()
viewCollision = ColShape.Sphere(0,0,0,SPAWN_RED_RADIUS)

addEventHandler('onClientResourceStart', resourceRoot, function()
    viewCollision:attach(localPlayer)
end)

addSharedEventHandler('onClientPedRequestAnswer', resourceRoot, function(pedDict)
    for ped, data in pairs(pedDict) do
        pedContainer:append(ped)
        -- TODO: data
    end
end)

addSharedEventHandler('onClientPedKey', resourceRoot, function(ped, stateTable)
    for control, state in pairs(stateTable) do
        setPedControlState(ped, control, state)
    end
end)

-- @param table control-state
local function setPedControlStateShared(ped, stateTable)
    for control, state in pairs(stateTable) do
        setPedControlState(ped, control, state)
    end
    triggerServerEvent('onPedSetControlState', resourceRoot, ped, stateTable)
end

local function trigger()
    -- spawn peds
    if pedContainer:getLength() < MAX_PEDS then
        triggerServerEvent('onPedRequest', resourceRoot, MAX_PEDS_PER_SPAWN)
    end
end

local function triggerRelease()
    -- release far peds
    local toRemove = pedContainer:removeIfNotInSphere(localPlayer.position, SPAWN_GREEN_RADIUS)
    if #toRemove > 0 then
        triggerServerEvent('onPedRelease', resourceRoot, toRemove)
    end
end

-- TODO FIXME govnocode
-- spawn checker
(function()
    local checkTimeLocal = CHECK_TIME_SPAWN

    addEventHandler('onClientPreRender', root, function(msec)
        if checkTimeLocal == nil then
            checkTimeLocal = CHECK_TIME_SPAWN
            return
        end

        if checkTimeLocal <= 0 then
            checkTimeLocal = CHECK_TIME_SPAWN

            -- lets do it
            trigger()

            return
        end

        checkTimeLocal = checkTimeLocal - msec
    end)
end)();

-- release checker
(function()
    local checkTimeLocal = CHECK_TIME_RELEASE

    addEventHandler('onClientPreRender', root, function(msec)
        if checkTimeLocal == nil then
            checkTimeLocal = CHECK_TIME_RELEASE
            return
        end

        if checkTimeLocal <= 0 then
            checkTimeLocal = CHECK_TIME_RELEASE

            -- lets do it
            triggerRelease()

            return
        end

        checkTimeLocal = checkTimeLocal - msec
    end)
end)();

-- state checker
(function()
    local checkTimeLocal = CHECK_TIME_PED_STATE

    addEventHandler('onClientPreRender', root, function(msec)
        if checkTimeLocal == nil then
            checkTimeLocal = CHECK_TIME_PED_STATE
            return
        end

        if checkTimeLocal <= 0 then
            checkTimeLocal = CHECK_TIME_PED_STATE

            -- lets do it
            local pedList = pedContainer:toList()
            for _, ped in pairs(pedList) do
                local states = {
                    forwards = false,
                    backwards = false,
                    left = false,
                    right = false,
                }
                local keys= {
                    'forwards',
                    'backwards',
                    'left',
                    'right',
                }

                states[keys[math.random(1, #keys)]] = true
                states['walk'] = true

                setPedControlStateShared(ped, states)
            end
            --end

            return
        end

        checkTimeLocal = checkTimeLocal - msec
    end)
end)();