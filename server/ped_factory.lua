local function shuffle(t)
    local rand = math.random 
    assert(t, "table.shuffle() expected a table, got nil")
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

local function randomSpawnNode(sourceNode)
    local nodes = {sourceNode,}

    local helperIds = sourceNode:getLink('helper')
    if helperIds and #helperIds ~= 0 then
        for _, id in pairs(helperIds) do
            table.insert(nodes, PATH_HELPER_LIST[id])
        end
    end

    return nodes[math.random(1, #nodes)]
end

local function createRandomPed(position)
    local PED_DATA = { 
        {35, 118},
        {43, 118},
        {46, 118},
    }
    local data = PED_DATA[math.random(1, #PED_DATA)]

    local ped = Ped(data[1], position)
    ped:setWalkingStyle(data[2])
    return ped
end

function pedFactory(controller, amount)
    local available = MAX_PEDS - pedContainer:getLength(controller)
    available = math.min(available, amount)

    local collision = playerCollision:getOrCreateCollision(controller)
    local inCollision = #collision:getElementsWithin('ped')

    available = math.min(available, MAX_PEDS - inCollision)

    -- get and filter path nodes
    local pathNodes = PATH_TREE:findInSphere(controller.position, SPAWN_GREEN_RADIUS)
    local pathNodesGreen = {}                         -- filtered path nodes
    for _, pathNode in pairs(pathNodes) do
        -- we can't spawn peds in red zone of any player
        local playerBlocked = false
        local players = Element.getAllByType('player')
        for _, player in pairs(players) do
            local distance = (pathNode:getPosition() - player.position):getLength()
            if distance <= SPAWN_RED_RADIUS then
                playerBlocked = true
            end
        end

        if not playerBlocked then
            local distance = (pathNode:getPosition() - controller.position):getLength()
            if distance > SPAWN_RED_RADIUS then
                table.insert(pathNodesGreen, pathNode)
            end
        end
    end

    if #pathNodesGreen == 0 then
        return {}
    end
    shuffle(pathNodesGreen)

    local result = {}
    for i = 1, available do
        local node = nil 
        if i <= #pathNodesGreen then
            node = pathNodesGreen[i]
        else
            node = pathNodesGreen[math.random(1, #pathNodesGreen)]
        end
        local spawnNode = randomSpawnNode(node)

        local ped = createRandomPed(spawnNode:getPosition())

        pedContainer:append(controller, ped)
        pedContainer:setData(ped, 'nextNodeId', node.id)

        -- DEBUG
        if math.random() > 0.7 then
            ped:setData('logic', 'attack')
        else
            ped:setData('logic', 'walk')
        end
        ped:setData('attackTarget', controller)

        local random = math.random()
        if random > 0.8 then
            ped:giveWeapon(31, 9999, true)
        elseif random > 0.5 then
            ped:giveWeapon(25, 9999, true)
        elseif random > 0.3 then
            ped:giveWeapon(22, 9999, true)
        end


        result[ped] = pedContainer:getAllData(ped)

        local logic = PedLogic(ped, pedContainer)
        addEventHandler('onPedWasted', ped, function()
            pedContainer:setData(ped, 'dead', true)

            setTimer(
                function() logic:remove() end,
                PED_DEATH_REMOVE, 
                1
            )
        end)
    end

    return result
end