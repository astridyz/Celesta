# Celesta
A new theoretical pattern applied in a library.

## Info
Celesta applies *entities*, *traits* and *components* to create a world.

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

local Query = Celesta.Query(Health, Regeneration)

local Trait = Celesta.Trait(Query, function(entity, world, scope, health, regeneration)

    print('Regenerating', entity, 'health!')

    local regenerating = task.spawn(function()
        local endTime = os.clock() + regeneration.duration:get()

        while os.clock() < endTime do
            task.wait(1)

            local current = health.current:get()
            local max = health.max:get()
            local regAmount = regeneration.amount:get()

           if current < max then
                local rest = math.min(current + regAmount, max)

                health.current:set(rest)
            end
        end

        --// Removing the component after the determined duration
        entity:Remove(Regeneration)
    end)

        --// In case we remove the trait before the timer ends
    table.insert(scope, function()
        task.cancel(regenerating)

        --// Removing the component in case the trait
        --// was disabled for any other reasons than
        --// removing the regeneration component
        entity:Remove(Regeneration)
    end)

end)


World:Import(Trait)
```

Spawn entities with sets of components

```lua
local entity = World:Entity(
    Health(),
    Regeneration()
)
--> Regenerating entity 1 health!
```