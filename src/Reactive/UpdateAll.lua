--!strict
--// Packages
local Types = require(script.Parent.Parent.Types)

local function UpdateAll(target: Types.State)

    for dependent in target._dependencySet do

        if typeof(dependent) == 'table' and dependent.Update then
            dependent:Update()
        
        elseif typeof(dependent) == 'function' then
            dependent()

        end
    end
end

return UpdateAll