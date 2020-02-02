-- spawn point

local debugMode = false
local currentNode = nil

-- set current node
addCommandHandler('scn', function(cmd, id)
    if not debugMode then
        return false 
    end

    id = tonumber(id)
    currentNode = PATH_LIST[id]
end)

-- spawn helper node
addCommandHandler('sph', function()
    if not debugMode then
        return false 
    end

    assert(currentNode ~= nil)

    local position = localPlayer.position

    local helperNode = PathNode(position.x, position.y, position.z)
    helperNode.id = #PATH_HELPER_LIST + 1
    currentNode:addLink('helper', #PATH_HELPER_LIST + 1)

    table.insert(PATH_HELPER_LIST, helperNode)
end)

addCommandHandler('dbg', function()
    debugMode = not debugMode
end)

-- spawn helper node in left and right side
addCommandHandler('sphd', function(cmd, smth)
    if not debugMode then
        return false 
    end

    assert(currentNode ~= nil)

    local position = localPlayer.position

    local LENGTH = 0.7
    local rotation = localPlayer.rotation.z
    local angle = math.rad(rotation + 90)

    local deltaList = {
        Vector2(LENGTH * math.cos(angle + math.pi/2), LENGTH * math.sin(angle + math.pi/2)),
        Vector2(LENGTH * 2 * math.cos(angle + math.pi/2), LENGTH* 2 * math.sin(angle + math.pi/2)),
        Vector2(LENGTH * math.cos(angle - math.pi/2), LENGTH * math.sin(angle - math.pi/2)),
        Vector2(LENGTH * 2 * math.cos(angle - math.pi/2), LENGTH* 2 * math.sin(angle - math.pi/2)),
    }

    if smth then
        LENGTH = 0.9
        deltaList = {
            Vector2(LENGTH * math.cos(angle + math.pi/2), LENGTH * math.sin(angle + math.pi/2)),
            Vector2(LENGTH * math.cos(angle - math.pi/2), LENGTH * math.sin(angle - math.pi/2)),
        }
    end

    for _, delta in pairs(deltaList) do 
        local helperNode = PathNode(
            position.x + delta.x, 
            position.y + delta.y, 
            position.z
        )
        helperNode.id = #PATH_HELPER_LIST + 1
        currentNode:addLink('helper', #PATH_HELPER_LIST + 1)

        table.insert(PATH_HELPER_LIST, helperNode)
    end
end)

-- spawn node
addCommandHandler('spn', function()
    if not debugMode then
        return false 
    end

    local position = localPlayer.position

    local pathNode = PathNode(position.x, position.y, position.z)
    pathNode.id = #PATH_LIST + 1

    table.insert(PATH_LIST, pathNode)
    PATH_TREE:insert(position, pathNode)

    currentNode = pathNode
end)

-- spawn node with links
addCommandHandler('spn2', function()
    if not debugMode then
        return false 
    end

    assert(currentNode ~= nil)

    local position = localPlayer.position

    local pathNode = PathNode(position.x, position.y, position.z)
    pathNode.id = #PATH_LIST + 1
    pathNode:addLink('backward', currentNode.id)
    currentNode:addLink('forward', pathNode.id)

    table.insert(PATH_LIST, pathNode)
    PATH_TREE:insert(position, pathNode)

    currentNode = pathNode
end)

addCommandHandler('dbgmd', function()
    setDevelopmentMode(true, true)
end)

function listToString(list)
    local result = '{'
    for _, value in ipairs(list) do
        result = result .. value .. ', '
    end

    return result .. '}'
end

function pathNodeToString(pathNode)
    local linksTableString = '{ '
    for k, v in pairs(pathNode._links) do
        local valueStr = ''
        if type(v) == 'table' then
            valueStr = listToString(v)
        else
            valueStr = v
        end

        linksTableString = linksTableString .. ('["%s"] = %s, '):format(k, valueStr)
    end
    linksTableString = linksTableString .. '}'

    return ('PathNode(%f, %f, %f, %s)'):format(pathNode.x, pathNode.y, pathNode.z, linksTableString)
end

-- save all

addCommandHandler('ss', function()
    if not debugMode then
        return false 
    end

    local string = 'PATH_LIST = {\n'
    for _, pathNode in ipairs(PATH_LIST) do
        string = string .. '    ' .. pathNodeToString(pathNode) .. ',\n'
    end
    string = string .. '}\n'

    local file = File(('path_list_%d.lua'):format(getTickCount()))
    file:write(string)
    file:close()

    string = 'PATH_HELPER_LIST = {\n'
    for _, pathNode in ipairs(PATH_HELPER_LIST) do
        string = string .. '    ' .. pathNodeToString(pathNode) .. ',\n'
    end
    string = string .. '}'

    file = File(('path_helper_list_%d.lua'):format(getTickCount()))
    file:write(string)
    file:close()

    outputConsole('done')
end)

local RENDER_RADIUS = 100

addEventHandler('onClientRender', root, function()
    if not debugMode then
        return false 
    end

    local checkVariables = (function()
        return SPAWN_RED_RADIUS ~= nil
                and SPAWN_GREEN_RADIUS ~= nil
    end)()
    assert(checkVariables, 'checkVariables fail')

    local position = localPlayer.position

    local pathNodes = PATH_TREE:findInSphere(position, RENDER_RADIUS)
    for _, pathNode in pairs(pathNodes) do
        local distance = (pathNode:getPosition() - position):getLength()

        local color
        if SPAWN_RED_RADIUS >= distance then
            color = 0xAAB74649
        elseif SPAWN_RED_RADIUS < distance and distance <= SPAWN_GREEN_RADIUS then
            color = 0xAA539D3C
        else
            color = 0xAAD9D9D9
        end
        if currentNode == pathNode then
            color = 0xAA3A3276      -- select currentNode
        end

        dxDrawLine3D(
                pathNode.x,
                pathNode.y,
                pathNode.z + 0.5, -- startZ
                pathNode.x,
                pathNode.y,
                pathNode.z - 2, -- endZ
                color,
                4                        -- width
        )

        dxDrawTextOnPosition(
            pathNode.x,
            pathNode.y,
            pathNode.z + 0.6, -- startZ
            ('ID: %d'):format(pathNode.id),
            0
        )

        local forwardLinks = pathNode:getLink('forward')
        if forwardLinks ~= nil then
            for _, id in pairs(forwardLinks) do
                local endNode = PATH_LIST[id]

                dxDrawLine3D(
                        pathNode.x,
                        pathNode.y,
                        pathNode.z, -- startZ
                        endNode.x,
                        endNode.y,
                        endNode.z, -- endZ
                        0xAA343C76, -- color
                        2                        -- width
                )
            end
        end
        local backwardLinks = pathNode:getLink('backward')
        if backwardLinks ~= nil then
            for _, id in pairs(backwardLinks) do
                local endNode = PATH_LIST[id]

                dxDrawLine3D(
                        pathNode.x,
                        pathNode.y,
                        pathNode.z - 0.1, -- startZ
                        endNode.x,
                        endNode.y,
                        endNode.z - 0.1, -- endZ
                        0xAA4F2F74, -- color
                        2                        -- width
                )
            end
        end
        local helpersLinks = pathNode:getLink('helper')
        if helpersLinks ~= nil then
            for _, id in pairs(helpersLinks) do
                local endNode = PATH_HELPER_LIST[id]

                dxDrawLine3D(
                        pathNode.x,
                        pathNode.y,
                        pathNode.z - 0.1, -- startZ
                        endNode.x,
                        endNode.y,
                        endNode.z - 0.1, -- endZ
                        0xAAAA7339, -- color
                        2                        -- width
                )
                dxDrawLine3D(
                        endNode.x,
                        endNode.y,
                        endNode.z + 0.5, -- startZ
                        endNode.x,
                        endNode.y,
                        endNode.z - 2, -- endZ
                        0xAA804C15,
                        4                        -- width
                )
            end
        end
    end
end)

addEventHandler('onClientRender', root, function()
    if not debugMode then
        return false 
    end

    if currentNode then
        
        local distance = (localPlayer.position - currentNode:getPosition()):getLength()
        local color = '#FFFFFF'
        if distance > 2.5 then
            color = '#FF0000'
        elseif distance > 1.8 then
            color = '#FFFF00'
        elseif distance > 1 then
            color = '#00FF00'
        end
        local text = '#FFFFFF ID: %d\nDistance: %s%f'
        text = text:format(currentNode.id, color, distance)

        dxDrawText(
            text,
            10,          --leftX
            10,  -- topY
            10,  -- rightX
            10,  -- bottomY
            0xFFFFFFFF,
            1,  --scaleXY
            1,  --scaleY
            'bankgothic',
            'left',
            'top',
            false,      -- clip
            false,       -- wordBreak
            false,      -- postGUI
            true       -- colorCoded
        )
    end
end)

-- request all debug info about peds from server

local DEBUG_SYNC_TIME = 250

local function requestInformationFromServer()
    if not debugMode then
        return false 
    end

    local peds = viewCollision:getElementsWithin('ped')
    triggerServerEvent('onPlayerDebugRequest', resourceRoot, peds)
end

setTimer(requestInformationFromServer, DEBUG_SYNC_TIME, 0)

local pedDebugInfo = {}

addSharedEventHandler('onClientDebugRequest', resourceRoot, function(info)
    pedDebugInfo = info
end)

local function getClientDebugInfoString(ped)
    local distance = (ped:getPosition() - localPlayer:getPosition()):getLength()
    local zone = (distance <= SPAWN_RED_RADIUS) and '#ff0000red' or '#00ff00green'
    local rotation = ped:getRotation().z

    local message = ''
    message = message .. ('#FFFFFFzone: %s\n'):format(zone)
    message = message .. ('#FFFFFFrotation: %s\n'):format(rotation)
    message = message .. ('#FFFFFFlogic: %s\n'):format(ped:getData('logic') or 'NIL')
    message = message .. ('#FFFFFFspawnRotation: %s\n'):format(ped:getData('spawnRotation') or 'NIL')
    message = message .. ('#FFFFFFHP: %s\n'):format(ped:getHealth())
    message = message .. ('#FFFFFFgoesAround: %s\n'):format(ped:getData('goesAround') or 'FALSE')
    message = message .. ('#FFFFFFgoesAroundTime: %s\n'):format(ped:getData('goesAroundTime') or 'FALSE')
    message = message .. ('#FFFFFFwaiting: %s\n'):format(ped:getData('waiting') or 'NIL')

    return message
end

addEventHandler('onClientRender', root, function()
    if not debugMode then
        return false
    end

    local Z_OFFSET = 0.7

    local peds = viewCollision:getElementsWithin('ped')
    for _, ped in pairs(peds) do
        local message = 'No server info\n'

        local data = pedDebugInfo[ped]
        if data ~= nil then
            message = ''
            for key, value in pairs(data) do
                message = message .. ('#FFFFFF%s: %s\n'):format(key, value)
            end
        end

        local position = ped.position
        dxDrawTextOnPosition(
                position.x,
                position.y,
                position.z + Z_OFFSET, -- startZ,
                message .. getClientDebugInfoString(ped),
                0
        )
        
    end
end)

addEventHandler('onClientRender', root, function()
    if not debugMode then
        return
    end

    localPlayer:setHealth(100)

    local peds = pedContainer._table
    for ped, _ in pairs(peds) do
        local bonePosition = ped:getBonePosition(8)
        
        local logic = getPedLogic(ped, pedContainer)
        local helperNode = logic:getNextHelperNode() or logic:getNextNode()
        if helperNode then
            dxDrawLine3D(
                    bonePosition,
                    helperNode:getPosition(),
                    0x77801D15,
                    4                        -- width
            )
        else 
            dxDrawLine3D(
                    bonePosition,
                    bonePosition + Vector3(0,0,1),
                    0x77801D15,
                    4                        -- width
            )
        end


        -- target
        if customData[ped] then
            local targetPivot = customData[ped]['targetPivot']

            if targetPivot then
                dxDrawLine3D(
                        bonePosition,
                        targetPivot,
                        0x55801D15,
                        2                        -- width
                )
            end
        end
    end
end)

addEventHandler('onClientRender', root, function()
    if not debugMode then
        return
    end

    local peds = viewCollision:getElementsWithin('ped')
    for _, ped in pairs(peds) do
        local x, y, z = getPedTargetStart(ped) -- Gets the Point to start From
        local sx, sy, sz = getPedTargetEnd(ped) -- Gets the Point where the Target Ends

        if x==x and y==y and z==z and sx==sx and sy==sy and sz==sz then
            dxDrawLine3D(
                    x,
                    y, 
                    z, 
                    sx, 
                    sy, 
                    sz,
                    0x88236467
                ) -- Draws the Line
        end
    end
end)


-- fps

local fps = 0
addEventHandler('onClientPreRender', root, function(msec)
    fps = math.floor(1000 / msec)
end)

addEventHandler('onClientRender', root, function()
    local screenSize = Vector2(guiGetScreenSize())
    
    dxDrawText(
        fps,
        screenSize.x - 15,
        0
    )
end)

-- welcome message

addEventHandler('onClientResourceStart', resourceRoot, function()
    outputChatBox('======================================')
    outputChatBox('Welcome!')
    outputChatBox('Ped traffic system works in Angel Pine')
    outputChatBox('======================================')
end)