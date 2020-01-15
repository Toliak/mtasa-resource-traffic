local function testTree()
    local rootNode = TreeNode()
    local parentLeft = TreeNode()
    local parentRight = TreeNode()
    local left = TreeNode()
    local right = TreeNode()

    rootNode:setLeft(parentLeft)
    rootNode:setRight(parentRight)

    parentLeft:setLeft(left)
    parentLeft:setRight(right)

    rootNode:setValue('rootNode')
    parentLeft:setValue('parentLeft')
    parentRight:setValue('parentRight')
    left:setValue('left')
    right:setValue('right')

    return rootNode
end

local function testTreeRotate()
    local rootNode = TreeNode()
    local parentLeft = TreeNode()
    local parentRight = TreeNode()
    local left = TreeNode()
    local right = TreeNode()
    local subLeft = TreeNode()
    local subRight = TreeNode()

    rootNode:setLeft(parentLeft)
    rootNode:setRight(parentRight)
    parentLeft:setLeft(left)
    parentRight:setRight(right)
    left:setLeft(subLeft)
    right:setRight(subRight)

    rootNode:setValue('rootNode')
    parentLeft:setValue('parentLeft')
    parentRight:setValue('parentRight')
    left:setValue('left')
    right:setValue('right')
    subLeft:setValue('subLeft')
    subRight:setValue('subRight')

    return rootNode
end

