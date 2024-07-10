--!strict
--// Packages
local Transform = require(script.Transform)
local Cleanup = require(script.Parent.Cleanup)

local Scoped = require(script.Parent.State.Scoped)

local Types = require(script.Parent.Types)
type Trait = Types.Trait
type Initter<E> = Types.Initter<E>

type Scoped<O> = Types.Scoped<O>
type Component = Types.Component

local function Trait<entity>(requirements: {[any]: Component}, init: Initter<entity>): Trait

    debug.profilebegin('new trait')

    requirements = typeof(requirements) == 'table' and requirements or {requirements} :: any

    local Class = {
        _requirements = Transform(requirements :: any),
    } :: Trait

    local applied = {}

    function Class.apply(entity, world)
        -- print('Applying trait to:', entity, 'componentSet:', requirements)

        if applied[entity] then
            warn('Trying to apply twitce to the same entity')
            return
        end

        applied[entity] = Scoped()

        table.insert(
            applied[entity],
            task.spawn(init, entity, world, applied[entity]
        ))
    end

    function Class.remove(entity)

        if not applied[entity] then
            warn('Entity does not have this trait.')
            return
        end

        Cleanup(applied[entity])

        applied[entity] = nil
    end

    function Class.isApplied(entity)
        return if applied[entity] then true else false
    end

    debug.profileend()

    return Class
end

return Trait