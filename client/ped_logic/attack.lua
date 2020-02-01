PedLogicAttackClass = classCopy(PedLogicWalkClass)

PedLogicAttackClass.updateRotationToTarget = function(self, target)
    local target = self._pedContainer:getData(self._ped, 'attackTarget')
    if not isElement(target) then
        return
    end
    
    local angle = getAngleBetweenPoints(self._ped:getPosition(), target:getPosition())
    local rotation = getNormalAngle(math.deg(angle) - 90)
    
    self._ped:setData('rotateTo', rotation, true)
end

PedLogicAttackClass.updateRotationTo = function(self)
    local target = self._pedContainer:getData(self._ped, 'attackTarget')
    if not isElement(target) then
        return PedLogicWalkClass.updateRotationTo(self)
    end

    return self:updateRotationToTarget(target)
end

PedLogicAttackClass.getTargetPivotPosition = function(self, target)
    local originalPosition = target:getPosition()
    if target:getType() == 'player' or target:getType() == 'ped' then
        originalPosition = target:getBonePosition(2)
    end

    local velocityDelta = target:getVelocity() * 10
    return originalPosition + Vector3(velocityDelta.x, velocityDelta.y, 0)
end

PedLogicAttackClass.canBeRotated = function(self)
    if self:canAttack() then
        return false
    end

    return PedLogicWalkClass.canBeRotated(self)
end

PedLogicAttackClass.checkAndUpdateTarget = function(self)
    local target = self._pedContainer:getData(self._ped, 'attackTarget')
    if not isElement(target) then
        return
    end
    
    local pivot = self:getTargetPivotPosition(target)
    local delta = pivot - self._ped:getPosition()
    delta = delta * PED_AIM_DISTANCE / delta:getLength()

    local aimTarget = self._ped:getPosition() + delta
    customData[self._ped]['targetPivot'] = aimTarget

    self._ped:setAimTarget(aimTarget)

    local angleBetween = math.deg(getAngleBetweenPoints(self._ped:getPosition(), aimTarget))
    if getNormalAngle(angleBetween) > 30 then
        self._ped:setRotation(0,0,self._ped:getData('rotateTo'))
    end
    -- self._ped:setRotation(0,0,self._ped:getData('rotateTo'))
    -- self._ped:setCameraRotation(self._ped:getData('rotateTo'))
    -- self._ped:setLookAt(aimTarget, 100, 100,target )
end

PedLogicAttackClass.canAttack = function(self)
    local target = self._pedContainer:getData(self._ped, 'attackTarget')
    if not isElement(target) then
        return false
    end
    target = target:getOccupiedVehicle() or target
    
    local distanceToTarget = (target:getPosition() - self._ped:getPosition()):getLength()
    local attackDistance = PED_MIN_ATTACK_DISTANCE[self._ped:getWeapon()] or 1

    if target:getType() == 'vehicle' then
        attackDistance = attackDistance + 1.5
    end

    if distanceToTarget > attackDistance then
        return false
    end

    return true
end

PedLogicAttackClass.getControlStatesAttack = function(self)
    if not self:canAttack() then
        return {
            fire = false,
            aim_weapon = false,
        }
    end

    return {
        fire = true,
        aim_weapon = true,
    }
end

PedLogicAttackClass.getControlStatesForward = function(self)
    if self:canAttack() then
        return {}
    end

    return PedLogicWalkClass.getControlStatesForward(self)
end

PedLogicAttackClass.getControlStatesDefault = function(self)
    local result = PedLogicWalkClass.getControlStatesDefault(self)

    result['walk'] = false
    result['sprint'] = false

    return result
end

PedLogicAttackClass.getControlStates = function(self)
    local result = PedLogicWalkClass.getControlStates(self)

    return mergeDicts(
        result,
        self:getControlStatesAttack()
    )
end

PedLogicAttackClass._checkSight = function(self, angleDelta)
    local result = PedLogicWalkClass._checkSight(self, angleDelta)

    local target = self._pedContainer:getData(self._ped, 'attackTarget')
    if not isElement(target) then
        return result
    end

    if not isElement(result) then
        return result
    end

    -- sight is clear if result is target
    if target == result or target:getOccupiedVehicle() == result then
        return false
    end

    return result
end

PedLogicAttackClass.updateNextNodeHelper = function(self)
    local target = self._pedContainer:getData(self._ped, 'attackTarget')
    if isElement(target) then
        return
    end

    return PedLogicWalkClass.updateNextNodeHelper(self)
end

function PedLogicAttack(ped, pedContainer)
    local object = setmetatable({}, {
        __index = PedLogicAttackClass,
    })

    object._ped = ped
    object._pedContainer = pedContainer

    if not customData[ped] then
        customData[ped] = {}
    end

    return object
end
