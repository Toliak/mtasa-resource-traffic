local IS_CLIENT = dxDrawText ~= nil

local function runTests()
    local failedTests = 0

    for i, testFunction in ipairs(TESTS) do
        local returned, error = pcall(testFunction)

        if returned == false then
            failedTests = failedTests + 1
            outputDebugString(('failed test %d'):format(i), 1)
            outputDebugString(error, 2)
        end

    end

    outputDebugString(
            ('====[TRAFFIC TESTS %s ]===='):format(IS_CLIENT and 'CLIENT' or 'SERVER'),
            0,
            255,
            255,
            255
    )
    outputDebugString(
            ('Failed %d from %d'):format(failedTests, #TESTS),
            0,
            255,
            255,
            255
    )

    for _, object in ipairs(FIXTURES) do
        if isElement(object) then
            object:destroy()
        end
    end
end

addEventHandler('onResourceStart', resourceRoot, runTests)
addEventHandler('onClientResourceStart', resourceRoot, runTests)