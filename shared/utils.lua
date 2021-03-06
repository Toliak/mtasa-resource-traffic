function addSharedEventHandler(name, source, triggerFunction, ...)
    addEvent(name, true)
    addEventHandler(name, source, triggerFunction, ...)
end

function compareWithPrecision(original, compareTo, precision)
    return compareTo - precision <= original and original <= compareTo + precision
end

function getAngleBetweenPoints(pointFrom, pointTo)
    local delta = pointTo - pointFrom
    local length = delta:getLength()

    local sin = delta.y / length
    local cos = delta.x / length

    local asin = math.asin(sin)
    local acos = math.acos(cos)

    if asin < 0 then
        return math.pi * 2 - acos
    end

    return acos
end

function getNormalAngle(angle)
    while angle < 0 do
        angle = angle + 360
    end
    while angle > 360 do
        angle = angle - 360
    end

    return angle
end

function getMinAngleSign(startAngle, endAngle)
    if startAngle == endAngle then
        return 1
    end

    if endAngle > startAngle then
        local clockwise = endAngle - startAngle
        local anticlockwise = 360 + startAngle - endAngle
        
        return (clockwise < anticlockwise) and (1) or (-1)
    else 
        local clockwise = 360 + endAngle - startAngle
        local anticlockwise = startAngle - endAngle
        
        return (clockwise < anticlockwise) and (1) or (-1)
    end
end

function rotatePointAroundPivot(point, pivot, rotation)
    local distance = (pivot - point):getLength()

    local originalAngle = getAngleBetweenPoints(pivot, point)
    local angle = originalAngle + rotation
    
    local delta = Vector2(
        distance * math.cos(angle),
        distance * math.sin(angle)
    )

    return pivot + delta
end

function mergeDicts(...)
    local result = {}

    for _, dict in ipairs({...}) do
        for key, value in pairs(dict) do
            result[key] = value
        end
    end

    return result
end

function mergeLists(...)
    local result = {}
    for _, list in ipairs({...}) do
        for _, v in ipairs(list) do
            table.insert(result, v)
        end
    end
    return result
end

function classCopy(original)
    local result = {}
    for key, value in pairs(original) do
        result[key] = value
    end
    return result
end

function listToSet(list)
    local result = {}
    for _, v in pairs(list) do
        result[v] = true
    end
    return result
end