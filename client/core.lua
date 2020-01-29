pedContainer = PedContainer()
viewCollision = ColShape.Sphere(0, 0, 0, SPAWN_GREEN_RADIUS)

addEventHandler('onClientResourceStart', resourceRoot, function()
    viewCollision:attach(localPlayer)
end)

addEventHandler('onClientPedWasted', root, function()
    if not pedContainer:isPedInContainer(source) then
        return
    end

    pedContainer:remove(source)
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
        local dict = {}
        for _, ped in pairs(toRemove) do
            dict[ped] = pedContainer:getAllData(ped)

            pedContainer:clearData(ped)
        end

        triggerServerEvent('onPedRelease', resourceRoot, dict)
    end
end
setTimer(checkRelease, CHECK_TIME_RELEASE, 0)

function updatePedRotation(ped, node)
    local angle = getAngleBetweenPoints(ped:getPosition(), node:getPosition())
    local rotation = getNormalAngle(math.deg(angle) - 90)

    --ped:setRotation(Vector3(0, 0, rotation))
    -- pedContainer:setData(ped, 'rotateTo', rotation)
    ped:setData('rotateTo', rotation, true)
    -- ped:setCameraRotation(rotation)
    --ped:setLookAt(node:getPosition())
    --ped:setAimTarget(node:getPosition())
end

function checkPedKeys()
    local pedList = pedContainer:toList()
    for _, ped in pairs(pedList) do

        local nextNodeId = pedContainer:getData(ped, 'nextNodeId')
        local nextNode = PATH_LIST[nextNodeId]
        local direction = pedContainer:getData(ped, 'direction')

        if direction == nil then
            local ALL_DIRECTION_LIST = { 'forward', 'backward' }

            -- collect available directions
            local availableDirectionList = {}
            for _, dir in pairs(ALL_DIRECTION_LIST) do
                local links = nextNode:getLink(dir)
                if links and #links ~= 0 then
                    table.insert(availableDirectionList, dir)
                end
            end

            local newDirection = availableDirectionList[math.random(1, #availableDirectionList)]
            pedContainer:setData(ped, 'direction', newDirection)
            direction = newDirection
        end

        updatePedRotation(ped, nextNode)

        local states = {
            forwards = false,
            backwards = false,
            left = false,
            right = false,
        }
        local keys = {
            'forwards',
        }

        states[keys[math.random(1, #keys)]] = true
        states['walk'] = true

        setPedControlStateShared(ped, states)
    end
end
setTimer(checkPedKeys, CHECK_TIME_PED_KEYS, 0)

function checkPedRotation(msec)
    local pedList = viewCollision:getElementsWithin('ped')
    for _, ped in pairs(pedList) do
        if ped:isOnGround() then
            local rotateTo = ped:getData('rotateTo')
            if rotateTo ~= false then
                if ped:getRotation().z ~= rotateTo and compareWithPrecision(ped:getRotation().z, rotateTo, 30) then
                    ped:setRotation(Vector3(0, 0, rotateTo))
                elseif ped:getRotation().z ~= rotateTo then
                    local rotation = ped:getRotation().z

                    ped:setRotation(Vector3(0, 0, rotation + PED_ROTATION_SPEED * msec / 1000))
                end
            end
        end
    end
end
addEventHandler('onClientPreRender', root, checkPedRotation)

function checkPedState()
    local pedList = pedContainer:toList()
    for _, ped in pairs(pedList) do

        local direction = pedContainer:getData(ped, 'direction')
        local nextNodeId = pedContainer:getData(ped, 'nextNodeId')
        local nextNode = PATH_LIST[nextNodeId]

        if direction ~= nil then
            local distance = (nextNode:getPosition() - ped.position):getLength()
            if distance < MIN_DISTANCE_TO_NODE then
                local nodes = nextNode:getLink(direction)

                if nodes and #nodes ~= 0 then
                    local newNextNodeId = nodes[math.random(1, #nodes)]

                    pedContainer:setData(ped, 'nextNodeId', newNextNodeId)
                end
            end
        end
    end
end
setTimer(checkPedState, CHECK_TIME_PED_STATE, 0)