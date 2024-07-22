--// Packages
local Destruct = require(script.Parent.Destruct)
local UpdateAll = require(script.Parent.UpdateAll)

local Types = require(script.Parent.Parent.Types)
type Dict<I, V> = Types.Dict<I, V>

local function Value<data>(scope: Dict<unknown, unknown>, initialData: data?): Types.Value<data>
    local Value = {
        _dependencySet = {},
    }

    local currentData = initialData

    function Value.Get()
        return currentData
    end

    function Value.Set(data: unknown, force: boolean?)
        if data == currentData and not force then
            return
        end

        currentData = data
        UpdateAll(Value)
    end

    function Value.Destruct()
        Destruct(Value)
        table.clear(Value)
    end

    table.insert(scope :: {}, Value.Destruct)

    return Value
end

return Value