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

FIXTURES = {
    Ped(0, 0, 0, 0), -- 1
    Ped(0, 0, 0, 0), -- 2
    Ped(0, 0, 0, 0), -- 3
    Ped(0, 0, 0, 0), -- 4
    Ped(0, 0, 0, 0), -- 5
}

TESTS = {
    -- TreeNode tests
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

    -- Tree tests
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
        -- Test getNodeByValue (not existing)

        local tree = Tree()

        tree:insertNode(TreeNode(10))
        tree:insertNode(TreeNode(9))
        tree:insertNode(TreeNode(8))
        tree:insertNode(TreeNode(7))
        tree:insertNode(TreeNode(6))

        assert(tree:getNodeByValue(1) == nil)
        assert(tree:getNodeByValue(4) == nil)
        assert(tree:getNodeByValue(5) == nil)
    end,
    function()
        -- Test getNodeByValue (not existing, empty tree)

        local tree = Tree()

        assert(tree:getNodeByValue(1) == nil)
        assert(tree:getNodeByValue(4) == nil)
        assert(tree:getNodeByValue(5) == nil)
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
    function()
        -- Test getNodeByValueOrInsert (existing)

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

        local node = tree:getNodeByValue(4)
        local resultNode = tree:getNodeByValueOrInsert(node)

        assert(node == resultNode)
    end,
    function()
        -- Test getNodeByValueOrInsert (not existing)

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

        local node = TreeNode(11)
        local resultNode = tree:getNodeByValueOrInsert(node)

        assert(node == resultNode)
    end,
    function()
        -- Test getNodeByValueOrInsert (not existing root)

        local tree = Tree()

        local node = TreeNode(2)
        local resultNode = tree:getNodeByValueOrInsert(node)

        assert(node == resultNode)
    end,

    -- Tree2D tests
    function()
        -- Test insert simple

        local tree2d = Tree2D()
        tree2d:insert(Vector2(2, 5), 'correct')

        assert(tree2d._tree ~= nil)
        assert(tree2d._tree._rootNode ~= nil)
        assert(tree2d._tree._rootNode.value == 2)       -- contains x

        local treeY = tree2d._tree._rootNode.data
        assert(treeY ~= nil)
        assert(treeY._rootNode ~= nil)
        assert(treeY._rootNode.value == 5)       -- contains y

        assert(treeY._rootNode.data == 'correct')
    end,
    function()
        -- Test insert and find

        local tree2d = Tree2D()
        tree2d:insert(Vector2(2, 5), 'correct')

        assert(tree2d:find(Vector2(2, 5)) == 'correct')
    end,
    function()
        -- Test insert and bad find

        local tree2d = Tree2D()
        tree2d:insert(Vector2(2, 5), 'correct')

        assert(tree2d:find(Vector2(3, 5)) == nil)
        assert(tree2d:find(Vector2(2, 4)) == nil)
    end,
    function()
        -- Test findInRectangle
        -- https://www.desmos.com/calculator/kncl44emvc

        local tree2d = Tree2D()
        tree2d:insert(Vector2(1, 1), 'incorrect')
        tree2d:insert(Vector2(-2, 6), 'correct')
        tree2d:insert(Vector2(0, 4), 'correct')
        tree2d:insert(Vector2(-5, 2), 'incorrect')
        tree2d:insert(Vector2(-1, 8), 'incorrect')

        local list = tree2d:findInRectangle(Vector2(-3, 6), Vector2(1, 2))
        assert(#list == 2)
        assert(list[1] == 'correct')
        assert(list[2] == 'correct')
    end,
    function()
        -- Test findInCircle
        -- https://www.desmos.com/calculator/fczkgvok5u

        local tree2d = Tree2D()
        tree2d:insert(Vector2(0, 0), 'correct')
        tree2d:insert(Vector2(1, 0), 'incorrect')
        tree2d:insert(Vector2(0, 2), 'correct')
        tree2d:insert(Vector2(0, 3), 'incorrect')
        tree2d:insert(Vector2(-1, -1), 'correct')
        tree2d:insert(Vector2(-1, 4), 'incorrect')
        tree2d:insert(Vector2(-3, 1), 'correct')
        tree2d:insert(Vector2(-3, 0), 'incorrect')
        tree2d:insert(Vector2(-2, 3), 'incorrect')

        local list = tree2d:findInCircle(Vector2(-1, 1), 2)
        assert(#list == 4)
        assert(list[1] == 'correct')
        assert(list[2] == 'correct')
        assert(list[3] == 'correct')
        assert(list[4] == 'correct')
    end,

    -- Tree3D tests
    function()
        -- Test insert simple

        local tree3d = Tree3D()
        tree3d:insert(Vector3(2, 5, -1), 'correct')

        assert(tree3d._tree ~= nil)
        assert(tree3d._tree._rootNode ~= nil)
        assert(tree3d._tree._rootNode.value == 2)       -- contains x

        local treeYZ = tree3d._tree._rootNode.data
        assert(treeYZ ~= nil)
        assert(treeYZ._tree ~= nil)
        assert(treeYZ._tree._rootNode ~= nil)
        assert(treeYZ._tree._rootNode.value == 5)       -- contains y

        local treeZ = treeYZ._tree._rootNode.data
        assert(treeZ ~= nil)
        assert(treeZ._rootNode ~= nil)
        assert(treeZ._rootNode.value == -1)       -- contains z
    end,
    function()
        -- Test insert and find

        local tree3d = Tree3D()
        tree3d:insert(Vector3(2, 5, -1), 'correct')

        assert(tree3d:find(Vector3(2, 5, -1)) == 'correct')
    end,
    function()
        -- Test insert (same X and Y)

        local tree3d = Tree3D()
        tree3d:insert(Vector3(2, 5, -1), 'correct')
        tree3d:insert(Vector3(2, 5, 5), 'correct')
        tree3d:insert(Vector3(2, 6, 2), 'correct')

        assert(tree3d:find(Vector3(2, 5, -1)) == 'correct')
        assert(tree3d:find(Vector3(2, 5, 5)) == 'correct')
        assert(tree3d:find(Vector3(2, 6, 2)) == 'correct')
    end,
    function()
        -- Test insert and bad find

        local tree3d = Tree3D()
        tree3d:insert(Vector3(2, 5, -1), 'correct')

        assert(tree3d:find(Vector3(2, 5, 9)) == nil)
        assert(tree3d:find(Vector3(2, 6, -1)) == nil)
        assert(tree3d:find(Vector3(3, 5, -1)) == nil)
    end,
    function()
        -- Test findInCuboid
        -- https://www.geogebra.org/3d/rxjsvjur

        local tree3d = Tree3D()
        tree3d:insert(Vector3(1, 4, 8), 'incorrect')
        tree3d:insert(Vector3(7, 1, 3), 'correct')
        tree3d:insert(Vector3(1, 0, 2), 'correct')
        tree3d:insert(Vector3(10, 6, 2), 'incorrect')

        local list = tree3d:findInCuboid(Vector3(-1, -1, 1), Vector3(10, 8, 4))
        assert(#list == 2)
        assert(list[1] == 'correct')
        assert(list[2] == 'correct')
    end,
    function()
        -- Test findInSphere
        -- https://www.geogebra.org/3d/tdzpdhgd

        local tree3d = Tree3D()
        tree3d:insert(Vector3(-5, -3, 0), 'incorrect')
        tree3d:insert(Vector3(-4, 0, 0), 'incorrect')
        tree3d:insert(Vector3(-9, 2, 0), 'incorrect')
        tree3d:insert(Vector3(-6, 1, -2), 'incorrect')
        tree3d:insert(Vector3(-6, 1, -1), 'correct')
        tree3d:insert(Vector3(-6, 1, 1), 'correct')
        tree3d:insert(Vector3(-9, 0, 1), 'incorrect')
        tree3d:insert(Vector3(-9, 0, 0), 'correct')

        local list = tree3d:findInSphere(Vector3(-7, 0, 0), 2)
        assert(#list == 3)
        assert(list[1] == 'correct')
        assert(list[2] == 'correct')
        assert(list[3] == 'correct')
    end,


    -- PathNode tests
    function()
        -- Test constructor

        local pathNode = PathNode(0, 0, 0)
        assert(pathNode:getPosition().x == 0)
        assert(pathNode:getPosition().y == 0)
        assert(pathNode:getPosition().z == 0)
    end,
    function()
        -- Test getPosition, setPosition

        local pathNode = PathNode(0, 0, 0)
        pathNode:setPosition(3, 2, 1)

        assert(pathNode:getPosition().x == 3)
        assert(pathNode:getPosition().y == 2)
        assert(pathNode:getPosition().z == 1)
    end,

    -- PedContainer tests
    function()
        -- Test append, getLength

        local container = PedContainer()

        container:append(FIXTURES[1], FIXTURES[1])
        assert(container:getLength() == 1)

        container:append(FIXTURES[1], FIXTURES[2])
        assert(container:getLength() == 2)
    end,
    function()
        -- Test createPed

        local container = PedContainer()

        container:createPed(FIXTURES[1], 0, PathNode(5, 6, 7))
        assert(container:getLength() == 1)
    end,
    function()
        -- Test destroy

        local ped = Ped(0, 0, 0, 0)
        local container = PedContainer()

        container:append(FIXTURES[1], ped)
        container:destroy(FIXTURES[1], ped)

        assert(container:getLength() == 0)
        assert(not isElement(ped))
    end,
    function()
        -- Test changePedController

        local container = PedContainer()

        container:append(FIXTURES[1], FIXTURES[1])
        container:changePedController(
                FIXTURES[1], -- old controller
                FIXTURES[1], -- ped
                FIXTURES[2]  -- new controller
        )
        assert(container._table[FIXTURES[1]][FIXTURES[1]] == nil)
        assert(container._table[FIXTURES[2]][FIXTURES[1]] ~= nil)
    end,
    function()
        -- Test getLength

        local container = PedContainer()
        assert(container:getLength() == 0)
        assert(container:getLength('string') == 0)

        container:append(FIXTURES[1], FIXTURES[1])
        assert(container:getLength() == 1)
        assert(container:getLength(FIXTURES[1]) == 1)
        assert(container:getLength('string') == 0)
    end,
    function()
        -- Test setData, getData

        local ped = Ped(0, 0, 0, 0)
        local container = PedContainer()

        container:append(FIXTURES[1], ped)
        container:setData(ped, 'key', 'value')
        assert(container:getData(ped, 'key') == 'value')

        container:destroy(FIXTURES[1], ped)
        assert(container._data[ped] == nil)
    end,
    function()
        -- Test getAllData

        local container = PedContainer()

        container:append(FIXTURES[1], FIXTURES[1])
        container:setData(FIXTURES[1], 'key', 'value')
        container:setData(FIXTURES[1], 'key2', 'value2')

        local allData = container:getAllData(FIXTURES[1])

        assert(allData['key'] == 'value')
        assert(allData['key2'] == 'value2')
    end,

    -- PlayerCollision test
    function()
        -- Test createCollision, getCollision

        local playerCollision = PlayerCollision(ColShape.Sphere, { 15 })

        local collision1 = playerCollision:createCollision(FIXTURES[1])
        local collision2 = playerCollision:getCollision(FIXTURES[1])

        assert(collision1 == collision2)
    end,
    function()
        -- Test getCollision (if does not exists)

        local playerCollision = PlayerCollision(ColShape.Sphere, { 15 })

        assert(playerCollision:getCollision(FIXTURES[1]) == nil)
    end,
    function()
        -- Test getOrCreateCollision (if does not exists)

        local playerCollision = PlayerCollision(ColShape.Sphere, { 15 })

        local collision1 = playerCollision:getOrCreateCollision(FIXTURES[1])
        local collision2 = playerCollision:getOrCreateCollision(FIXTURES[1])

        assert(collision1 == collision2)
    end,
    function()
        -- Test destroyCollision

        local playerCollision = PlayerCollision(ColShape.Sphere, { 15 })

        playerCollision:createCollision(FIXTURES[1])
        playerCollision:destroyCollision(FIXTURES[1])

        local collision2 = playerCollision:getCollision(FIXTURES[1])

        assert(collision2 == nil)
    end,

    -- compareWithPrecision test
    function()
        assert(compareWithPrecision(1, 1, 0) == true)
        assert(compareWithPrecision(1, -1, 0) == false)

        assert(compareWithPrecision(2, 1, 4) == true)
        assert(compareWithPrecision(-90.8, 1, 4) == false)
    end,

    -- getAngleBetweenPoints test
    function()
        -- https://www.desmos.com/calculator/oaxvait33n

        local center = Vector2(1, 2)

        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(4, 2)),
                0,
                0.001
        ))
        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(3, 4)),
                1 / 4 * math.pi,
                0.001
        ))
        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(1, 3)),
                2 / 4 * math.pi,
                0.001
        ))
        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(-2, 5)),
                3 / 4 * math.pi,
                0.001
        ))
        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(-1, 2)),
                4 / 4 * math.pi,
                0.001
        ))
        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(-1, 0)),
                5 / 4 * math.pi,
                0.001
        ))
        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(1, 0)),
                6 / 4 * math.pi,
                0.001
        ))
        assert(compareWithPrecision(
                getAngleBetweenPoints(center, Vector2(3, 0)),
                7 / 4 * math.pi,
                0.001
        ))
    end,

    -- getNormalAngle test
    function()
        assert(getNormalAngle(140) == 140)
        assert(getNormalAngle(420) == 60)
        assert(getNormalAngle(-90) == 270)
    end,

    -- getMinAngleSign test
    function()
        assert(getMinAngleSign(0, 90) == 1)      -- clockwise
        assert(getMinAngleSign(0, 270) == -1)    -- anti clockwise
        assert(getMinAngleSign(270, 45) == 1)      -- clockwise
        assert(getMinAngleSign(270, 180) == -1)    -- anti clockwise
    end,

    -- rotatePointAroundPivot test
    function()
        -- https://www.desmos.com/calculator/0hljopqtx9
        local point1 = rotatePointAroundPivot(Vector2(0,0), Vector2(0,4), math.pi/2)

        assert(compareWithPrecision(point1.x, 4, 0.001) == true)
        assert(compareWithPrecision(point1.y, 4, 0.001) == true)

        -- https://www.desmos.com/calculator/jch4zt0nao
        local point2 = rotatePointAroundPivot(Vector2(-2, 7), Vector2(0,4), -1.176)
        
        assert(compareWithPrecision(point2.x, 2, 0.001) == true)
        assert(compareWithPrecision(point2.y, 7, 0.001) == true)
    end,
}