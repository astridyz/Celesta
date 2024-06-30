--!strict
--// Packages
local State = script.Parent

local Update = require(State.Parent.Update)
local clearStateObject = require(State.Parent.Clear)

local Computed = require(State.Computed)

local Types = require(State.Parent.Types)
type StateObject = Types.StateObject
type useFunction = Types.useFunction

type Value<D, O> = Types.Value<D, O>

--// This
local function Value<data>(initialData: data?): Value<data, unknown>

    debug.profilebegin('new Value')

    local Value = {
        _dependencies = {},
        _dependents = {},
        class = 'Value'
    } :: Value<data, unknown>

    local currentData = initialData

    function Value:set(data: any, force: boolean?)
        if data == currentData and not force then
            return
        end

        currentData = data
        Update(Value)
    end

    function Value:get()
        return currentData or {} :: any
    end

    function Value:Computed(result: (use: useFunction) -> ...any)
        return Computed(Value, result :: any)
    end

    function Value:destroy()
        clearStateObject(Value)

        table.clear(Value)
    end

    debug.profileend()

    return Value
end

return Value