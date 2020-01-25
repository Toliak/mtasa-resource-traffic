-- spawn point
addCommandHandler('spn', function()
    local position = localPlayer.position

    local pathNode = PathNode(position.x, position.y, position.z)
    table.insert(PATH_LIST, pathNode)

    PATH_TREE:insert(position, pathNode)
end)

function pathNodeToString(pathNode)
    local linksTableString = '{ '
    for k, v in pairs(pathNode._links) do
        linksTableString = linksTableString .. ('["%s"] = %d, '):format(k, v)
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
    end
end)

addEventHandler('onClientRender', root, function()
    local HEIGTH = 0.3
    local Z_OFFSET = 1.5
    for ped, _ in pairs(pedContainer._table) do 
        local position = ped.position
        dxDrawLine3D(
            position.x,
            position.y,
            position.z + Z_OFFSET, -- startZ
            position.x,
            position.y,
            position.z + Z_OFFSET + HEIGTH, -- endZ
                0xFFFFFFFF,
                8                        -- width
        )
    end
end)