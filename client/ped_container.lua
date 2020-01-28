local PedContainerClass = {
    _table = nil, -- acts like std::set
    _data = nil, -- acts like std::map

    getLength = function(self)
        local length = 0
        for _, _ in pairs(self._table) do
            length = length + 1
        end
        return length
    end,

    removeIfNotInSphere = function(self, center, radius)
        local result = {}

        for object, _ in pairs(self._table) do
            local distance = (object.position - center):getLength()

            if distance > radius then
                table.insert(result, object)        -- add to result list
                self._table[object] = nil           -- remove from set
            end
        end

        return result
    end,

    append = function(self, object)
        assert(isElement(object), 'PedContainer.append expected Ped at argument 2')
        assert(getElementType(object) == 'ped', 'PedContainer.append expected Ped at argument 2')

        self._table[object] = true
        self._data[object] = {}
    end,

    setData = function(self, ped, key, value)
        assert(isElement(ped), 'PedContainer.setData expected Ped at argument 2')
        assert(getElementType(ped) == 'ped', 'PedContainer.setData expected Ped at argument 2')

        self._data[ped][key] = value
    end,

    getData = function(self, ped, key)
        assert(isElement(ped), 'PedContainer.getData expected Ped at argument 2')
        assert(getElementType(ped) == 'ped', 'PedContainer.getData expected Ped at argument 2')

        return self._data[ped][key]
    end,

    toList = function(self)
        -- TODO: test

        local result = {}
        for ped, _ in pairs(self._table) do
            table.insert(result, ped)
        end

        return result
    end,

    toDict = function(self)
        -- TODO: test

        local result = {}
        for ped, _ in pairs(self._table) do
            result[ped] = self._data[ped]
        end

        return result
    end
}

function PedContainer()
    local object = setmetatable({}, {
        __index = PedContainerClass,
    })

    object._table = {}
    object._data = {}

    return object
end