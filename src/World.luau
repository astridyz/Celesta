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

local function IsTypeSubset(
    typeSet: { [ID]: boolean },
    smallTypes : { [ID]: boolean }
): boolean

    for t in pairs(smallTypes) do
        if not typeSet[t] then
            return false
        end
    end

    return true
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

    local newArchetype = {
        traits = {},
        typeSet = {},
        hash = hash
    }

    world._archetypeIndex[hash] = newArchetype

    return newArchetype
end

local function ArchetypeMerge(
    baseArchetype: Archetype,
    additionalArchetypes: { Archetype }
)

    local requiredTypes = baseArchetype.typeSet

    for _, archetype in ipairs(additionalArchetypes) do
        for _, trait in ipairs(archetype.traits) do

            if table.find(baseArchetype.traits, trait) then
                continue
            end

            local skip = false

            for id in pairs(archetype.typeSet) do
                
                if not requiredTypes[id] then
                    skip = true
                    break
                end
            end

            if skip then
                continue
            end

            table.insert(baseArchetype.traits, trait)
        end

    end
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

    local types = {}

    for _, component in ipairs(components) do
        table.insert(types, component._id)
    end

    local componentsIndex = world._componentsIndex
    local newArchetype = ArchetypeCreate(world, types)

    for _, id in ipairs(types) do

        if not componentsIndex[id] then
            componentsIndex[id] = {}
        end

        local archetypes = componentsIndex[id]

        if not table.find(archetypes, newArchetype.hash) then
            table.insert(archetypes, newArchetype.hash)
        end

        newArchetype.typeSet[id] = true
    end

    if table.find(newArchetype.traits, trait) then
        error('Duplicated trait in archetype: ' .. newArchetype.hash)
    end

    table.insert(newArchetype.traits, trait)

    for _, updateArchetype in pairs(world._archetypeIndex) do
        if IsTypeSubset(updateArchetype.typeSet, newArchetype.typeSet) then
            ArchetypeMerge(updateArchetype, { newArchetype })
        end
    end

    world._traitArchetypes[trait] = newArchetype
end

local function GetRelevantTraitsFromArchetype(
    world: World,
    types: { ID }
): { [Trait]: boolean }?
    
    local relevantTraits = {}
    local firstMap;

    for _, id in ipairs(types) do
        
        local map = world._componentsIndex[id]

        if not map then
            return
        end

        if firstMap == nil or #firstMap < #map then
            firstMap = map
        end
    end

    for _, hash in ipairs(firstMap) do
        
        local compatibleArchetype = world._archetypeIndex[hash]

        if #compatibleArchetype.traits == 0 then
            continue
        end

        for _, trait in ipairs(compatibleArchetype.traits) do
            relevantTraits[trait] = true
        end
    end

    return relevantTraits
end

local function filterRowTraits(
    row: {[Trait]: boolean},
    traitSet: { [Trait]: boolean }
): { Trait }

    local filtered = {}
    
    for trait in pairs(traitSet) do
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
    traitSet: { [Trait]: boolean }
)

    local columnFilter = filterRowTraits(row, traitSet)

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