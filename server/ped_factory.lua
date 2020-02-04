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
    local SKILLS = { 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79 }

    local data = PED_DATA[math.random(1, #PED_DATA)]

    local ped = Ped(data.skin, position)
    ped:setWalkingStyle(data.walkingStyle)
    
    ped:setData('logic', data.defaultLogic)

    for _, skill in pairs(SKILLS) do
        ped:setStat(skill, math.random(100, 1000))
    end

    local randomWeapon = data.availableWeapons[math.random(1, #data.availableWeapons)]
    if randomWeapon ~= 0 then
        ped:giveWeapon(randomWeapon, 9999, true)
    end

    return ped
end

local function getAvailableGreenNodes(controller)
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

                -- check time availability
                if not pathNode:isPlayerCooldownActive(controller) then
                    table.insert(pathNodesGreen, pathNode)
                    pathNode:setPlayerCooldown(controller, NODE_SPAWN_COOLDOWN)
                end

            end
        end
    end

    return pathNodesGreen
end

function pedFactory(controller, amount)
    local available = MAX_PEDS - pedContainer:getLength(controller)
    available = math.min(available, amount)

    local collision = playerCollision:getOrCreateCollision(controller)
    local inCollision = #collision:getElementsWithin('ped')

    available = math.min(available, MAX_PEDS - inCollision, MAX_PED_PER_SPAWN)

    local pathNodesGreen = getAvailableGreenNodes(controller)

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