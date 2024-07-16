--!strict
--// Packages
local ExchangeDependencyAll = require(script.Parent.ExchangeAll)
local ClearStateObject = require(script.Parent.Clear)

local Types = require(script.Parent.Types)
type Bundle = Types.Bundle
type Datatype = Types.Datatype

local function Bundle(...: Types.Component): Bundle
    
    debug.profilebegin('new bundle')

    local Class = {
        Kind = 'Bundle' :: 'Bundle',
        _dependencies = {},
        _dependents = {},
        _set = { ... }
    }

    ExchangeDependencyAll(Class, Class._set)

    function Class.Use(...: Datatype)
        local Data = {}

        --// Creating datatypes of all the components in the bundle
        for _, component in Class._set do
            local datatype = component()

            Data[datatype._name] = datatype
        end

        --// Overlaying the datatypes set before with the new provided at call
        for _, datatype in { ... } do
            Data[datatype._name] = datatype :: Datatype
        end

        return Data
    end

    function Class.Destruct()
        ClearStateObject(Class)

        table.clear(Class)
    end

    local Meta = {}

    function Meta:__call(...)
        return Class.Use(...)
    end
    
    setmetatable(Class, Meta)

    debug.profileend()

    return Class
end

return Bundle