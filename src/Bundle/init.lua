--!strict
--// Packages
local ExchangeDependencyAll = require(script.Parent.ExchangeAll)
local ClearStateObject = require(script.Parent.Clear)

local Types = require(script.Parent.Types)
type Bundle = Types.Bundle
type Datatype = Types.Datatype

local function Bundle(...: Types.Component): Bundle
    
    debug.profilebegin('new Class')

    local Class = {
        Kind = 'Bundle' :: 'Bundle',
        _dependencies = {},
        _dependents = {},
        _set = { ... }
    }

    ExchangeDependencyAll(Class, Class._set)

    function Class.Use(...: Datatype)
        local Data = {}

        for _, component in Class._set do
            local datatype = component()

            Data[datatype._name] = datatype
        end

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