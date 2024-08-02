--!strict
--// Packages
local Trait = require(script.Parent.Trait)
local AssertTrait = Trait.AssertTrait

local Entity = require(script.Parent.Entity)

local Types = require(script.Parent.Types)
type World = Types.World
type Entity = Types.Entity

type Trait = Types.Trait

type ComponentData<D> = Types.ComponentData<D>

type Dict<I, V> = Types.Dict<I, V>
type Array<V> = Types.Array<V>

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
    local entity = Entity(self)
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