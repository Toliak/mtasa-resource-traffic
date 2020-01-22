local function sqr(x)
    return x * x
end

local Tree2DClass = {
    _tree = nil,

    insert = function(self, vector2, data)
        local basicTree = Tree()                            -- insert that shit, if key does not exists
        basicTree:insertNode(TreeNode(vector2.y, data))
        local basicNode = TreeNode(vector2.x, basicTree)

        local node = self._tree:getNodeByValueOrInsert(basicNode)
        if node == basicNode then
            return nil                  -- ok, inserted
        end

        local tree = node.data                              -- the same X, insert our data with Y
        tree:insertNode(TreeNode(vector2.y, data))
    end,

    find = function(self, vector2)
        local treeYNode = self._tree:getNodeByValue(vector2.x)
        if treeYNode == nil then
            return nil
        end

        local resultNode = treeYNode.data:getNodeByValue(vector2.y)      -- data is tree
        if resultNode == nil then
            return nil
        end

        return resultNode.data
    end,

    findInRectangle = function(self, leftUpCorner, rightDownCorner)
        local result = {}

        -- list of nodes with trees inside
        local nodeList = self._tree:getNodesInRange(leftUpCorner.x, rightDownCorner.x)

        for _, node in pairs(nodeList) do
            -- every node has correct X only

            local tree = node.data

            local insideResult = tree:getNodesInRange(rightDownCorner.y, leftUpCorner.y)   -- nodes with correct X and Y
            for _, resultNode in ipairs(insideResult) do
                table.insert(result, resultNode.data)           -- save only data
            end
        end

        return result
    end,

    findInCircle = function(self, center, radius)
        local result = {}

        -- list of nodes with trees inside
        local nodeList = self._tree:getNodesInRange(center.x - radius, center.x + radius)

        for _, node in pairs(nodeList) do
            -- every node has correct X only

            local tree = node.data

            local x = node.value
            local yTop = math.sqrt(sqr(radius) - sqr(x - center.x)) + center.y
            local yBottom = -math.sqrt(sqr(radius) - sqr(x - center.x)) + center.y

            local insideResult = tree:getNodesInRange(yBottom, yTop)   -- nodes with correct X and Y
            for _, resultNode in ipairs(insideResult) do
                table.insert(result, resultNode.data)           -- save only data
            end
        end

        return result
    end,
}

function Tree2D()
    local result = setmetatable({}, {
        __index = Tree2DClass,
    })

    result._tree = Tree()

    return result
end