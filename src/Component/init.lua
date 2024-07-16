--!strict
--// Packages
local Select = require(script.Parent.Select)
local JoinData = require(script.Parent.JoinData)
local ToValue = require(script.ToValue)
local ExchangeDependency = require(script.Parent.Exchange)
local ClearStateObject = require(script.Parent.Clear)

local Scoped = require(script.Parent.State.Scoped)

local Types = require(script.Parent.Types)
type Component = Types.Component

local function Component(...): Component

    debug.profilebegin('new Component')

    local name, default = Select(
        { ... }, 'string', 'table'
    )

    name = name or debug.info(2, "s") :: string .. "@" .. debug.info(2, "l")

    assert(
        default == nil or typeof(default) == 'table',
        'If default data is provided, it must be a table'
    )

    local Class = {
        Kind = 'Component' :: 'Component',
        Name = name,
        _dependents = {},
        _dependencies = {}
    }

    function Class.Instantiate(defaultData: Types.Data?)
        local prototype = defaultData or {}

        if default then
            JoinData(default, prototype)
        end

        prototype = ToValue(prototype)

        local data = Scoped() :: Types.Datatype
        JoinData(prototype, data)

        --// If the component get destroyed, its instances will too
        ExchangeDependency(Class, data)

        --// Applying the component ID to the instance
        --// So we can know this instance component
        data._name = name

        --// Applying its kind to help identify it in bundles / components groups
        data.Kind = 'Datatype' :: any

        return data
    end

    function Class.Destruct()
        ClearStateObject(Class)

        table.clear(Class)
    end

    local Meta = {}

    function Meta:__call(...)
        return Class.Instantiate(...)
    end
    
    setmetatable(Class, Meta)
    
    debug.profileend()

    return Class :: any
end

return Component