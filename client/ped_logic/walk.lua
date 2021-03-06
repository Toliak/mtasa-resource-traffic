customData = {}

PedLogicWalkClass = {
    _ped = nil,
    _pedContainer = nil,

    getNextNode = function(self)
        local nextNodeId = self._pedContainer:getData(self._ped, 'nextNodeId')
        return PATH_LIST[nextNodeId]
    end,

    getNextHelperNode = function(self)
        local nodeId = self._pedContainer:getData(self._ped, 'helperNodeId')
        return PATH_HELPER_LIST[nodeId]
    end,

    getDirection = function(self)
        return self._pedContainer:getData(self._ped, 'direction')
    end,

    -- time to wait before going around obstacle
    getWaitTime = function(self)
        return PED_WAIT_TIME
    end,

    -- time to wait until going around obstacle stops
    getGoAroundTime = function(self)
        return PED_GO_AROUND_TIME
    end,

    -- can ped be rotated
    canBeRotated = function(self)
        if self._ped:isDead() or not self._ped:isOnGround() then
            return false
        end

        if self._ped:getData('goesAround') then
            return false
        end

        local waiting = self._ped:getData('waiting')
        if type(waiting) == 'number' and getTickCount() < waiting then
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

    updateRotation = function(self, isSpawnRotation)
        local node = self:getNextHelperNode() or self:getNextNode()
        local angle = getAngleBetweenPoints(self._ped:getPosition(), node:getPosition())
        local rotation = getNormalAngle(math.deg(angle) - 90)

        self._ped:setCameraRotation(- rotation)
        self._ped:setData('rotation', rotation, true)

        if isSpawnRotation then
            customData[self._ped].isSpawnRotationAvailable = true
            self._ped:setData('spawnRotation', rotation, true)
        end
    end,

    -- update remote ped camera rotation
    checkAndUpdateRotation = function(self)
        if self._pedContainer:isPedInContainer(self._ped) then
            return false
        end

        local rotation = self._ped:getData('rotation')
        if type(rotation) ~= 'number' then
            return false
        end

        self._ped:setCameraRotation(- rotation)
    end,

    checkAndSetSpawnRotation = function(self)
        if not self:canBeRotated() then
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

    _checkSight = function(self, angleDelta)
        local rotation = self._ped:getRotation().z
        if getPedControlState(self._ped, 'backwards') then
            rotation = rotation - 180
        end

        local angle = math.rad(rotation + 90)

        local LENGTH = 4
        local SIGHT_Z_OFFSET = {-0.6, 0.2}
        local CRITICAL_DISTANCE = 0.8

        for _, z in pairs(SIGHT_Z_OFFSET) do
            local currentAngle = angle + angleDelta

            local startPoint = self._ped:getPosition() + Vector3(0,0,z)
            local endPoint = startPoint + Vector3(
                LENGTH * math.cos(currentAngle),
                LENGTH * math.sin(currentAngle), 
                0
                )

            local hit, hitX, hitY, hitZ, hitElement = processLineOfSight(
                startPoint, 
                endPoint,
                true,       -- checkBuildings
                true,       -- checkVehicles
                true,       -- checkPlayers
                true,       -- checkObjects
                true,       -- checkDummies
                false,      -- seeThroughStuff
                false,      -- ignoreSomeObjectsForCamera
                false,      -- shootThroughStuff
                self._ped        -- ignoredElement
            )

            if hit then
                local distance = (Vector3(hitX, hitY, hitZ) - startPoint):getLength()

                if distance <= CRITICAL_DISTANCE then
                    return hitElement or true
                end
            end
        end

        return false
    end,

    checkLeftSight = function(self)
        return self:_checkSight(math.rad(25)) or self:_checkSight(math.rad(60))
    end,

    checkRightSight = function(self)
        return self:_checkSight(math.rad(-25)) or self:_checkSight(math.rad(-60))
    end,

    checkFrontSight = function(self)
        return self:_checkSight(0)
    end,

    checkAndUpdateWait = function(self, waitTime)
        if self._ped:getData('waiting') then
            if getTickCount() < self._ped:getData('waiting') then
                return false
            else
                return true
            end
        end

        self._ped:setData('waiting', getTickCount() + waitTime)
    end,

    checkAndUpdateGoAroundTime = function(self, time)
        if self._ped:getData('goesAroundTime') then
            if getTickCount() < self._ped:getData('goesAroundTime') then
                return false
            else
                return true
            end
        end

        self._ped:setData('goesAroundTime', getTickCount() + time)
    end,

    checkAndUpdateSight = function(self)
        local waiting = self._ped:getData('waiting')
        if type(waiting) == 'number' and getTickCount() < waiting then
            return false
        end
        
        local walking = self._ped:getData('goesAroundTime')
        if type(walking) == 'number' and getTickCount() < walking then
            return false
        end

        local waitTime = self:getWaitTime()
        local goAroundTime = self:getGoAroundTime()
        if self:checkFrontSight() then
            self._ped:setData('goesAround', 'back')
            self:checkAndUpdateWait(waitTime)
            self:checkAndUpdateGoAroundTime(goAroundTime + waitTime)

        elseif self:checkLeftSight() then
            self._ped:setData('goesAround', 'right')
            self:checkAndUpdateWait(waitTime)
            self:checkAndUpdateGoAroundTime(goAroundTime + waitTime)

        elseif self:checkRightSight() then
            self._ped:setData('goesAround', 'left')
            self:checkAndUpdateWait(waitTime)
            self:checkAndUpdateGoAroundTime(goAroundTime + waitTime)

        else
            self._ped:setData('goesAround', false)
            self._ped:setData('goesAroundTime', false)
            self._ped:setData('waiting', false)
        end
    end,

    updateNextNodeHelper = function(self)
        local nextNode = self:getNextNode()
        if not nextNode then 
            return
        end

        local helpers = nextNode:getLink('helper')
        if helpers == nil or #helpers == 0 then
            return
        end

        local nodes = {nextNode}
        for _, helperId in pairs(helpers) do
            table.insert(nodes, PATH_HELPER_LIST[helperId])
        end
        
        local rotation = self._ped:getRotation().z
        local angle = math.rad(rotation + 90)
        local position = self._ped:getPosition()

        local minDistance = nil
        local minNode = nil

        for _, helperNode in pairs(nodes) do
            local delta = helperNode:getPosition() - position
            local rotatedPoint = rotatePointAroundPivot(
                Vector2(delta.x, delta.y), 
                Vector2(0,0),
                -angle
            )

            local manhattanDistance = math.abs(rotatedPoint.x) + math.abs(rotatedPoint.y)
            if minNode == nil or minDistance > manhattanDistance then
                minDistance = manhattanDistance
                minNode = helperNode
            end
        end

        assert(minNode ~= nil)

        if minNode == nextNode then
            self._pedContainer:setData(self._ped, 'helperNodeId', nil)
            return
        end
        
        self._pedContainer:setData(self._ped, 'helperNodeId', minNode.id)
    end,

    canGoForward = function(self)
        if self._ped:isDead() then
            return false
        end

        if self._ped:getData('goesAround') then
            return false
        end

        local waiting = self._ped:getData('waiting')
        if type(waiting) == 'number' and getTickCount() < waiting then
            return false
        end

        return true
    end,

    canGoAround = function(self)
        if self._ped:isDead() then
            return false
        end
        
        if not self._ped:getData('goesAround') then
            return false
        end

        local waiting = self._ped:getData('waiting')
        if type(waiting) == 'number' and getTickCount() < waiting then
            return false
        end

        return true
    end,

    getControlStatesForward = function(self)
        if self:canGoForward() then
            return {
                forwards = true
            }
        end

        return {
            forwards = false
        }
    end,

    getControlStatesSight = function(self)
        if not self:canGoAround() then
            return {}
        end

        if self._ped:getData('goesAround') == 'left' then
            return { left = true }
        elseif self._ped:getData('goesAround') == 'right' then
            return { right = true }
        elseif self._ped:getData('goesAround') == 'back' then
            return { backwards = true }
        end
    end,

    getControlStatesDefault = function(self)
        return { 
            walk = true,
            fire = false,
            aim_weapon = false,
            sprint = false,
            forwards = false,
            backwards = false,
            right = false,
            left = false,
        }
    end,

    getControlStates = function(self)
        local result = {}

        result = mergeDicts(
            self:getControlStatesDefault(),
             self:getControlStatesForward(),
             self:getControlStatesSight()
            )
        
        return result
    end,

    checkAndUpdateTarget = function(self) end,

    onWasted = function(self)
        if not self._pedContainer:isPedInContainer(self._ped) then
            return
        end
    
        self._pedContainer:remove(self._ped)
    end,
}

function PedLogicWalk(ped, pedContainer)
    local object = setmetatable({}, {
        __index = PedLogicWalkClass,
    })

    object._ped = ped
    object._pedContainer = pedContainer

    if not customData[ped] then
        customData[ped] = {}
    end

    return object
end