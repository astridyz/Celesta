--!strict
--// Typing
local Types = require(script.Types)

export type World = Types.World
export type Entity = Types.Entity
export type Trait = Types.Trait
export type Query<Q...> = Types.Query<Q...>

export type Scenario = Types.Scenario
export type ScenarioMatch = Types.ScenarioMatch

export type Component<D> = Types.Component<D>
export type ComponentData<D> = Types.ComponentData<D>

export type Value<D> = Types.Value<D>
export type Scoped<D> = Types.Scoped<D>
export type Computed<D> = Types.Computed<D>

--// Init
return {
    World = require(script.World),
    Trait = require(script.Trait).New,
    Query = require(script.Query),
    Component = require(script.Component).New,
    Scenario = require(script.Scenario).New,

    Value = require(script.Reactive.Value),
    Computed = require(script.Reactive.Computed),
    Scoped = require(script.Reactive.Scoped),

    Clean = require(script.Reactive.Clean),
    Destruct = require(script.Reactive.Destruct),
    
    JoinData = require(script.Utils.JoinData),
}