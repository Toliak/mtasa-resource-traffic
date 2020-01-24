local PedContainerClass = {
    _table = nil, -- acts like std::set

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
        assert(isElement(object), 'PedList.append expected Ped at argument 2')
        assert(getElementType(object) == 'ped', 'PedList.append expected Ped at argument 2')

        self._table[object] = true
    end
}

function PedContainer()
    local object = setmetatable({}, {
        __index = PedContainerClass,
    })

    object._table = {}

    return object
end