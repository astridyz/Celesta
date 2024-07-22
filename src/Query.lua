--// Packages
local Component = require(script.Parent.Component)
local AssertComponent = Component.AssertComponent

local Types = require(script.Parent.Types)
type Query<Q...> = Types.Query<Q...>

type Component<D> = Types.Component<D>
type ComponentData<D> = Types.ComponentData<D>

local function ToDict(object)
    local dict = {}

    for index, component in object do

        AssertComponent(component, index)

        local id = component._id
        
        dict[id] = component
    end

    return dict
end

local Query  = {}
Query.__index = Query

local function NewQuery(...)
    local query = {
        _no = {},
        _need = ToDict({...})
    }

    setmetatable(query, Query)

    return query
end

function Query:No(...: Component<unknown>)
    self._no = ToDict({...})

    return Query
end

function Query:Match(storage)
    
    self = self :: Query<unknown>

    for componentId, _ in self._need do
        if not storage[componentId] then
            return false
        end
    end

    for componentId, _ in self._no do
        if storage[componentId] then
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