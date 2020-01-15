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

        assert(parentLeft ~= nil)
        assert(parentLeft:getValue() == 'parentLeft')
    end,
    function()
        -- checks tree structure

        local rootNode = testTree()
        local left = rootNode:getLeft():getLeft()

        assert(left ~= nil)
        assert(left:getValue() == 'left')
    end,
    function()
        -- checks getSibling

        local rootNode = testTree()
        local right = rootNode:getLeft():getLeft():getSibling()

        assert(right ~= nil)
        assert(right:getValue() == 'right')
    end,
    function()
        -- checks getGrandParent

        local rootNode = testTree()
        local grandparent = rootNode:getLeft():getLeft():getGrandParent()

        assert(grandparent ~= nil)
        assert(grandparent:getValue() == 'rootNode')
    end,
    function()
        -- checks rotateLeft

        local rootNode = testTreeRotate()
        local parentRight = rootNode:getRight()
        local right = parentRight:getRight()

        rootNode:rotateLeft()

        assert(parentRight:getParent() == nil)
        assert(parentRight:getLeft() == rootNode)
        assert(parentRight:getRight() == right)
    end,
    function()
        -- checks rotateRight

        local rootNode = testTreeRotate()
        local parentLeft = rootNode:getLeft()
        local left = parentLeft:getLeft()

        rootNode:rotateRight()

        assert(parentLeft:getParent() == nil)
        assert(parentLeft:getRight() == rootNode)
        assert(parentLeft:getLeft() == left)
    end,
    function()
        -- Simple insert test

        local tree = Tree()
        tree:insertNode(TreeNode(10))

        assert(tree._rootNode ~= nil)
        assert(tree._rootNode:getValue() == 10)
    end,
    function()
        -- Test insert with rotation

        local tree = Tree()
        tree:insertNode(TreeNode(10))
        tree:insertNode(TreeNode(9))
        tree:insertNode(TreeNode(8))

        assert(tree._rootNode ~= nil)
        assert(tree._rootNode:getValue() == 9)
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
    function()
        -- Test getNodeByValue

        local tree = Tree()

        local one = TreeNode(1)
        local four = TreeNode(4)
        local five = TreeNode(5)

        tree:insertNode(TreeNode(10))
        tree:insertNode(TreeNode(9))
        tree:insertNode(TreeNode(8))
        tree:insertNode(TreeNode(7))
        tree:insertNode(TreeNode(6))
        tree:insertNode(five)
        tree:insertNode(four)
        tree:insertNode(TreeNode(3))
        tree:insertNode(TreeNode(2))
        tree:insertNode(one)

        assert(tree:getNodeByValue(1) == one)
        assert(tree:getNodeByValue(4) == four)
        assert(tree:getNodeByValue(5) == five)
    end,
    function()
        -- Test getNodesInRange

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

        local nodes = tree:getNodesInRange(4, 7)
        assert(#nodes == 4)

        for _, n in pairs(nodes) do
            assert(4 <= n:getValue() and n:getValue() <= 7)
        end
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