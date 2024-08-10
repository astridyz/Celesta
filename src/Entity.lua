--!strict
--// Packages
local Component = require(script.Parent.Component)
local AssertComponentData = Component.AssertComponentData
local AssertComponent = Component.AssertComponent

local Types = require(script.Parent.Types)
type Self = Types.Entity
type World = Types.World

type Component<D> = Types.Component<D>
type ComponentData<D> = Types.ComponentData<D>

local Entity = {}
Entity.__index = Entity

local function NewEntity(world: World): Types.Entity
    
    local nextId = world._nextId
    world._nextId += 1

    return setmetatable({

        _world = world,
        _storage = {},
        _id = nextId

    }, Entity) :: any
end

function Entity.Add(self: Self, ...: ComponentData<unknown>)

    for index, data in { ... } do

        AssertComponentData(data, index)

        local metatable = getmetatable(data)
        local id = metatable._id

        self._storage[id] = data :: ComponentData<unknown>
    end

    self._world:_applyTraits(self)
end

function Entity.Remove(self: Self, ...: Component<unknown>)

    for index, component in { ... } do
        
        AssertComponent(component, index)

        local id = component._id

        local datatype = self._storage[id]
        datatype:Clean()

        self._storage[id] = nil
    end

    self._world:_applyTraits(self)
end

function Entity.Get(self: Self, ...: Component<unknown>)

    local results = {} ::
    Types.Array<ComponentData<unknown> | boolean>

    for index, component in { ... } do
        
        AssertComponent(component, index)

        local id = component._id
        local datatype = self._storage[id]

        if not datatype then
            table.insert(results, false)
        end

        table.insert(results, datatype)
    end

    return unpack(results)
end

function Entity.Clear(self: Self)

    for index, data in self._storage do
        
        AssertComponentData(data, index)
        data:Clean()
    end 

    table.clear(self._storage)

    self._world:_applyTraits(self)
end

function Entity.Destruct(self: Self)
    self:Clear()

    table.clear(self)
end

return NewEntity