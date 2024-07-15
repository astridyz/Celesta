# Celesta
A new theoretical pattern applied in a library.

## Info
Celesta applies *entities*, *traits* and *components* to create a world.

It also has React-style classes designed for optimizations and adaptation to the world.

## Usage
Creating components and scheduling traits

```lua
local World = Celesta.World()

local Health = Celesta.Component {
    --// Default data for this component
    max = 100,
    current = 100
}

local Regeneration = Celesta.Component {
    duration = 5,
    amount = 10
}

local Requirements = Celesta.Intersect(Health, Regeneration)

local Trait = Celesta.Trait(Requirements,
    function(entity, world, scope, health, regeneration)

        print('Regenerating entity', entity, 'health!')

        local regenerating = task.spawn(function()
            local endTime = os.clock() + regeneration.duration:get()

            while os.clock() < endTime do
                task.wait(1)

                local current = health.current:get()
                local max = health.max:get()

                if current < max then
                    health.current:set(math.min(current + regeneration.amount:get(), max))
                end
            end

            entity.Remove(Regeneration)
            --// Removing the component after the determined duration
        end)

        --// In case we remove the trait before the timer ends
        scope.Insert(function()
            task.cancel(regenerating)
            
            --// Removing the component
            entity.Remove(Regeneration)
        end)

    end)


World.scheduleTrait(Trait)
```

Spawn entities with sets of components

```lua
local entity = World.Entity(
    Health(),
    Regeneration()
)
--> Regenerating entity 1 health!
```