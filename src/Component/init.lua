--!strict
--// Packages
local JoinData = require(script.Parent.JoinData)
local ToValue = require(script.ToValue)

local Scoped = require(script.Parent.State.Scoped)

local Types = require(script.Parent.Types)
type Data = Types.Data
type Value<D, O> = Types.Value<D, O>

type Component = Types.Component

local function Component(name: string?, default: Data?): Component

    debug.profilebegin('new component')

    assert(
        default == nil or typeof(default) == 'table',
        'If default data is provided, it must be a table'
    )

    name = name or debug.info(2, "s") :: string .. "@" .. debug.info(2, "l")

    local Class = {
        name = name :: string,
    }

    function Class.new(parcialData: Data?)
        parcialData = parcialData or {}

        if default then
            JoinData(default, parcialData)
        end

        local data = ToValue(parcialData :: Data)

        data = JoinData(data, Scoped())

        data._name = name :: string

        return data :: Types.Scoped<unknown> & Types.ComponentData
    end

    local meta = {}

    function meta:__call(parcialData: Data?)
        return Class.new(parcialData)
    end

    setmetatable(Class, meta)

    debug.profileend()

    return Class
end

return Component