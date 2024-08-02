--!strict
--// Packages
local Trait = require(script.Parent.Trait)
local Component = require(script.Parent.Component)

local AssertComponentData = Component.AssertComponentData
local AssertComponent = Component.AssertComponent
local AssertTrait = Trait.AssertTrait

local Types = require(script.Parent.Types)
type World = Types.World
type Entity = Types.Entity

type Trait = Types.Trait

type Component<D> = Types.Component<D>
type ComponentData<D> = Types.ComponentData<D>

type Dict<I, V> = Types.Dict<I, V>
type Array<V> = Types.Array<V>

local Entity = {}
Entity.__index = Entity

local function NewEntity(world: World): Entity
    
    local nextId = world._nextId
    world._nextId += 1

    return setmetatable({

        _world = world,
        _storage = {},
        _id = nextId

    }, Entity) :: any
end

function Entity.Add(self: Entity, ...: ComponentData<unknown>)

    for index, data in { ... } do

        AssertComponentData(data, index)

        local metatable = getmetatable(data)
        local id = metatable._id

        self._storage[id] = data :: ComponentData<unknown>
    end

    self._world:_applyTraits(self)
end

function Entity.Remove(self: Entity, ...: Component<unknown>)

    for index, component in { ... } do
        
        AssertComponent(component, index)

        local id = component._id

        local datatype = self._storage[id]
        datatype:Clean()

        self._storage[id] = nil
    end

    self._world:_applyTraits(self)
end

function Entity.Get(self: Entity, ...: Component<unknown>)
    local results = {} :: Types.Array<ComponentData<unknown> | boolean>

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

function Entity.Clear(self: Entity)

    for index, data in self._storage do
        
        AssertComponentData(data, index)
        data:Clean()
    end 

    table.clear(self._storage)

    self._world:_applyTraits(self)
end

function Entity.Destruct(self: Entity)
    self:Clear()

    table.clear(self)
end

local World = {}
World.__index = World

local function NewWorld(): World

    return setmetatable({

        _storage = {},
        _traits = {},
        _nextId = 1

    }, World) :: any
end

function World._addColumnTrait(self: World, entity: Entity, column: Array<Trait>)
    for _, trait in column do
        
        local query = trait._query
        local storage = entity._storage

        if query:Match(entity._id, storage) then
        
            if trait:isApplied(entity) then
                continue
            end

            trait(entity, self, entity:Get(table.unpack(query._need)))
            continue
        end

        if trait:isApplied(entity) then
            trait:Remove(entity)
        end
    end
end

function World._applyTraits(self: World, entity: Entity)
    for priority, colunm in self._traits do
        self:_addColumnTrait(entity, colunm)
    end
end

function World.Import(self: World, ...: Trait)
    for index, object in { ... } do
        
        AssertTrait(object, index)

        local priority = object._priority
        local traits = self._traits

        if not traits[priority] then
            traits[priority] = {}
        end

        table.insert(traits[priority], object)
    end
end

function World.Entity(self: World, ...: ComponentData<unknown>)
    local entity = NewEntity(self)
    self._storage[entity._id] = entity

    entity:Add(...)

    return entity
end

function World.Get(self: World, ID: number)
    local entity = self._storage[ID]

    if not entity then
        return
    end

    return entity
end

function World.Despawn(self: World, ID: number)
    local entity = self:Get(ID)

    if not entity then
        return
    end

    entity:Destruct()
end

return NewWorld