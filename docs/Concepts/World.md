---
tags:
    - Theory
---

In ECS systems, the "world" is the central context or container that manages all entities, components, and systems (or in Celesta, traits). It acts as the environment where everything in your game or application exists and interacts.

### World as a Middleware

The world is responsible for creating, storing, updating, and destroying entities. Traits are coordinated by the world, ensuring they act on the correct entities and components in the right order.

For example, in a game, the world would manage entities like players, enemies, and objects, handling their components and ensuring that traits operate on them as needed.

### Scheduling Traits

Traits are independent of the world, meaning you can share traits between worlds, clients, servers, and other contexts.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local world = Celesta.World()

local trait = Celesta.Trait(...)
local anotherTrait = Celesta.Trait(...)

world:Import(trait, anotherTrait)
```

The :Import() method adds the trait and its query to the world's storage. Now, any changes in an entity's components can trigger the trait.

!!! tip "Always do this"
    Before creating entities, import all your static traits. If you don't, your game could fail.

### Spawning Entities

To create a new entity, you use the ``:Entity()`` method provided by the World. This method initializes a new entity, which you can then customize by adding components to it.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local world = Celesta.World()

local player = world:Entity()
player:Add(Health())
player:Add(Imortal())
```

In this example, a new entity named player is created, and two components ``Health`` and ``Imortal`` are added to it.

Celesta allows for streamlined syntax when adding components to entities. Any amount of components will be added in a single function call.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local world = Celesta.World()

local player = world:Entity()

player:Add(
    Health(),
    Imortal()
)
```

You can also pass multiple components directly to the ``:Entity()`` method.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local world = Celesta.World()

local player = world:Entity(
    Health(),
    Imortal()
)
```

!!! note 
    Adding components using the :Entity() method is functionally equivalent to creating the entity first and then calling :Add() with the desired components.

Each of these approaches has its use cases, depending on the complexity and requirements of your game.