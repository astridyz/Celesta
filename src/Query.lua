--!strict
--// Packages
local Component = require(script.Parent.Component)
local AssertComponent = Component.AssertComponent

--// Tping
local Types = require(script.Parent.Types)
type Query<Q...> = Types.Query<Q...>
type Self = Query<unknown>

type Component<D> = Types.Component<D>
type ComponentData<D> = Types.ComponentData<D>

type Dict<I, V> = Types.Dict<I, V>

--// This
local Query  = {}
Query.__index = Query

--// Functions
local function checkAndSolve(...)
    for index, component in { ... } do
        AssertComponent(component, index)
    end
end

local function NewQuery(...)
    
    checkAndSolve(...)

    return setmetatable({

        _no = {},
        _on = {},
        _need = { ... }

    }, Query)
end

function Query.No(self: Self, ...: Component<unknown>)
    checkAndSolve(...)

    self._no = { ... }

    return self
end

function Query.Match(
    self: Self,
    entityID: number,
    storage: Dict<unknown, Component<unknown>>
)

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