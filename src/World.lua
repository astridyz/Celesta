--// Packages
local unpack = unpack

local Component = require(script.Parent.Component)
local AssertComponentData = Component.AssertComponentData
local AssertComponent = Component.AssertComponent

local Types = require(script.Parent.Types)
type World = Types.World
type Entity = Types.Entity

type Component<D> = Types.Component<D>
type ComponentData<D> = Types.ComponentData<D>

type Trait = Types.Trait

type Dict<I, V> = Types.Dict<I, V>

local Entity = {}
Entity.__index = Entity
Entity.Kind = 'Entity'

local function NewEntity(world: World): Entity
    local nextId = world._nextId
    world._nextId += 1

    local newEntity = {
        _world = world,
        _storage = {},
        _id = nextId
    }

    setmetatable(newEntity, Entity)

    return newEntity :: any
end

function Entity:Add(...: ComponentData<unknown>)
    self = self :: Entity

    for index, data in { ... } do

        AssertComponentData(data, index)

        local metatable = getmetatable(data)
        local id = metatable._id

        self._storage[id] = data
    end

    self._world:_applyTraits(self)
end

function Entity:Remove(...: Component<unknown>)
    self = self :: Entity

    for index, component in { ... } do
        
        AssertComponent(component, index)

        local id = component._id

        local datatype = self._storage[id]
        datatype:Clean()

        self._storage[id] = nil
    end

    self._world:_applyTraits(self)
end

function Entity:Get(...: Component<unknown>)
    self = self :: Entity

    local results = {}

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

function Entity:Clear()
    self = self :: Entity

    for index, data in self._storage do
        
        AssertComponentData(data, index)
        data:Clean()
    end 

    table.clear(self._storage)

    self._world:_applyTraits(self)
end

function Entity:Destruct()
    self:Clear()

    table.clear(self)
end

local World = {}
World.__index = World

local function NewWorld(): Types.World
    local world = {
        _storage = {},
        _traits = {},
        _nextId = 0
    }

    setmetatable(world, World)

    return world :: any
end

function World:_applyTraits(entity: Entity)
    self = self :: World

    for query, trait in self._traits do
    
        if query:Match(entity._storage) then
            
            if trait:isApplied(entity) then
                continue
            end

            trait(entity, self, entity:Get(unpack(query._need)))
            continue
        end

        if trait:isApplied(entity) then
            trait:Remove(entity)
        end
    end
end

function World:Import(...: Trait | {Trait})
    for _, object in { ... } do
        
        assert(typeof(object) == 'table', 'Invalid trait type: not a table')

        if not object.Kind or object.Kind ~= 'Trait' then
            self:Import(object)
            continue
        end

        local traits = self._traits
        local query = object._query

        assert(query, 'Invalid trait type: Doesnt have a query')

        traits[query] = object
    end
end

function World:Entity(...: ComponentData<unknown>)
    local entity = NewEntity(self)

    entity:Add(...)

    self._storage[entity._id] = entity
    return entity
end

function World:Get(ID: number)
    
    self = self :: World

    local entity = self._storage[ID]

    if not entity then
        return
    end

    return entity
end

function World:Despawn(ID: number)
    self = self :: World

    local entity = self:Get(ID)

    if not entity then
        return
    end

    entity:Destruct()
end

return NewWorld