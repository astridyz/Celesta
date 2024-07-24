--!strict
--// Packages
local Component = require(script.Parent.Component)

local AssertComponent = Component.AssertComponent

local Types = require(script.Parent.Types)
type Query<Q...> = Types.Query<Q...>

type Component<D> = Types.Component<D>
type ComponentData<D> = Types.ComponentData<D>

local function checkAndSolve(object)
    for index, component in object do
        AssertComponent(component, index)
    end
end

local Query  = {}
Query.__index = Query

local function NewQuery(...)
    checkAndSolve({ ... })

    local query = {
        _no = {},
        _need = { ... }
    }

    setmetatable(query, Query)

    return query
end

function Query.No(self: Query<unknown>, ...: Component<unknown>)
    checkAndSolve({ ... })

    self._no = { ... }

    return Query
end

function Query.Match(self: Query<unknown>, storage)
    for _, component in self._need do
        local id = component._id

        if not storage[id] then
            return false
        end
    end

    for _, component in self._no do
        local id = component._id

        if storage[id] then
            return false
        end
    end

    return true
end

return (NewQuery :: any) :: Types.QueryConstructor