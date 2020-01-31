FIXTURES = {
    Ped(1, 0, 0, 0), -- 1
    Ped(1, -4, 0, 0),
    Ped(1, 6, 0, 0), -- 3
}

TESTS = {
    -- pathNodeToString tests
    function()
        -- Basic test

        local pathNode = PathNode(4, 5, 3, { forward = 1, backward = 2 })
        local pathString = pathNodeToString(pathNode)

        assert(pathString:find('4'))
        assert(pathString:find('5'))
        assert(pathString:find('3'))
        assert(pathString:find('forward.+=.+1'))
        assert(pathString:find('backward.+=.+2'))
    end,

    -- PedContainer tests
    function()
        -- Test append, getLength

        local pedList = PedContainer()
        assert(pedList:getLength() == 0)

        pedList:append(FIXTURES[1])
        assert(pedList:getLength() == 1)

        pedList:append(FIXTURES[2])
        assert(pedList:getLength() == 2)

        pedList:append(FIXTURES[3])
        assert(pedList:getLength() == 3)
    end,
    function()
        -- Test removeIfNotInSphere

        local pedList = PedContainer()
        pedList:append(FIXTURES[1])
        pedList:append(FIXTURES[2])
        pedList:append(FIXTURES[3])

        local result = pedList:removeIfNotInSphere(Vector3(0, 0, 0), 5)
        assert(#result == 1)
        assert(result[1] == FIXTURES[3])

        result = pedList:removeIfNotInSphere(Vector3(10, 10, 10), 5)
        assert(#result == 2)
    end,
    function()
        -- Test setData, getData

        local pedList = PedContainer()
        pedList:append(FIXTURES[1])

        pedList:setData(FIXTURES[1], 'key', 'value')
        assert(pedList:getData(FIXTURES[1], 'key') == 'value')
    end,
    function()
        -- Test getAllData

        local pedList = PedContainer()
        pedList:append(FIXTURES[1])

        pedList:setData(FIXTURES[1], 'key', 'value')
        pedList:setData(FIXTURES[1], 'key1', 'value1')
        local data = pedList:getAllData(FIXTURES[1])

        assert(data['key'] == 'value')
        assert(data['key1'] == 'value1')
    end,
    function()
        -- Test clearData

        local pedList = PedContainer()
        pedList:append(FIXTURES[1])
        pedList:setData(FIXTURES[1], 'key', 'value')

        pedList:clearData(FIXTURES[1])

        assert(pedList._data[FIXTURES[1]] == nil)
    end,
    function()
        -- Test isPedInContainer

        local pedList = PedContainer()
        pedList:append(FIXTURES[1])

        assert(pedList:isPedInContainer(FIXTURES[1]) == true)
        assert(pedList:isPedInContainer(FIXTURES[2]) == false)
    end,
    function()
        -- Test remove

        local pedList = PedContainer()
        pedList:append(FIXTURES[1])
        pedList:remove(FIXTURES[1])

        assert(pedList:isPedInContainer(FIXTURES[1]) == false)
    end,

}