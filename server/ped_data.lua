function pedDataFactory(skin, walkingStyle, defaultLogic, availableWeapons)
    return {
        skin = skin,
        walkingStyle = walkingStyle,
        defaultLogic = defaultLogic,
        availableWeapons = availableWeapons,
    }
end

PED_DATA = {
    -- Men
    pedDataFactory(35, 118, 'walk', {0, 2, 6, 25}),
    pedDataFactory(43, 118, 'walk', {0, 2}),
    pedDataFactory(46, 118, 'walk', {0, 5, 25, 22}),
    pedDataFactory(47, 118, 'walk', {0, 5, 25, 22}),
    pedDataFactory(48, 118, 'walk', {0, 5, 25, 22}),
    pedDataFactory(60, 118, 'walk', {0, 5, 25, 22}),
    pedDataFactory(287, 118, 'walk', {3, 27, 23, 29, 31}),

    -- Women
    pedDataFactory(12, 129, 'walk', {0, 14, 15, 26}),
    pedDataFactory(40, 129, 'walk', {0, 14, 15, 32}),
    pedDataFactory(76, 129, 'walk', {0, 14, 15, 26}),
    pedDataFactory(69, 129, 'walk', {0, 14, 15, 32}),

    -- Gang
    pedDataFactory(102, 121, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(103, 121, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(104, 121, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(105, 122, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(106, 122, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(107, 122, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(108, 121, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(109, 121, 'walk', {5, 25, 22, 24, 30, 28}),
    pedDataFactory(110, 121, 'walk', {5, 25, 22, 24, 30, 28}),
}