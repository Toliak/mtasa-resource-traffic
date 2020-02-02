pedContainer = PedContainer()
playerCollision = PlayerCollision(ColShape.Sphere, { SPAWN_GREEN_RADIUS })

addSharedEventHandler('onPedRequest', resourceRoot, function(amount_)
    assert(type(amount_) == 'number')

    local task = coroutine.create(function(player, amount)
        local peds = pedFactory(player, amount)
        triggerClientEvent(player, 'onClientPedRequestAnswer', resourceRoot, peds)
    end)
    coroutine.resume(task, client, amount_)
end)

local function releasePeds(player, pedDict)
    for ped, dataTable in pairs(pedDict) do
        local newController = getPedStreamablePlayer(ped, SPAWN_RED_RADIUS, player)
        if newController == nil then
            pedContainer:destroy(player, ped)

        else
            -- Update data
            
            if type(dataTable) == 'table' then
                for key, value in pairs(dataTable) do
                    pedContainer:setData(ped, key, value)
                end
            end

            -- New controller
            
            if ped:getData('logic') == 'attack' then
                ped:setData('attackTarget', newController)
            end
            
            pedContainer:changePedController(player, ped, newController)
            triggerClientEvent(
                    newController,
                    'onClientPedRequestAnswer',
                    resourceRoot,
                    { [ped] = pedContainer:getAllData(ped) }
            )

            
        end
    end
end

-- When ped is no longer needed by client
addSharedEventHandler('onPedRelease', resourceRoot, function(pedDict_)
    local task = coroutine.create(releasePeds)
    coroutine.resume(task, client, pedDict_)
end)

addSharedEventHandler('onPedSetControlState', resourceRoot, function(ped_, stateTable_)
    local task = coroutine.create(function(exclude, ped, stateTable)
        local players = Element.getAllByType('player')
        local clientList = {}

        for _, player in pairs(players) do
            local distance = (player.position - ped.position):getLength()

            if exclude ~= player and distance <= SPAWN_GREEN_RADIUS then
                table.insert(clientList, player)
            end
        end

        triggerClientEvent(clientList, 'onClientPedKey', resourceRoot, ped, stateTable)
    end)
    coroutine.resume(task, client, ped_, stateTable_)
end)

addSharedEventHandler('onPedDamageShit', resourceRoot, function (ped, weapon, bodypart, loss)
    ped.health = ped.health - loss

    local isDead = pedContainer:getData(ped, 'dead')
    if ped.health <= 0 and not isDead then
        pedContainer:setData(ped, 'dead', true)
        triggerEvent('onPedWasted', ped, 0, client, weapon, bodypart)
        triggerClientEvent(ped:getSyncer(), 'onClientPedWastedShit', resourceRoot, ped)
    end
end)

addEventHandler('onPlayerQuit', root, function()
    local dict = pedContainer._table[source]

    if not dict then
        return
    end
    
    local task = coroutine.create(releasePeds)
    coroutine.resume(task, source, dict)
end)