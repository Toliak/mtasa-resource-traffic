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

function pedFactory(controller, amount)
    local SKINS = { 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44,
                    45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61,
                    63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92,
                    93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150,
                    151, 152, 157 }

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
        local skin = SKINS[math.random(1, #SKINS)]

        local node = nil 
        if i <= #pathNodesGreen then
            node = pathNodesGreen[i]
        else
            node = pathNodesGreen[math.random(1, #pathNodesGreen)]
        end
        local spawnNode = randomSpawnNode(node)

        local ped = pedContainer:createPed(controller, skin, node)
        ped:setPosition(spawnNode:getPosition())
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