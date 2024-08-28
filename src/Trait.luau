--!strict
local Clean = require(script.Parent.Reactive.Clean)
local Scoped = require(script.Parent.Reactive.Scoped)

local Types = require(script.Parent.Types)
type Trait = Types.Trait
type World = Types.World

type Entity = Types.Entity

type ComponentData<D> = Types.ComponentData<D>
type Scoped<D> = Types.Scoped<D>

local Trait = {}
Trait.__index = Trait

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
    self: Trait,
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

function Trait.Remove(self: Trait, entity: Entity)
    local id = entity._id
    local scope = self._entityMap[id]

    Clean(scope :: any)

    self._entityMap[id] = nil
end

function Trait.isApplied(self: Trait, entity: Entity)
    return self._entityMap[entity._id] ~= nil
end

return NewTrait