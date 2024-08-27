In the context of Celesta and similar frameworks, traits function as specialized systems that encapsulate behavior and logic associated with entities.

### Understanding Traits

Unlike traditional systems that run continuously, traits are invoked under specific conditions, making them efficient and targeted in their operation.

Traits are designed to act upon entities when certain criteria are met. For example, when an entity acquires a new component or its state changes, the relevant traits are automatically triggered.

This approach minimizes unnecessary processing and allows the system to respond dynamically to changes in the game or entities' state.

Traits can be anything. Functions to create an instance, a loop for an AI algorithm or even changing a number.

!!! note "Keep in mind"
    Traits are applied only once. They do not run when a X component changes, but when X component is added or removed from an entity.

If the requirements are no longer meet, they will be removed. When this happen, if the entity meet the requirements again, the trait you be applied once again.

### Trait requirements

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Health = Celesta.Component()
local Query = Celesta.Query(Health)

local Trait = Celesta.Trait(Query, 0, function()
end)
```

Traits need a query structure to be valid. The query condition defines whether or not the trait will be applied to an entity.

### Priority

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Health = Celesta.Component()
local Query = Celesta.Query(Health)

local FirstTrait = Celesta.Trait(Query, 1, function()
    print('Trait applied first!')
end)

local LastTrait = Celesta.Trait(Query, 0, function()
    print('Trait applied last!')
end)
```

!!! tip "Shared queries"
    You can use the same query for multiple traits, allowing you to divide your code in different modules or sections.

The second parameter is the priority. The number ``0`` is the lowest priority, meaning any trait with a priority greater than ``0`` will be processed first. This allows you to control the order in which traits are evaluated, ensuring that critical traits are applied before others.

*Traits priorities increase sequentially*: The higher the number, the later the trait will be processed, except for ``0``, which always has the lowest priority and is processed last.

### Function parameters

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Health = Celesta.Component()
local Query = Celesta.Query(Health)

return Celesta.Trait(Query, 1, function(entity, world, scope, health)
end)
```

!!! note "Modularized code"
    By returning traits in modules, you can easily organize your codebase into different files. From now on, we will use this approach.

When a trait is applied, the trait processor is called with the following parameters:

- ``entity``: The *entity* to which the trait is applied.
- ``world``: The world that the *entity* belongs to.
- ``scope``: The scope of the trait (we’ll cover this in more detail soon).
- ``health``: The entity data from the trait's required components.

These parameters provide the necessary context and data for the trait to function correctly.

### Evaluating Traits

If a trait triggers another trait that yields, the current trait will continue executing. This can lead to errors if the triggered trait has not yet completed its operation.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Baseplate = Celesta.Component()
local Query = Celesta.Query(Baseplate)

return Celesta.Trait(Query, 0, function(entity, world, scope, baseplate)
    --// Imagine that the trait that creates the part yields.
    entity:Add(Part)

    local part = entity:Get(Part)

    --// instance could be nil because the part is not created yet.
    local instance = part.instance:Get()

    doSomethingWithPart(instance) --> ERROR
end)
```

In this example, if the trait that adds a part yields, the current trait may continue executing before the part is fully created. This can result in errors, such as attempting to operate on a part that has not been fully initialized yet.

To prevent this, you should reverse the order of things.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Part = Celesta.Component()
local Query = Celesta.Query(Part)

return Celesta.Trait(Query, 0, function(entity, world, scope, part)
    local instance = Instance.New('Part')

    part.instance:Set(instance)
    entity:Add(Baseplate)
end)
```

Create the part first, and then add the baseplate component.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Baseplate = Celesta.Component()
local Query = Celesta.Query(Part, Baseplate)

return Celesta.Trait(Query, 0, function(entity, world, scope, part)

    --// The part is already created before this trait was applied
    local instance = part.instance:Get()

    doSomethingWithPart(instance)
end)
```

### Trait scope

Traits can be added to or removed from entities, but reverting changes is not done automatically. When removing a trait, you must manually handle the cleanup of any data associated with it.

Using the previous example:

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Part = Celesta.Component()
local Query = Celesta.Query(Part)

return Celesta.Trait(Query, 0, function(entity, world, scope, part)

    local instance = Instance.New('Part')
    
    --// The trait scope is cleaned when removed.
    --// Adding anything to it will be destroyed after its use.
    table.insert(scope, instance)

    part.instance:Set(instance)
end)
```

In this example, any components or data added to the trait’s scope, such as the instance, will be cleaned up when the trait is removed.