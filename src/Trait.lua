--// Packages
local Clean = require(script.Parent.Reactive.Clean)

local Scoped = require(script.Parent.Reactive.Scoped)

local Types = require(script.Parent.Types)
type Scoped<D> = Types.Scoped<D>

type Entity = Types.Entity
type World = Types.World

type ComponentData<D> = Types.ComponentData<D>

local function Trait<Reqs...>(
    Query: Types.Query<Reqs...>,
    initter: (entity: Entity, world: World, scope: Types.Scoped<unknown>, Reqs...) -> () 
): Types.Trait

    local Trait = {
        Kind = 'Trait',
        _query = Query :: any,
        _entityMap = {}
    }

    function Trait.Apply(entity: Entity, world: World, ...: any)
        local scope = Scoped()

        Trait._entityMap[entity._id] = scope

        local thread = task.spawn(initter, entity, world, scope, ...)
        table.insert(scope, thread)
    end

    function Trait.Remove(entity: Entity)
        local scope = Trait._entityMap[entity._id]

        if not scope then
            error('Trait error: attempt to remove a inexistent scope')
        end

        Clean(scope)

        Trait._entityMap[entity._id] = nil
    end

    function Trait.isApplied(entity: Entity)
        return Trait._entityMap[entity._id] and true or false
    end

    local meta = {}

    function meta:__call(entity: Entity, world: World, ...: any)
        Trait.Apply(entity, world, ...)
    end

    setmetatable(Trait, meta)

    return Trait
end

return Trait