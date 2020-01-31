local function sqr(x)
    return x * x
end

local Tree3DClass = {
    _tree = nil,

    insert = function(self, vector3, data)
        local basicTree = Tree2D()                            -- insert that shit, if key does not exists
        basicTree:insert(Vector2(vector3.y, vector3.z), data)
        local basicNode = TreeNode(vector3.x, basicTree)

        local node = self._tree:getNodeByValueOrInsert(basicNode)
        if node == basicNode then
            return nil                  -- ok, inserted
        end

        local tree2d = node.data                              -- the same X, insert our data with Y
        tree2d:insert(Vector2(vector3.y, vector3.z), data)
    end,

    find = function(self, vector3)
        local tree2DNode = self._tree:getNodeByValue(vector3.x)
        if tree2DNode == nil then
            return nil
        end

        return tree2DNode.data:find(Vector2(vector3.y, vector3.z))
    end,

    findInCuboid = function(self, corner, depth)
        local result = {}

        -- list of nodes with trees inside
        local nodeList = self._tree:getNodesInRange(corner.x, corner.x + depth.x)

        for _, node in pairs(nodeList) do
            -- every node has correct X only

            local tree2d = node.data

            local insideResult = tree2d:findInRectangle(
                    Vector2(corner.y, corner.z + depth.z),          -- left up
                    Vector2(corner.y + depth.y, corner.z)           -- right down
            )
            for _, data in ipairs(insideResult) do
                table.insert(result, data)
            end
        end

        return result
    end,

    findInSphere = function(self, center, radius)
        local result = {}

        -- list of nodes with trees inside
        local nodeList = self._tree:getNodesInRange(center.x - radius, center.x + radius)

        for _, node in pairs(nodeList) do
            -- every node has correct X only

            local x = node.value
            local tree2d = node.data

            local insideResult = tree2d:findInCircle(
                    Vector2(center.y, center.z),                            -- center
                    math.sqrt(sqr(radius) - sqr(x - center.x))      -- radius
            )
            for _, data in ipairs(insideResult) do
                table.insert(result, data)
            end
        end

        return result
    end,
}

function Tree3D()
    local result = setmetatable({}, {
        __index = Tree3DClass,
    })

    result._tree = Tree()

    return result
end