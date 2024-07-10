--!strict
--// Packages
local JoinData = require(script.Parent.JoinData)
local ToValue = require(script.ToValue)

local Scoped = require(script.Parent.State.Scoped)

local Types = require(script.Parent.Types)
type Data = Types.Data
type Value<D, O> = Types.Value<D, O>

type Component = Types.Component

local function Component(...): Component

    debug.profilebegin('new component')

    local args = { ... }
    local name
    local default

    --// Unnecessary
    if args[1] ~= nil then

        if typeof(args[1]) == 'string' then
            name = args[1]
            default = args[2] and args[2] or nil

        elseif typeof(args[1]) == 'table' then

            name = args[2] and args[2] or nil
            default = args[1]
        end

    end

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

type newComponent = ((name: string, default: Data?) -> Component)
& ((default: Data, name: string?) -> Component)
& ((name: string?, defalt: Data?) -> Component)

return Component :: newComponent