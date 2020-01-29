-- spawn point
addCommandHandler('spn', function()
    local position = localPlayer.position

    local pathNode = PathNode(position.x, position.y, position.z)
    table.insert(PATH_LIST, pathNode)

    PATH_TREE:insert(position, pathNode)
end)

addCommandHandler('dbg', function (cmd, id)
    id = tonumber(id)

    updatePedRotation(localPlayer, PATH_LIST[id])
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

addCommandHandler('ss', function()
    local string = 'PATH_LIST = {\n'
    for _, pathNode in ipairs(PATH_LIST) do
        string = string .. '    ' .. pathNodeToString(pathNode) .. ',\n'
    end
    string = string .. '}'

    outputConsole(string)
end)

local RENDER_RADIUS = 100

addEventHandler('onClientRender', root, function()
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
            color = 0xFFB74649
        elseif SPAWN_RED_RADIUS < distance and distance <= SPAWN_GREEN_RADIUS then
            color = 0xFF539D3C
        else
            color = 0xFFD9D9D9
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
                        0xFF343C76, -- color
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
                        0xFF4F2F74, -- color
                        2                        -- width
                )
            end
        end
    end
end)

-- request all debug info about peds from server

local DEBUG_SYNC_TIME = 250

local function requestInformationFromServer()
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
    local rotateTo = ped:getData('rotateTo') or 'NIL'
    local rotation = ped:getRotation().z

    local message = ''
    message = message .. ('#FFFFFFzone: %s\n'):format(zone)
    message = message .. ('#FFFFFFrotateTo: %s\n'):format(rotateTo)
    message = message .. ('#FFFFFFrotation: %s\n'):format(rotation)

    return message
end

addEventHandler('onClientRender', root, function()
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

-- Lines of sight
addEventHandler('onClientRender', root, function()

end)