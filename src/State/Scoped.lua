--!strict
--// Packages
local Computed = require(script.Parent.Computed)
local Value = require(script.Parent.Value)

local Types = require(script.Parent.Parent.Types)
type Scoped<O> = Types.Scoped<O>

type useFunction = Types.useFunction

local function Scoped()
    
    debug.profilebegin('new Scope')

    local Scope = {} :: Scoped<unknown>

    function Scope:Computed(value, result: (use: useFunction) -> ...any)
        local computed = Computed(value, result :: any)

        table.insert(Scope, computed)

        return computed
    end

    function Scope:Value<data>(initialData: data)
        local value = Value(initialData)

        table.insert(Scope, value)

        return value :: any
    end

    debug.profileend()

    return Scope
end

return Scoped