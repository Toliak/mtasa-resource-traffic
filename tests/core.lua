local IS_CLIENT = dxDrawText ~= nil

local function runTests()
    local failedTests = 0

    for i, testFunction in ipairs(TESTS) do
        local returned, error = pcall(testFunction)

        if returned == false then
            failedTests = failedTests + 1
            iprint('failed test ', i)
            iprint(error)
        end

    end

    iprint(('====[TRAFFIC TESTS %s ]===='):format(IS_CLIENT and 'CLIENT' or 'SERVER'))
    iprint('Failed ', failedTests, 'from', #TESTS)

    for _, object in ipairs(FIXTURES) do
        object:destroy()
    end
end

addEventHandler('onResourceStart', resourceRoot, runTests)
addEventHandler('onClientResourceStart', resourceRoot, runTests)