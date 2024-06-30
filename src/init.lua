local Types = require(script.Types)

export type World = Types.World
export type Trait = Types.Trait

export type Component = Types.Component
export type ComponentData = Types.ComponentData

export type Computed<O> = Types.Computed<O>
export type Scoped<O> = Types.Scoped<O>
export type Value<D, O> = Types.Value<D, O>

return {
    World = require(script.World),
    Trait = require(script.Trait),
    Component = require(script.Component),

    Computed = require(script.State.Computed),
    Scoped = require(script.State.Scoped),
    Value = require(script.State.Value),

    Cleanup = require(script.Cleanup),
    JoinData = require(script.JoinData),
}