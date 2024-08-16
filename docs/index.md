---
hide:
  - navigation
---

<div class="hero">
    <div class="hero-content">
        <img src="assets/images/Celesta.svg" alt="Celesta Logo" class="logo">
        <h1>Enhance your game with scalable, dynamic code.</h1>
        <a href="Learning/" class="btn-primary">Getting started</a>
    </div>
</div>

## Introduction

Celesta is a library for Entity Component System (ECS) that adopts an event-driven approach to simplify development and reduce the complexity associated with traditional ECS loops.

## Components

Components in Celesta are defined simply and intuitively.
  They are used to store data related to an entity. Here is an example of how to define components for health and regeneration:

```
type Value<D> = Celesta.Value<D>

local Health = Celesta.Component {
    max = 100 :: Value<number>,
    current = 100 :: Value<number>
}

local Regeneration = Celesta.Component {
    duration = 5 :: Value<number>,
    amount = 10 :: Value<number>
}
```

## Query

The Query object is used to combine components that need to be considered in a system. It defines which components are required for a trait to function. Here is an example of defining a query between Health and Regeneration:

```
local Query = Celesta.Query(Health, Regeneration)
```

## Traits
Traits are functions that are executed when entities meet the requirements defined by the Query. They allow you to add custom logic and respond to changes in component states. Here’s an example of a trait that regenerates an entity’s health:

```
local Trait = Celesta.Trait(Query, function(world, entity, scope, health, regeneration)

    local regenerating = task.spawn(function()
    
        local endTime = os.clock() + regeneration.duration:Get()

        while os.clock() < endTime do
            task.wait(1)

            local current = health.current:Get()
            local max = health.max:Get()
            
            --// Add logic for health regeneration here
            
        end

    end)

    --// Will be canceled when the trait is removed
    table.insert(scope, regenerating)

end)
```