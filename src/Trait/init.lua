--!strict
--// Packages
local ExchangeDependencyAll = require(script.Parent.ExchangeAll)

local ClearStateObject = require(script.Parent.Clear)
local Cleanup = require(script.Parent.Cleanup)

local Scoped = require(script.Parent.State.Scoped)

local Types = require(script.Parent.Types)
type Component = Types.Component
type Entity = Types.Entity
type Scoped<O, D> = Types.Scoped<O, D>
type Intersection<R...> = Types.Intersection<R...>

--// function forAll<Req...>(requirements: intersection<Req...>, init: (world, entity, scopeReq...) -> ()): trait
local function Trait<Req...>(
    requirements: Intersection<Req...>,
    initter: (entity: Entity, world: Types.World, scope: Scoped<unknown, any>, Req...) -> ()
): Types.Trait

    debug.profilebegin('new trait')

    local reqComponents = requirements :: any

    local Trait = {
        Kind = 'Trait' :: 'Trait',
        _dependents = {},
        _dependencies = {},
        _applied = {},
        _requirements = reqComponents
    }

    ExchangeDependencyAll(Trait, reqComponents)

    function Trait.Apply(entity, world)
        local entityScope = Scoped()

        local thread = task.spawn(initter, entity, world, entityScope)

        entityScope:Insert(thread)

        Trait._applied[entity] = entityScope
    end

    function Trait.Remove(entity)
        local entityScope = Trait._applied[entity]

        Cleanup(entityScope)
    end

    function Trait.IsApplied(entity)
        return Trait._applied[entity] and true or false
    end

    function Trait.Destruct()

        for entity in Trait._applied do
            Trait.Remove(entity :: Entity)
        end

        ClearStateObject(Trait)

        table.clear(Trait)
    end

    debug.profileend()

    return Trait
end

return Trait