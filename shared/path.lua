PATH_TREE = Tree3D()

for _, pathNode in pairs(PATH_LIST) do
    PATH_TREE:insert(pathNode:getPosition(), pathNode)
end