local pedContainer = PedContainer()

addEvent('onClientPedRequestAnswer', true)
addEventHandler('onClientPedRequestAnswer', resourceRoot, function(peds)
    for _, ped in pairs(peds) do
        pedContainer:append(ped)
    end
end)

local function trigger()
    -- spawn peds
    if pedContainer:getLength() < MAX_PEDS then
        triggerServerEvent('onPedRequest', resourceRoot, MAX_PEDS - pedContainer:getLength())
    end

    -- remove far peds
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
                    'forwards',
                    'backwards',
                    'left',
                    'right',
                }
                for _, state in pairs(states) do
                    ped:setControlState(state, false)
                end

                ped:setControlState(states[math.random(1, #states)], true)
                ped:setControlState('walk', true)
            end
            --end

            return
        end

        checkTimeLocal = checkTimeLocal - msec
    end)
end)();