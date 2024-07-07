--!strict
local Value = require(script.Parent.Parent.State.Value)

local Types = require(script.Parent.Parent.Types)
type ComponentData = Types.ComponentData

local function ToValue(data: {[string]: any}): Types.ComponentData

    assert(typeof(data) == 'table', 'Data needs to be an table.')

    local newData = {}

    for index, value in data do

        --[[
        if typeof(value) == 'table' then
            warn('Fields of type table in component data wont receive values.')
        end
        ]]

        newData[index] = Value(value)
    end

    return newData :: any
end

return ToValue