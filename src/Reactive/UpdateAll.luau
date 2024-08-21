--!strict
local Types = require(script.Parent.Parent.Types)

local function UpdateAll(target: Types.State)

    for dependent in target._dependencySet do

        if typeof(dependent) == 'table' and dependent:_update() then
        elseif typeof(dependent) == 'function' then dependent() end
    end
end

return UpdateAll