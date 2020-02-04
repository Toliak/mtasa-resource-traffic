function getPedLogic(ped, ...)
    local logicName = ped:getData('logic')

    if type(logicName) ~= 'string' or logicName == 'walk' then
        return PedLogicWalk(ped, ...)

    elseif logicName == 'run' then
        return PedLogicRun(ped, ...)

    elseif logicName == 'attack' then
        return PedLogicAttack(ped, ...)
        
    end

    return PedLogicWalk(ped, ...)
end

local function isGangPedAvailable(pedAttacker, pedGang)
    if pedGang:isDead() then
        return false
    end

    if pedGang:getData('logic') ~= 'walk' then
        return false
    end

    local distance = (pedAttacker:getPosition() - pedGang:getPosition()):getLength()
    if distance >= PED_GANG_ATTACK_MIN_DISTANCE then
        return false
    end

    local sightClear = isLineOfSightClear(
        pedAttacker:getPosition(),
        pedGang:getPosition(),
        true,    -- checkBuildings
        true,    -- checkVehicles
        false,    -- checkPeds
        true,    -- checkObjects
        false,    -- checkDummies
        true,    -- seeThroughStuff
        true,    -- ignoreSomeObjectsForCamera
        nil     -- ignoredElement
    )
    if not sightClear then
        return false
    end

    return true
end

local function checkGang(ped)
    if ped:isDead() then
        return
    end

    local BALLAS = {102, 103, 104}
    local GROVE = {105, 106, 107}
    local VAGOS = {108, 109, 110} 

    local GANG = listToSet(mergeLists(GROVE, BALLAS, VAGOS))
    if GANG[ped:getModel()] == nil then
        return
    end

    local NOT_GROVE = listToSet(mergeLists(BALLAS, VAGOS))
    local NOT_BALLAS = listToSet(mergeLists(GROVE, VAGOS))
    local NOT_VAGOS = listToSet(mergeLists(BALLAS, GROVE))

    local ANTI_SKIN_MAPPING = {
        {GROVE, NOT_GROVE},
        {BALLAS, NOT_BALLAS},
        {VAGOS, NOT_VAGOS},
    }
    local ANTI_SKIN = {}
    for _, pair in pairs(ANTI_SKIN_MAPPING) do
        for _, skin in pairs(pair[1]) do        -- for every skin set of anti skins
            ANTI_SKIN[skin] = pair[2]
        end
    end
    
    local antiSkinSet = ANTI_SKIN[ped:getModel()]

    local pedList = viewCollision:getElementsWithin('ped')
    for _, otherPed in pairs(pedList) do
        if antiSkinSet[otherPed:getModel()] and isGangPedAvailable(ped, otherPed) then
            ped:setData('attackTarget', otherPed)
            ped:setData('logic', 'attack')

            otherPed:setData('attackTarget', ped)
            otherPed:setData('logic', 'attack')
            
            break
        end
    end
end

function changePedLogic(ped)
    local logicName = ped:getData('logic')
    if logicName == 'walk' then
        checkGang(ped)
    elseif logicName == 'attack' then
        local target = ped:getData('attackTarget')
        
        if not isElement(target) or target:isDead() then
            ped:setData('logic', 'walk')
            ped:setData('attackTarget', false)
        end
    end
end