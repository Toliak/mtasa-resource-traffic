local function collectInfoAboutPed(ped, client)
    local controller = (function()
        for player, pedSet in pairs(pedContainer._table) do
            
            for playerPed, _ in pairs(pedSet) do
                if playerPed == ped then 
                    return player
                end
            end

        end

        return nil
    end)()

    local controllerName = '#FF0000NIL'
    if controller ~= nil then
        controllerName = (controller == client) and '#00FF00' or '#FFFFFF'
        controllerName = controllerName .. controller:getName()
    end
    
    return {
        controller = controllerName,
        syncer = ped:getSyncer():getName(),
    }
end

addEvent('onPlayerDebugRequest', true)
addEventHandler('onPlayerDebugRequest', resourceRoot, function(pedList)
    local debugInfoDict = {}

    for _, ped in pairs(pedList) do
        debugInfoDict[ped] = collectInfoAboutPed(ped, client)
    end

    triggerClientEvent(client, 'onClientDebugRequest', resourceRoot, debugInfoDict)
end)