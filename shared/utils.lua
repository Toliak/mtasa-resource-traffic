function addSharedEventHandler(name, source, triggerFunction, ...)
    addEvent(name, true)
    addEventHandler(name, source, triggerFunction, ...)
end