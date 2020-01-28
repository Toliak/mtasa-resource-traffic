PATH_TREE = Tree3D()

for id, pathNode in pairs(PATH_LIST) do
    pathNode.id = id

    PATH_TREE:insert(pathNode:getPosition(), pathNode)
end