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