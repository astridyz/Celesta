---
tags:
    - Theory
---

Queries are the backbone of efficient entity management in libraries like Celesta. They enable you to sift through a vast pool of entities and get exactly those that match specific criteria.

### Why Queries Matter

Instead of processing systems in every entity, queries let you target those that matter — whether they possess certain components, or meet specific conditions.

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Health = Celesta.Component()

local Query = Celesta.Query(Health)
```

In this example, the query requires entities to have the ``Health`` component. We can take this further by adding specific conditions:

```lua
local Celesta = require(game.ReplicatedStorage.Celesta)

local Health = Celesta.Component()
local Immortal = Celesta.Component()

local Query = Celesta.Query(Health):No(Immortal)
```

This query selects entities with the ``Health`` component, but excludes those that also have the ``Immortal`` component.