In Celesta, components are essential data structures associated with entities. They store the various attributes and states that define an entity's behavior and characteristics.

### What are Components?

Components are simple data containers attached to entities. They hold specific pieces of information related to an entity, such as position, health, or custom attributes. Components do not contain logic or behavior; instead, they purely represent data.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Velocity = Celesta.Component {
    --// Default data for this component
    current = 16
}
```

Due to limitations in Luau, the type-checking is not done automatically, so we have to type-cast values in the data fields.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)
type Value<D> = Celesta.Value<D>

local Velocity = Celesta.Component {
    current = 16 :: Value<number>
}
```

!!! warning "Luau type-checking"
    Unfortunately, this approach may lead to type-cast errors. As a workaround, you might need to use ``--!nocheck`` at the beginning of the code to bypass these type-checking issues.

Components don’t necessarily need a default data; you can later add more fields or simply not use any.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Player = Celesta.Component()
```

Components that don't have any data are called *tags*. *Tags* can be anything; a marker that this entity is a player or even that this entity is a door.