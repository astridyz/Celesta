--!strict
--// Packages
local State = script.Parent

local Update = require(State.Parent.Update)
local clearStateObject = require(State.Parent.Clear)

local Types = require(State.Parent.Types)
type useFunction = Types.useFunction

type Value<D, O> = Types.Value<D, O>

--// This
local function Value<data>(initialData: data?): Value<unknown, data>

    debug.profilebegin('new value')

    local Class = {
        Kind = 'Value' :: 'Value',
        _dependencies = {},
        _dependents = {},
    } :: Value<unknown, data>

    local currentData = initialData

    function Class:set(data: any, force: boolean?)
        if data == currentData and not force then
            return
        end

        currentData = data
        Update(Class)
    end

    function Class:get()
        return currentData or {} :: any
    end

    function Class.Destruct()
        clearStateObject(Value)

        table.clear(Class)
    end

    debug.profileend()

    return Class
end

return Value