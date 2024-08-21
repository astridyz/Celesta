--!strict
local Types = require(script.Parent.Parent.Types)

local function OutdateAll(target: Types.State)

    for dependent in target._dependencySet do

        if typeof(dependent) == 'function' then continue end

        dependent._updated = false
        OutdateAll(dependent :: any) -- Types.Update should to be Types.State :angery:
    end
end

return OutdateAll