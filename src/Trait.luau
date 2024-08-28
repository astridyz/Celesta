--!strict
local Clean = require(script.Parent.Reactive.Clean)

local Scoped = require(script.Parent.Reactive.Scoped)

local Types = require(script.Parent.Types)
type Trait = Types.Trait
type Self = Trait

type Entity = Types.Entity
type World = Types.World
type ComponentData<D> = Types.ComponentData<D>

type Scoped<D> = Types.Scoped<D>

local TRAIT_MARKER = {}

local Trait = {}
Trait.__index = Trait
Trait[TRAIT_MARKER] = true

local function NewTrait<Reqs...>(
    Query: Types.Query<Reqs...>,
    priority: number,
    processor: (entity: Entity, world: World, Scoped<unknown>, Reqs...) -> () 
): Trait

    return setmetatable({

        _query = Query :: any,
        _entityMap = {},
        _processor = processor,
        _priority = priority

    }, Trait) :: any
end

function Trait.Apply(
    self: Self,
    entity: Entity,
    world: World,
    ...: ComponentData<unknown>
)

    local entityScope = Scoped()
    local id = entity._id

    self._entityMap[id] = entityScope

    local thread = task.spawn(
        self._processor,
        entity,
        world,
        entityScope,
        ...
    )

    table.insert(entityScope, thread)
end

function Trait.Remove(self: Self, entity: Entity)
    local id = entity._id
    local scope = self._entityMap[id]

    Clean(scope :: any)

    self._entityMap[id] = nil
end

function Trait.isApplied(self: Self, entity: Entity)
    return self._entityMap[entity._id] ~= nil
end

local function AssertTraitType(object, index: number)
    assert(typeof(object) == 'table', 'Trait #' .. index .. ' is invalid: not a table')
end

local function AssertTrait(object, index: number)
    AssertTraitType(object, index)
    
    local meta = getmetatable(object)
    assert(meta, 'Trait #' .. index .. ' is invalid: doesnt have metatable.')

    assert(meta[TRAIT_MARKER], 'Trait #' .. index .. ' is invalid: has no marker.')
end

return {
    New = NewTrait,
    AssertTrait = AssertTrait
}