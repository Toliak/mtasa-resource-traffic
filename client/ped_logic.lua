local PedLogicClass = {
    _ped = nil,
}

function PedLogic(ped)
    local object = setmetatable({}, {
        __index = PedLogicClass,
    })

    object._ped = ped

    return object
end