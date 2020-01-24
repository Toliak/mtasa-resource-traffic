SPAWN_RED_RADIUS = 10
SPAWN_GREEN_RADIUS = 15

MAX_PEDS = 5
CHECK_TIME = 100

local check_time_local = CHECK_TIME

local function trigger()

end

addEventHandler('onClientPreRender', root, function(msec)
    if check_time_local <= 0 then
        check_time_local = 0

        -- lets do it
        trigger()

        return
    end

    check_time_local = check_time_local - msec
end)