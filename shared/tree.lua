--- https://en.wikipedia.org/wiki/Red%E2%80%93black_tree

TreeNodeColor = {
    RED = 1,
    BLACK = 0,
}

local TreeNodeClass = {
    left = nil,
    right = nil,
    parent = nil,
    color = nil, -- 0 BLACK or 1 RED
    value = nil, -- sort by
    data = nil,

    _insertRecurse = function(self, rootNode)
        if rootNode ~= nil then
            if self.value < rootNode.value then
                if rootNode.left ~= nil then
                    return self:_insertRecurse(rootNode.left)
                end

                rootNode.left = self
            else
                if rootNode.right ~= nil then
                    return self:_insertRecurse(rootNode.right)
                end

                rootNode.right = self
            end
        end

        self.parent = rootNode
        self.color = TreeNodeColor.RED
    end,

    _insertRepairTree = function(self)
        if self.parent == nil then
            -- insertCase1
            self.color = TreeNodeColor.BLACK

        elseif self.parent.color == TreeNodeColor.BLACK then
            -- insertCase2
            return -- tree valid

        elseif self:getUncle() ~= nil and self:getUncle().color == TreeNodeColor.RED then
            -- insertCase3
            self.parent.color = TreeNodeColor.BLACK
            self:getUncle().color = TreeNodeColor.BLACK

            local grandparent = self:getGrandParent()
            grandparent.color = TreeNodeColor.RED

            grandparent:_insertRepairTree()

        else
            -- insertCase4
            local parent = self.parent
            local grandparent = self:getGrandParent()

            local next = nil
            if self == parent.right and parent == grandparent.left then
                parent:rotateLeft()
                next = self.left
            elseif self == parent.left and parent == grandparent.right then
                parent:rotateRight()
                next = self.right
            end

            -- insertCase4 step 2
            parent = next.parent
            grandparent = next:getGrandParent()

            if next == parent.left then
                grandparent:rotateRight()
            else
                grandparent:rotateLeft()
            end

            parent.color = TreeNodeColor.BLACK
            grandparent.color = TreeNodeColor.RED
        end
    end,

    setLeft = function(self, left)
        self.left = left

        if left ~= nil then
            left.parent = self
        end
    end,

    setRight = function(self, right)
        self.right = right

        if right ~= nil then
            right.parent = self
        end
    end,

    setColor = function(self, color)
        self.color = color
    end,

    setValue = function(self, value)
        self.value = value
    end,

    getColor = function(self)
        return self.color
    end,

    getValue = function(self)
        return self.value
    end,

    getLeft = function(self)
        return self.left;
    end,

    getRight = function(self)
        return self.right;
    end,

    getParent = function(self)
        return self.parent
    end,

    getGrandParent = function(self)
        local parent = self.parent
        if parent == nil then
            return nil
        end

        return parent.parent
    end,

    getSibling = function(self)
        local parent = self.parent
        if parent == nil then
            return nil
        end

        if parent.left == self then
            return parent.right
        end
        return parent.left
    end,

    getUncle = function(self)
        local parent = self.parent
        if parent == nil then
            return nil
        end

        return parent:getSibling()
    end,

    rotateLeft = function(self)
        local newParent = self.right
        local parent = self.parent
        assert(newParent ~= nil)

        self.right = newParent.left
        newParent.left = self
        self.parent = newParent

        if self.right ~= nil then
            self.right.parent = self
        end

        if parent ~= nil then
            if self == parent.left then
                parent.left = newParent
            elseif self == parent.right then
                parent.right = newParent
            end
        end

        newParent.parent = parent
    end,

    rotateRight = function(self)
        local newParent = self.left
        local parent = self.parent
        assert(newParent ~= nil)

        self.left = newParent.right
        newParent.right = self
        self.parent = newParent

        if self.left ~= nil then
            self.left.parent = self
        end

        if parent ~= nil then
            if self == parent.left then
                parent.left = newParent
            elseif self == parent.right then
                parent.right = newParent
            end
        end

        newParent.parent = parent
    end,
}

function TreeNode()
    return setmetatable({}, {
        __index = TreeNodeClass,
    })
end

local TreeClass = {
    _rootNode = nil,

    insertNode = function(self, node)
        node:_insertRecurse(self._rootNode)

        node:_insertRepairTree()

        self._rootNode = node
        while self._rootNode.parent ~= nil do
            self._rootNode = self._rootNode.parent
        end
    end,
}

function Tree()
    return setmetatable({}, {
        __index = TreeClass,
    })
end