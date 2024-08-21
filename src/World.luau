--!strict
local Trait = require(script.Parent.Trait)
local AssertTrait = Trait.AssertTrait

local Entity = require(script.Parent.Entity)

local Types = require(script.Parent.Types)
type World = Types.World
type Self = World

type Entity = Types.Entity

type Trait = Types.Trait
type ComponentData<D> = Types.ComponentData<D>

local World = {}
World.__index = World

local function NewWorld(): World

    return setmetatable({

        _storage = {},
        _componentsMap = {},
        _traitMap = {},
        _nextId = 1,

    }, World) :: any
end

local function getRelevantTraits(
    world: World,
    entity: Entity,
    modified: { number }
): { Trait }

    local relevant = {}

    for _, id in ipairs(modified) do
        
        local componentTraits = world._componentsMap[id]

        for _, trait in ipairs(componentTraits) do
            table.insert(relevant, trait)
        end
    end

    return relevant
end

local function filterColumnTraits(
    column: {[Trait]: boolean},
    traits: { Trait }
): { Trait }
    local filtered = {}
    
    for _, trait in ipairs(traits) do
        if not column[trait] then
            continue
        end

        table.insert(filtered, trait)
    end

    return filtered
end

local function attachTraitColumn(
    world: World,
    entity: Entity,
    column: {[Trait]: boolean},
    traits: { Trait }
)

    local columnFilter = filterColumnTraits(column, traits)

    for _, trait in ipairs(columnFilter) do

        local query = trait._query
        local storage = entity._storage

        if query:Match(entity._id, storage) then
    
            if trait:isApplied(entity) then
                continue
            end

            trait:Apply(entity, world, entity:Get(table.unpack(query._need)))
    
        elseif trait:isApplied(entity) then
            trait:Remove(entity)

        end
    end
end

function World._applyTraits(
    self: Self,
    entity: Entity,
    modified: { number }
)

    local relevant = getRelevantTraits(self, entity, modified)

    for _, column in pairs(self._traitMap) do
        attachTraitColumn(self, entity, column, relevant)
    end
end

local function IndexComponentsByTrait(world: World, trait: Trait)
    local componentsMap = world._componentsMap

    for _, component in ipairs(trait._query._need) do
    
        local id = component._id

        if not componentsMap[id] then
            componentsMap[id] = {}
        end

        table.insert(componentsMap[id], trait)
    end
end

function World.Import(self: Self, ...: Trait)
    for index, trait in { ... } do
        
        AssertTrait(trait, index)

        local priority = trait._priority
        local traits = self._traitMap

        if not traits[priority] then
            traits[priority] = {}
        end

        traits[priority][trait] = true

        IndexComponentsByTrait(self, trait)
    end
end

function World.Entity(self: Self, ...: ComponentData<unknown>): Entity
    local entity = Entity(self)
    self._storage[entity._id] = entity

    entity:Add(...)

    return entity
end

function World.Get(self: Self, ID: number): Entity?
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