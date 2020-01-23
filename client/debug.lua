-- spawn point
addCommandHandler('sp', function()
    local position = localPlayer.position

    local pathNode = PathNode(position.x, position.y, position.z)
    table.insert(PATH_LIST, pathNode)

    PATH_TREE:insert(position, pathNode)
end)

local function pathNodeToString(pathNode)
    local linksTableString = '{ '
    for k, v in pairs(pathNode) do
        linksTableString = linksTableString .. ('["%s"] = %d, '):format(k, v)
    end
    linksTableString = linksTableString .. '}'

    return ('PathNode(%f, %f, %f, %s)'):format(pathNode.x, pathNode.y, pathNode.z, linksTableString)
end

addCommandHandler('ss', function()
    local string = 'PATH_LIST = {\n'
    for _, pathNode in ipairs(PATH_LIST) do
        string = string .. '    ' .. pathNodeToString(pathNode) .. '\n'
    end
    string = string .. '}'

    return string
end)

local RENDER_RADIUS = 10

addEventHandler('onClientRender', root, function()
    local position = localPlayer.position

    local pathNodes = PATH_TREE:findInSphere(position, RENDER_RADIUS)
    for _, pathNode in pairs(pathNodes) do
        dxDrawLine3D(
                pathNode.x,
                pathNode.y,
                pathNode.z + 0.5,       -- startZ
                pathNode.x,
                pathNode.y,
                pathNode.z - 2,         -- endZ
                0xFF0000AA,             -- color
                4                       -- width
        )
    end

end)