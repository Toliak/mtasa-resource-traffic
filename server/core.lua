local PedListClass = {
    _list = {}
}

function PedList()
    return setmetatable({}, {
        __index = PedListClass,
    })
end

ped_list = PedList()   -- Dict[Player, Ped]


addEventHandler('onClientPedRequest', resourceRoot, function()

end)