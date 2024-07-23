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

function Query:No(...: Component<unknown>)
    checkAndSolve({ ... })

    self._no = { ... }

    return Query
end

function Query:Match(storage)
    
    self = self :: Query<unknown>

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

return NewQuery :: (<D>(component: Component<D>) -> Query<ComponentData<D>>)
& (<D, D1>(component: Component<D>, component2: Component<D1>) -> Query<ComponentData<D>, ComponentData<D1>>)
& (<D, D1, D2>(component: Component<D>, component2: Component<D1>, component3: Component<D2>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>>)
& (<D, D1, D2, D3>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>>)
& (<D, D1, D2, D3, D4>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>>)
& (<D, D1, D2, D3, D4, D5>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>, component6: Component<D5>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>>)
& (<D, D1, D2, D3, D4, D5, D6>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>, component6: Component<D5>, component7: Component<D6>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>, ComponentData<D6>>)