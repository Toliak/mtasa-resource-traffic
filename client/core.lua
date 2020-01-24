SPAWN_RED_RADIUS = 25
SPAWN_GREEN_RADIUS = 40

MAX_PEDS = 100
CHECK_TIME = 100

local checkTimeLocal = CHECK_TIME
local pedContainer = PedContainer()

local function trigger()
    -- remove far peds
    local toRemove = pedContainer:removeIfNotInSphere(localPlayer.position, SPAWN_GREEN_RADIUS)
    -- TODO: send list to server
    for _, ped in pairs(toRemove) do
        ped:destroy()
    end

    -- spawn peds
    if pedContainer:getLength() >= MAX_PEDS then
        return
    end

    local position = localPlayer.position
    local pathNodes = PATH_TREE:findInSphere(position, SPAWN_GREEN_RADIUS)
    iprint(#pathNodes)
    for _, pathNode in pairs(pathNodes) do
        (function()
            local distance = (pathNode:getPosition() - position):getLength()
            if distance <= SPAWN_RED_RADIUS then
                return
            end

            --TODO: move to server-side
            local ped = Ped(303, pathNode:getPosition())
            pedContainer:append(ped)

            local states = {
                'forwards',
                'backwards',
                'left',
                'right',
            }
            ped:setControlState(states[math.random(1, #states)], true)
            ped:setControlState('walk', true)
        end)()
    end
end

addEventHandler('onClientPreRender', root, function(msec)
    if checkTimeLocal <= 0 then
        checkTimeLocal = 0

        -- lets do it
        trigger()

        return
    end

    checkTimeLocal = checkTimeLocal - msec
end)