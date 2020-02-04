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

    -- This method does not clear ped data
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

        object:setStreamable(false)
    end,

    setData = function(self, ped, key, value)
        assert(isElement(ped), 'PedContainer.setData expected Ped at argument 2')
        assert(getElementType(ped) == 'ped', 'PedContainer.setData expected Ped at argument 2')

        self._data[ped][key] = value
    end,

    getData = function(self, ped, key)
        assert(isElement(ped), 'PedContainer.getData expected Ped at argument 2')
        assert(getElementType(ped) == 'ped', 'PedContainer.getData expected Ped at argument 2')
        assert(self._data[ped] ~= nil, 
                ('PedContainer.getData(%s, %s) Ped "%s" not found'):format(tostring(ped), tostring(key), tostring(isElement(ped))))
        
        return self._data[ped][key]
    end,

    getAllData = function(self, ped)
        assert(isElement(ped), 'PedContainer.getAllData expected Ped at argument 2')
        assert(getElementType(ped) == 'ped', 'PedContainer.getAllData expected Ped at argument 2')

        return self._data[ped]
    end,

    clearData = function(self, ped)
        self._data[ped] = nil
    end,

    isPedInContainer = function(self, ped)
        return self._table[ped] ~= nil
    end, 

    remove = function(self, ped)
        self._table[ped] = nil
        self._data[ped] = nil
    end,

    toList = function(self)
        local result = {}
        for ped, _ in pairs(self._table) do
            table.insert(result, ped)
        end

        return result
    end,

    toDict = function(self)
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