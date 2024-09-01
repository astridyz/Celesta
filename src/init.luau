local Reactive = require(script.Reactive)

local Types = require(script.Types)

export type World = Types.World
export type Entity = Types.Entity
export type Trait = Types.Trait
export type Query<Q...> = Types.Query<Q...>

export type Component<D> = Types.Component<D>
export type ComponentData<D> = Types.ComponentData<D>

export type Value<D> = Types.Value<D>
export type Scoped<D> = Types.Scoped<D>
export type Computed<D> = Types.Computed<D>

return {
    World = require(script.World),
    Trait = require(script.Trait),
    Query = require(script.Query),
    Component = require(script.Component).New,

    Value = Reactive.Value,
    Computed = Reactive.Computed,
    Scoped = Reactive.Scoped,

    Clean = Reactive.Clean,
    Destruct = Reactive.Destruct,
    
    JoinData = require(script.Utils.JoinData),
}