TESTS = {
    function()
        -- checks rootNode value

        local rootNode = testTree()

        return rootNode:getValue() == 'rootNode'
    end,
    function()
        -- checks tree structure

        local rootNode = testTree()
        local parentLeft = rootNode:getLeft()

        if parentLeft == nil then
            iprint('parentLeft == nil')
            return false
        end
        if parentLeft:getValue() ~= 'parentLeft' then
            iprint("parentLeft:getValue() ~= 'parentLeft'")
            return false
        end
    end,
    function()
        -- checks tree structure

        local rootNode = testTree()
        local left = rootNode:getLeft():getLeft()

        if left == nil then
            iprint('left == nil')
            return false
        end
        if left:getValue() ~= 'left' then
            iprint("left:getValue() ~= 'left'")
            return false
        end
    end,
    function()
        -- checks getSibling

        local rootNode = testTree()
        local right = rootNode:getLeft():getLeft():getSibling()

        if right == nil then
            iprint('right == nil')
            return false
        end
        if right:getValue() ~= 'right' then
            iprint("right:getValue() ~= 'right'")
            return false
        end
    end,
    function()
        -- checks getGrandParent

        local rootNode = testTree()
        local grandparent = rootNode:getLeft():getLeft():getGrandParent()

        if grandparent == nil then
            iprint('grandparent == nil')
            return false
        end
        if grandparent:getValue() ~= 'rootNode' then
            iprint("grandparent:getValue() ~= 'rootNode'")
            return false
        end
    end,
    function()
        -- checks rotateLeft

        local rootNode = testTreeRotate()
        local parentRight = rootNode:getRight()
        local right = parentRight:getRight()

        rootNode:rotateLeft()

        if parentRight:getParent() ~= nil then
            iprint("parentRight:getParent() ~= nil")
            return false
        end
        if parentRight:getLeft() ~= rootNode then
            iprint("parentRight:getLeft() ~= rootNode")
            return false
        end
        if parentRight:getRight() ~= right then
            iprint("parentRight:getRight() ~= right")
            return false
        end
    end,
    function()
        -- checks rotateRight

        local rootNode = testTreeRotate()
        local parentLeft = rootNode:getLeft()
        local left = parentLeft:getLeft()

        rootNode:rotateRight()

        if parentLeft:getParent() ~= nil then
            iprint("parentLeft:getParent() ~= nil")
            return false
        end
        if parentLeft:getRight() ~= rootNode then
            iprint("parentLeft:getRight() ~= rootNode")
            return false
        end
        if parentLeft:getLeft() ~= left then
            iprint("parentLeft:getLeft() ~= left")
            return false
        end
    end,
    function()
        -- Simple insert test

        local tree = Tree()
        tree:insertNode(TreeNode(10))

        if tree._rootNode == nil then
            iprint("tree._rootNode == nil")
            return false
        end
        if tree._rootNode:getValue() ~= 10 then
            iprint("tree._rootNode:getValue() ~= 10")
            return false
        end
    end,
    function()
        -- Test insert with rotation

        local tree = Tree()
        tree:insertNode(TreeNode(10))
        tree:insertNode(TreeNode(9))
        tree:insertNode(TreeNode(8))

        if tree._rootNode == nil then
            iprint("tree._rootNode == nil")
            return false
        end
        if tree._rootNode:getValue() ~= 9 then
            iprint("tree._rootNode:getValue() ~= 9")
            return false
        end
    end,
    function()
        -- Test insert with 10 numbers

        local tree = Tree()
        tree:insertNode(TreeNode(10))
        tree:insertNode(TreeNode(9))
        tree:insertNode(TreeNode(8))
        tree:insertNode(TreeNode(7))
        tree:insertNode(TreeNode(6))
        tree:insertNode(TreeNode(5))
        tree:insertNode(TreeNode(4))
        tree:insertNode(TreeNode(3))
        tree:insertNode(TreeNode(2))
        tree:insertNode(TreeNode(1))

        assert(tree._rootNode ~= nil)
        assert(tree._rootNode:getValue() == 7)
        assert(tree._rootNode:getColor() == TreeNodeColor.BLACK)

        assert(tree._rootNode:getRight() ~= nil)
        assert(tree._rootNode:getRight():getValue() == 9)
        assert(tree._rootNode:getRight():getColor() == TreeNodeColor.BLACK)

        assert(tree._rootNode:getLeft() ~= nil)
        assert(tree._rootNode:getLeft():getValue() == 5)
        assert(tree._rootNode:getLeft():getColor() == TreeNodeColor.BLACK)

        assert(tree._rootNode:getLeft():getLeft() ~= nil)
        assert(tree._rootNode:getLeft():getLeft():getValue() == 3)
        assert(tree._rootNode:getLeft():getLeft():getColor() == TreeNodeColor.RED)
    end,
    function()
        -- Test insert with 10 numbers decr

        local tree = Tree()
        tree:insertNode(TreeNode(1))
        tree:insertNode(TreeNode(2))
        tree:insertNode(TreeNode(3))
        tree:insertNode(TreeNode(4))
        tree:insertNode(TreeNode(5))
        tree:insertNode(TreeNode(6))
        tree:insertNode(TreeNode(7))
        tree:insertNode(TreeNode(8))
        tree:insertNode(TreeNode(9))
        tree:insertNode(TreeNode(10))

        assert(tree._rootNode ~= nil)
        assert(tree._rootNode:getValue() == 4)
        assert(tree._rootNode:getColor() == TreeNodeColor.BLACK)

        assert(tree._rootNode:getLeft() ~= nil)
        assert(tree._rootNode:getLeft():getValue() == 2)
        assert(tree._rootNode:getLeft():getColor() == TreeNodeColor.BLACK)

        assert(tree._rootNode:getRight() ~= nil)
        assert(tree._rootNode:getRight():getValue() == 6)
        assert(tree._rootNode:getRight():getColor() == TreeNodeColor.BLACK)

        assert(tree._rootNode:getRight():getRight() ~= nil)
        assert(tree._rootNode:getRight():getRight():getValue() == 8)
        assert(tree._rootNode:getRight():getRight():getColor() == TreeNodeColor.RED)
    end,
}

addEventHandler('onResourceStart', resourceRoot, function()
    local failedTests = 0

    for i, testFunction in ipairs(TESTS) do
        local returned, error = pcall(testFunction)

        if returned == false then
            failedTests = failedTests + 1
            iprint('failed test ', i)
            iprint(error)
        end

    end

    iprint('====[TRAFFIC TESTS]====')
    iprint('Failed ', failedTests, 'from', #TESTS)
end)