--!strict
local Types = require(script.Parent.Parent.Types)

local function Destruct(state: Types.State)
    table.clear(state._dependencySet)
    table.clear(state)
end

return Destruct