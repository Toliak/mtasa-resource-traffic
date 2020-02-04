SPAWN_RED_RADIUS = 30
SPAWN_GREEN_RADIUS = 55

MAX_PEDS = 16
MAX_PED_PER_SPAWN = 2
CHECK_TIME_SPAWN = 150
CHECK_TIME_RELEASE = 800
CHECK_TIME_PED_KEYS = 200
CHECK_TIME_PED_STATE = 100
CHECK_TIME_PED_STATE_LONG = 1500

NODE_SPAWN_COOLDOWN = 3000

PED_ROTATION_SPEED = 200            -- deg per second
PED_WAIT_TIME = 500                 -- ped wait before going around obstacle
PED_WAIT_TIME_ATTACK = 100          -- ped wait before going around obstacle (attack logic)
PED_GO_AROUND_TIME = 600            -- ped go left/right/back from obstacle
PED_GO_AROUND_TIME_ATTACK = 1500           -- ped go left/right/back from obstacle (attack logic)
PED_DEATH_REMOVE = 1500             -- remove ped after death
PED_AIM_DISTANCE = 30               -- constant aim distance
PED_MELEE_CLICK_COOLDOWN = 300      -- ... Must be not smaller than CHECK_TIME_PED_KEYS

PED_GANG_ATTACK_MIN_DISTANCE = 25

-- dict<weaponId, distance>
local MELEE_DISTANCE = 1.5
PED_MIN_ATTACK_DISTANCE = {
    -- Melee
    [0] = MELEE_DISTANCE,
    [1] = MELEE_DISTANCE,
    [2] = MELEE_DISTANCE,
    [3] = MELEE_DISTANCE,
    [4] = MELEE_DISTANCE,
    [5] = MELEE_DISTANCE,
    [6] = MELEE_DISTANCE,
    [7] = MELEE_DISTANCE,
    [8] = MELEE_DISTANCE,
    [9] = MELEE_DISTANCE,
    [10] = MELEE_DISTANCE,
    [11] = MELEE_DISTANCE,
    [12] = MELEE_DISTANCE,
    [13] = MELEE_DISTANCE,
    [14] = MELEE_DISTANCE,
    [15] = MELEE_DISTANCE,

    [22] = 8,
    [23] = 9,
    [24] = 10,
    
    [25] = 10,
    [26] = 5,
    [27] = 12,

    [28] = 7,
    [29] = 14,
    [32] = 9,

    [30] = 17,
    [31] = 20,
}


MIN_DISTANCE_TO_NODE = 2            -- min distance before ped can go to the next node
