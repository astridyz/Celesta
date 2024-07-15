--!strict
--// Packages
local State = script.Parent

local ClearStateObject = require(State.Parent.Clear)

local Computed = require(State.Computed)
local Value = require(State.Value)

local Types = require(State.Parent.Types)
type Scoped<O, D> = Types.Scoped<O, D>

type useFunction = Types.useFunction

local function Scoped(): Types.Scoped<unknown, unknown>
    
    debug.profilebegin('new scope')

    local Class = {
        Kind = 'Scoped' :: 'Scoped',
        _dependents = {},
        _dependencies = {}
    }

    function Class:Computed(value, result: (use: useFunction) -> ...any)
        local computed = Computed(value, result :: any)

        table.insert(Class, computed)

        return computed
    end

    function Class:Value<data>(initialData: data)
        local newValue = Value(initialData)

        table.insert(Class, newValue :: any)

        return newValue
    end

    function Class.Insert(...: any)
        local args = { ... }

        for _, value in args do
            table.insert(Class, value)
        end
    end

    function Class.Destruct()
        ClearStateObject(Class)

        table.clear(Class)
    end

    debug.profileend()

    return Class :: any
end

return Scoped