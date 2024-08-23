local TestRunner = require(script.Parent.TestRunner)

return function()
    
    for _, module in script.Parent.Modules:GetDescendants() do
        if not module:IsA('ModuleScript') then return end

        require(module)(TestRunner)
    end

    local job = task.spawn(function()
    
        for _, test in TestRunner.tests do

            while not test.result.n do task.wait() end

            if test.result[1] then
                print(`test '{test.name}' successfully passed`)
            else
                warn(`test '{test.name}' failed:\n{test.result[2]}`)
            end
        end
    end)

    return function()
        task.cancel(job)
    end
end