local Types = require(script.Types)

export type World = Types.World
export type Trait = Types.Trait
export type Entity = Types.Entity

export type Component = Types.Component
export type Datatype = Types.Datatype

export type Computed = Types.Computed
export type Scoped<O, D> = Types.Scoped<O, D>
export type Value<O, D> = Types.Value<O, D>

return {
    World = require(script.World),
    Trait = require(script.Trait),
    Component = require(script.Component),

    Intersect = require(script.Trait.Intersect),
    Bundle = require(script.Bundle),

    Computed = require(script.State.Computed),
    Scoped = require(script.State.Scoped),
    Value = require(script.State.Value),

    Cleanup = require(script.Cleanup),
    JoinData = require(script.JoinData),
}