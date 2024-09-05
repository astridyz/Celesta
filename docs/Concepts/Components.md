---
tags:
    - Theory
---

In Celesta, components are data structures associated with entities. They store the data and states that define an entity's behavior and characteristics.

### What are Components?

Components are simple containers attached to entities. They hold specific pieces of information related to an entity, such as position, health, or custom attributes.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Velocity = Celesta.Component {--// Default data for this component
    current = 16
}
```

Celesta works with reactive data. All data inside components are *values*. *Values* are structures with ``get`` and ``set`` methods.

*Values* allow other structures to work with the changes made to them, ensuring that any modifications are automatically propagated throughout the game.

Due to limitations in Luau, the type-checking is not done automatically, so you must type-cast *values* in the data fields.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)
type Value<D> = Celesta.Value<D>

local Velocity = Celesta.Component {
    current = 16 :: Value<number>
}
```

!!! warning "Luau type-checking"
    Unfortunately, this approach may lead to type-cast errors. As a workaround, you might need to use ``--!nocheck`` at the beginning of the code to bypass these type-checking issues.

Components don't necessarily need a default data; you can later add more fields or simply not use any.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Player = Celesta.Component()
```

Components that don't have any data are called *tags*. *Tags* can be anything; a marker that this entity is a player or even that this entity is a door.

### Integrating components in systems

Components encapsulate specific functionality, making it easy to manage and update parts of the system independently.

They enable efficient data handling and reactive programming, where systems can automatically respond to changes.

```lua
local function exampleTrait(velocity)
    local current = velocity.current

    velocity:Computed(function(use)
        print(use(current))
    end)
end
```

This example demonstrate how a system can wait for a change and executing a function.

!!! abstract "Making it look easy"
    This example introduces a several new concepts. It's recommended that you explore the documentation further to learn all about them.