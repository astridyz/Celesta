--!nolint
--!strict
local Trait = require(script.Parent.Trait)
local AssertValidTrait = Trait.AssertTrait

local Entity = require(script.Parent.Entity)

local Types = require(script.Parent.Types)
type World = Types.World
type Self = World

type Entity = Types.Entity

type Trait = Types.Trait
type Archetype = Types.Archetype

export type ID = number

local World = {}
World.__index = World

local function NewWorld(): Types.World

    return setmetatable({

        _traitMap = {},
        _traitArchetypes = {},
        _archetypeIndex = {},
        _nextId = 1,
        _componentsIndex = {},
        _storage = {}

    }, World) :: any
end

local function ArchetypeHash(types: { ID }): Types.Hash
    table.sort(types)

    return table.concat(types, '_')
end

local function ArchetypeCreate(
    world: World,
    types: { ID }
): Archetype

    local hash = ArchetypeHash(types)
    local archetype = world._archetypeIndex[hash]

    if archetype then
        return archetype
    end

    local archetype = {
        traits = {},
        records = {},
        hash = hash
    }

    world._archetypeIndex[hash] = archetype

    return archetype
end

local function ArchetypeTraitTransition(
    world: World,
    trait: Trait
)

    local components = trait._query._all

    local length = #components

    if length == 0 then
        error('Invalid trait query: must have at least 1 component')    
    end

    local types = table.create(length)

    for i = 1, length do
        
        local component = components[i]
        local id = component._id

        table.insert(types, id)
    end

    local oldArchetype = world._traitArchetypes[trait]
    local newArchetype = ArchetypeCreate(world, types)

    if oldArchetype and oldArchetype ~= newArchetype then

        local traitIndex = table.find(oldArchetype.traits, trait)

        if not traitIndex then
            error('Invalid archetype generation')
        end

        table.remove(oldArchetype.traits, traitIndex)
    end

    local componentsIndex = world._componentsIndex

    for _, id in ipairs(types) do

        if not componentsIndex[id] then
            componentsIndex[id] = {}
        end

        table.insert(componentsIndex[id], newArchetype.hash)
    end

    table.insert(newArchetype.traits, trait)
end

local function GetRelevantTraitsFromArchetype(
    world: World,
    types: { ID }
): { Trait }?
    
    local relevantTraits = {}

    for _, id in ipairs(types) do
        
        local map = world._componentsIndex[id]

        if not map then
            return
        end

        for _, hash in ipairs(map) do
        
            local compatibleArchetype = world._archetypeIndex[hash]
    
            if #compatibleArchetype.traits == 0 then
                continue
            end
    
            for _, trait in ipairs(compatibleArchetype.traits) do
                table.insert(relevantTraits, trait)
            end
        end
    end

    return relevantTraits
end

local function filterRowTraits(
    row: {[Trait]: boolean},
    traits: { Trait }
): { Trait }

    local filtered = {}
    
    for _, trait in ipairs(traits) do
        if not row[trait] then
            continue
        end

        table.insert(filtered, trait)
    end

    return filtered
end

local function attachTraitRow(
    world: World,
    entity: Entity,
    row: {[Trait]: boolean},
    traits: { Trait }
)

    local columnFilter = filterRowTraits(row, traits)

    for _, trait in ipairs(columnFilter) do

        local query = trait._query
        local storage = entity._storage

        if query:Match(entity._id, storage) then
    
            if trait:isApplied(entity) then
                continue
            end

            trait:Apply(entity, world,
                entity:Get(table.unpack(query._need)))

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

    local relevant = GetRelevantTraitsFromArchetype(self, modified)
    if not relevant then return end

    for _, row in pairs(self._traitMap) do
        attachTraitRow(self, entity, row, relevant)
    end
end

function World.Import(self: Self, ...: Trait)
    local traits = self._traitMap

    for index, trait in { ... } do
        
        AssertValidTrait(trait, index)

        local priority = trait._priority

        if not traits[priority] then
            traits[priority] = {}
        end

        traits[priority][trait] = true

        ArchetypeTraitTransition(self, trait)
    end
end

function World.Entity(
    self: Self,
    ...: Types.ComponentData<unknown>
)

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