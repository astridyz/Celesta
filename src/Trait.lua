--!strict
--// Packages
local Clean = require(script.Parent.Reactive.Clean)

local Scoped = require(script.Parent.Reactive.Scoped)

local Types = require(script.Parent.Types)
type Entity = Types.Entity
type World = Types.World

type Trait = Types.Trait

type ComponentData<D> = Types.ComponentData<D>

type Scoped<D> = Types.Scoped<D>

local TRAIT_MARKER = {}

local Trait = {}
Trait.__index = Trait
Trait[TRAIT_MARKER] = true

function Trait.__call(self: Trait, entity, world, ...)
    return self:Apply(entity, world, ...)
end

local function NewTrait<Reqs...>(Query: Types.Query<Reqs...>, priority: number, initter: (entity: Entity, world: World, Scoped<unknown>, Reqs...) -> () ): Trait

    return setmetatable({

        _query = Query :: any,
        _entityMap = {},
        _initter = initter,
        _priority = priority

    }, Trait) :: any
end

function Trait.Apply(self: Trait, entity: Entity, world: World, ...: any)
    local scope = Scoped()

    self._entityMap[entity._id] = scope

    local thread = task.spawn(self._initter, entity, world, scope, ...)
    table.insert(scope, thread)
end

function Trait.Remove(self: Trait, entity: Entity)
    local scope = self._entityMap[entity._id]
    assert(scope, 'Trait error: attempt to remove a inexistent scope')

    Clean(scope :: any)

    self._entityMap[entity._id] = nil
end

function Trait.isApplied(self: Trait, entity: Entity)
    return self._entityMap[entity._id] and true or false
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