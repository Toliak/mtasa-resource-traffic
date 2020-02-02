SPAWN_RED_RADIUS = 30
SPAWN_GREEN_RADIUS = 55

MAX_PEDS = 16
CHECK_TIME_SPAWN = 150
CHECK_TIME_RELEASE = 800
CHECK_TIME_PED_KEYS = 200
CHECK_TIME_PED_STATE = 100

NODE_SPAWN_COOLDOWN = 3000

PED_ROTATION_SPEED = 200            -- deg per second
PED_WAIT_TIME = 500                 -- ped wait before going around obstacle
PED_WAIT_TIME_ATTACK = 100          -- ped wait before going around obstacle (attack logic)
PED_GO_AROUND_TIME = 600            -- ped go left/right/back from obstacle
PED_GO_AROUND_TIME_ATTACK = 1500           -- ped go left/right/back from obstacle (attack logic)
PED_DEATH_REMOVE = 1500             -- remove ped after death
PED_AIM_DISTANCE = 30               -- constant aim distance

-- dict<weaponId, distance>
-- TODO get rid of this: Ped:getTargetStart, Ped:getTargetEnd
PED_MIN_ATTACK_DISTANCE = {
    [0] = 1,
    [1] = 1,
    [22] = 8,
    [31] = 15,
    [25] = 10,
}


MIN_DISTANCE_TO_NODE = 2            -- min distance before ped can go to the next node
