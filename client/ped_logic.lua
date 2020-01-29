local customData = {}

local PedLogicClass = {
    _ped = nil,
    _pedContainer = nil,

    getNextNode = function(self)
        local nextNodeId = self._pedContainer:getData(self._ped, 'nextNodeId')
        return PATH_LIST[nextNodeId]
    end,

    getDirection = function(self)
        return self._pedContainer:getData(self._ped, 'direction')
    end,

    -- can ped be rotated
    isPedFree = function(self)
        if self._ped:isDead() or not self._ped:isOnGround() then
            return false
        end

        return true
    end,
    
    -- can ped go to the next node
    checkAndUpdateNextNode = function(self)
        local direction = self:getDirection()
        local nextNode = self:getNextNode()

        if direction == nil then
            return
        end

        local distance = (nextNode:getPosition() - self._ped.position):getLength()
        if distance >= MIN_DISTANCE_TO_NODE then
            return
        end

        self:updateNextNode()
    end,

    -- set next node
    updateNextNode = function(self)
        local direction = self:getDirection()
        local nextNode = self:getNextNode()

        local nodes = nextNode:getLink(direction)
        if not (nodes and #nodes ~= 0 )then
            return 
        end

        local nextNodeId = nodes[math.random(1, #nodes)]
        self._pedContainer:setData(self._ped, 'nextNodeId', nextNodeId)

        return PATH_LIST[nextNodeId]
    end,

    checkAndUpdateDirection = function(self)
        if self:getDirection() ~= nil then
            return
        end

        return self:updateDirection()
    end,

    updateDirection = function(self)
        local ALL_DIRECTION_LIST = { 'forward', 'backward' }

        -- collect available directions
        local availableDirectionList = {}
        local nextNode = self:getNextNode()

        for _, dir in pairs(ALL_DIRECTION_LIST) do
            local links = nextNode:getLink(dir)

            if links and #links ~= 0 then
                table.insert(availableDirectionList, dir)
            end
        end

        if #availableDirectionList == 0 then
            outputDebugString(('No available directions for node %d'):format(nextNode.id), 2)
            return
        end

        local newDirection = availableDirectionList[math.random(1, #availableDirectionList)]
        self._pedContainer:setData(self._ped, 'direction', newDirection)

        return newDirection
    end,

    updateRotationTo = function(self, isSpawnRotation)
        local node = self:getNextNode()
        local angle = getAngleBetweenPoints(self._ped:getPosition(), node:getPosition())
        local rotation = getNormalAngle(math.deg(angle) - 90)

        self._ped:setData('rotateTo', rotation, true)

        if isSpawnRotation then
            customData[self._ped].isSpawnRotationAvailable = true
            self._ped:setData('spawnRotation', rotation, true)
        end

        return rotation
    end,

    checkAndSetSpawnRotation = function(self)
        if not self:isPedFree() then
            return
        end

        local isSpawnRotationAvailable = customData[self._ped].isSpawnRotationAvailable
        if not isSpawnRotationAvailable then
            return
        end

        local spawnRotation = self._ped:getData('spawnRotation')
        if type(spawnRotation) ~= 'number' then
            return
        end

        self._ped:setRotation(Vector3(0, 0, spawnRotation))
        customData[self._ped].isSpawnRotationAvailable = false
    end,

    checkAndUpdateRotation = function(self, msec)
        if not self:isPedFree() then
            return
        end

        local rotateTo = self._ped:getData('rotateTo')
        if rotateTo == false then
            return
        end

        if self._ped:getRotation().z ~= rotateTo and compareWithPrecision(self._ped:getRotation().z, rotateTo, 15) then
            self._ped:setRotation(Vector3(0, 0, rotateTo))

        elseif self._ped:getRotation().z ~= rotateTo then
            local rotation = self._ped:getRotation().z

            self._ped:setRotation(
                Vector3(0, 0, rotation + PED_ROTATION_SPEED * msec / 1000 * getMinAngleSign(rotation, rotateTo)))
        end

    end,

    onWasted = function(self)
        if not self._pedContainer:isPedInContainer(self._ped) then
            return
        end
    
        self._pedContainer:remove(self._ped)
    end,
}

function PedLogic(ped, pedContainer)
    local object = setmetatable({}, {
        __index = PedLogicClass,
    })

    object._ped = ped
    object._pedContainer = pedContainer

    if not customData[ped] then
        customData[ped] = {}
    end

    return object
end