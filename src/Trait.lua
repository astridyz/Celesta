--!strict
--// Packages
local Clean = require(script.Parent.Reactive.Clean)

local Scoped = require(script.Parent.Reactive.Scoped)

local Types = require(script.Parent.Types)
type Trait = Types.Trait

type Entity = Types.Entity
type World = Types.World

type ComponentData<D> = Types.ComponentData<D>

type Scoped<D> = Types.Scoped<D>

local Trait = {}
Trait.__index = Trait
Trait.Kind = 'Trait'

function Trait:__call(entity, world, ...)
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

function Trait:Apply(entity: Entity, world: World, ...: any)
    self = self :: Trait

    local scope = Scoped()

    self._entityMap[entity._id] = scope

    local thread = task.spawn(self._initter, entity, world, scope, ...)
    table.insert(scope, thread)
end

function Trait:Remove(entity: Entity)
    self = self :: Trait

    local scope = self._entityMap[entity._id]

    if not scope then
        error('Trait error: attempt to remove a inexistent scope')
    end

    Clean(scope)

    self._entityMap[entity._id] = nil
end

function Trait:isApplied(entity: Entity)
    return self._entityMap[entity._id] and true or false
end

return NewTrait