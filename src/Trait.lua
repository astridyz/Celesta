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

local Trait = {}
Trait.__index = Trait

function Trait.__call(self: Trait, entity, world, ...)
    return self:Apply(entity, world, ...)
end

local function NewTrait<Reqs...>(
    Query: Types.Query<Reqs...>,
    initter: (entity: Entity, world: World, scope: Types.Scoped<unknown>, Reqs...) -> () 
): Types.Trait

    local trait = {
        _query = Query :: any,
        _entityMap = {},
        _initter = initter
    }

    setmetatable(trait, Trait)

    return trait :: any
end

function Trait.Apply(self: Trait, entity: Entity, world: World, ...: any)
    local scope = Scoped()

    self._entityMap[entity._id] = scope

    local thread = task.spawn(self._initter, entity, world, scope, ...)
    table.insert(scope, thread)
end

function Trait.Remove(self: Trait, entity: Entity)
    local scope = self._entityMap[entity._id]

    if not scope then
        error('Trait error: attempt to remove a inexistent scope')
    end

    Clean(scope :: any)

    self._entityMap[entity._id] = nil
end

function Trait.isApplied(self: Trait, entity: Entity)
    return self._entityMap[entity._id] and true or false
end

return NewTrait