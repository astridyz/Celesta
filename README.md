# Celesta
A new theoretical pattern applied in a library.

## Info
Celesta applies *entities*, *traits* and *components* to create a world.

It also has React-style classes designed for optimizations and adaptation to the world.

## Usage
Creating components and scheduling traits

```lua
local World = Celesta.World()

local Component = Celesta.Component()

local Trait = Celesta.Trait({Component}, function(world, entity, scope)

    print('Trait applied to:', entity)

end)

World.scheduleTraits({Trait})
```

Spawn entities with sets of components

```lua
world:spawn(
    Component()
)
--> Trait applied to: 1
```