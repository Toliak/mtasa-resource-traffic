local pedContainer = PedContainer()
local playerCollision = PlayerCollision(ColShape.Sphere, {SPAWN_RED_RADIUS})

local function pedFactory(controller, amount)
    local SKINS = { 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44,
                    45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61,
                    63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92,
                    93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150,
                    151, 152, 157 }

    local available = MAX_PEDS - pedContainer:getLength(controller)
    available = math.min(available, amount)

    local collision = playerCollision:getOrCreateCollision(controller)
    local inCollision = #collision:getElementsWithin('ped')

    available = math.min(available,  MAX_PEDS - inCollision)

    -- get and filter path nodes
    local pathNodes = PATH_TREE:findInSphere(controller.position, SPAWN_GREEN_RADIUS)
    local pathNodesGreen = {}                         -- filtered path nodes
    for _, pathNode in pairs(pathNodes) do
        local distance = (pathNode:getPosition() - controller.position):getLength()
        if distance > SPAWN_RED_RADIUS then
            table.insert(pathNodesGreen, pathNode)
        end
    end

    if #pathNodesGreen == 0 then
        return {}
    end

    local result = {}
    for i = 1, available do
        local skin = SKINS[math.random(1, #SKINS)]
        local node = pathNodesGreen[math.random(1, #pathNodesGreen)]

        local ped = pedContainer:createPed(controller, skin, node)
        table.insert(result, ped)
    end

    return result
end

addEvent('onPedRequest', true)
addEventHandler('onPedRequest', resourceRoot, function(amount_)
    assert(type(amount_) == 'number')

    local task = coroutine.create(function(player, amount)
        local peds = pedFactory(player, amount)
        triggerClientEvent(player, 'onClientPedRequestAnswer', resourceRoot, peds)
    end)
    coroutine.resume(task, client, amount_)
end)

-- When ped is no longer needed by client
addEvent('onPedRelease', true)
addEventHandler('onPedRelease', resourceRoot, function(pedList_)
    local task = coroutine.create(function(player, pedList)
        for _, ped in pairs(pedList) do
            local newController = getPedStreamablePlayer(ped, SPAWN_RED_RADIUS, player)
            if newController == nil then
                pedContainer:destroy(player, ped)
            else
                pedContainer:changePedController(player, ped, newController)
                triggerClientEvent(newController, 'onClientPedRequestAnswer', resourceRoot, {ped})
            end

        end
    end)
    coroutine.resume(task, client, pedList_)
end)

addEvent('onPedSetControlState', true)
addEventHandler('onPedSetControlState', resourceRoot, function(ped_, control_, state_)
    local task = coroutine.create(function(exclude, ped, control, state)
        local players = Element.getAllByType('player')
        local clientList = {}

        for _, player in pairs(players) do
            local distance = (player.position - ped.position):getLength()

            if exclude ~= player and distance <= SPAWN_GREEN_RADIUS then
                table.insert(clientList, player)
            end
        end

        triggerClientEvent(clientList, 'onClientPedKey', resourceRoot, ped, control, state)
    end)
    coroutine.resume(task, client, ped_, control_, state_)
end)