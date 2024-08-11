--!strict
--// Typing
local Types = require(script.Parent.Parent.Types)

--// This
local function Destruct(object: Types.State)
    for dependency in object._dependencySet do
        
        if typeof(dependency) ~= 'table' then
            continue
        end

        if dependency.Update then
            dependency:Update()
        end
    end

    table.clear(object)
end

return Destruct