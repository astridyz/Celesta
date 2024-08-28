--!strict
local Component = require(script.Parent.Component)
local AssertComponent = Component.AssertComponent

local Types = require(script.Parent.Types)
type Query<Q...> = Types.Query<Q...>
type Component<D> = Types.Component<D>

local Query  = {}
Query.__index = Query

local function checkAndSolve(
    query: Query<unknown>,
    ...: Component<unknown>
): { Component<unknown> }

    local all = query._all
    local field = {}

    for index, component in { ... } do

        AssertComponent(component, index)

        table.insert(all, component)
        table.insert(field, component)
    end

    return field
end

local function NewQuery<Q...>(...): Query<Q...>
    
    local self = setmetatable({

        _no = {},
        _on = {},
        _need = {},
        _all = {}

    }, Query) :: any

    self._need = checkAndSolve(self, ...)

    return self
end

function Query.No(
    self: Query<unknown>,
    ...: Component<unknown>
): Query<unknown>

    self._no = checkAndSolve(self, ...)

    return self
end

function Query.Match(
    self: Query<unknown>,
    entityID: number,
    storage: {[unknown]: Types.ComponentData<unknown>}
): boolean

    for _, component in ipairs(self._need) do
        local id = component._id

        if not storage[id] then
            return false
        end
    end

    for _, component in ipairs(self._no) do
        local id = component._id

        if storage[id] then
            return false
        end
    end

    return true
end

return (NewQuery :: any) :: Types.QueryConstructor