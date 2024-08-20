--!strict
--// Packages
local Trait = require(script.Parent.Trait)
local AssertTrait = Trait.AssertTrait

local Entity = require(script.Parent.Entity)

--// Typing
local Types = require(script.Parent.Types)
type Self = Types.World
type Entity = Types.Entity

type Trait = Types.Trait
type TraitColumn = Types.TraitColumn
type ComponentData<D> = Types.ComponentData<D>

type Dict<I, V> = Types.Dict<I, V>
type Array<V> = Types.Array<V>

--// This
local World = {}
World.__index = World

--// Functions
local function NewWorld(): Types.World

    return setmetatable({

        _storage = {},
        _traits = {},
        _componentsMap = {},
        _nextId = 1,

    }, World) :: any
end

function World._indexTraitsByComponents(self: Self, column: TraitColumn)
    local componentsMap = self._componentsMap

    for trait in pairs(column) do
        for _, component in ipairs(trait._query._need) do

            local id = component._id

            if not componentsMap[id] then
                componentsMap[id] = {}
            end

            table.insert(componentsMap[id], trait)
        end
    end
end

function World._generateComponentsIndex(self: Self)
    for _, column in pairs(self._traits) do
        self:_indexTraitsByComponents(column)
    end
end

function World._getRelevantTraits(self: Self, entity: Entity, column: TraitColumn): TraitColumn
    local relevantComponents = {}

    for id, component in entity._storage do
        
        local componentTraits = self._componentsMap[id]

        for _, trait in ipairs(componentTraits) do

            if not column[trait] then
                continue
            end

            relevantComponents[trait] = true
        end
    end

    return relevantComponents
end

function World._attachTraitColumn(self: Self, entity: Entity, column: TraitColumn)
    
    local relevantTraits = self:_getRelevantTraits(entity, column)

    for trait in pairs(relevantTraits) do
        
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

function World._applyTraits(self: Self, entity: Entity, column: TraitColumn)
    for _, column in pairs(self._traits) do
        self:_attachTraitColumn(entity, column)
    end
end

function World.Import(self: Self, ...: Trait)
    for index, object in { ... } do
        
        AssertTrait(object, index)

        local priority = object._priority
        local traits = self._traits

        if not traits[priority] then
            traits[priority] = {}
        end

        traits[priority][object] = true
    end

    self:_generateComponentsIndex()
end

function World.Entity(self: Self, ...: ComponentData<unknown>)
    local entity = Entity(self)
    self._storage[entity._id] = entity

    entity:Add(...)

    return entity
end

function World.Get(self: Self, ID: number)
    local entity = self._storage[ID]

    if not entity then
        return
    end

    return entity
end

function World.Despawn(self: Self, ID: number)
    local entity = self:Get(ID)

    if not entity then
        return
    end

    entity:Destruct()
end

return NewWorld