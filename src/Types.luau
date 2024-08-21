--!strict
export type State<value = unknown> = {
    _value: value,
    _scope: Scoped,
    _dependencySet: {[UpdateState | (...any) -> ...any]: boolean},

    Get: (self: State<value>) -> value,
}

export type UpdateState = {
    _update: (self: UpdateState) -> boolean
}

export type Scoped<D = unknown> = { unknown } & D

export type Value<value> = State<value> & {
    Set: (self: Value<value>, value: any, force: boolean?) -> value?,
    Destruct: (self: Value<value>) -> ()
}

export type Computed<value> = State<value> & UpdateState & {
    _scope: Scoped<any>,
    _processor: UseFunction<unknown>,

    Destruct: (self: Computed<value>) -> ()
}

export type UseFunction<value> = (state: UsedAs<value>) -> value
export type UsedAs<value> = State<value> | value

export type Cleaning = Instance
    | RBXScriptConnection
    | (...any) -> ...any
    | {destroy: (unknown) -> ()}
    | {Destroy: (unknown) -> ()}
    | {Destruct: (unknown) -> ()}
    | { Cleaning }
    | { unknown }
    | {[unknown]: unknown}

export type Merging = {[string]: unknown}

export type Component<default = {}> = {
    _id: number,
    _default: Merging?,

    New: (self: Component<default>, data: Merging?) -> default,

} & typeof(setmetatable(
    {}, {} :: { __call: (self: Component<default>, data: Merging?) -> default}
))

export type ComponentData<data> = Scoped<data & {
    _name: string,
    _id: number,

    Value: <data>(scope: Scoped, initialData: data?) -> Value<data>,
    Computed: <data>(scope: Scoped, result: (use: <VD>(value: Value<VD>) -> VD) -> data) -> Computed<data>,
    Clean: (scope: Scoped) -> (),

} & typeof(setmetatable(
    {}, {} :: {_id: number}
))>

export type Query<querying...> = {
    _no: { Component<unknown> },
    _need: { Component<unknown> } ,

    No: (self: Query<querying...>, ...Component<unknown>) -> Query<querying...>,
    Match: (self: Query<querying...>, entityID: number, storage: {[number]: ComponentData<unknown>}) -> boolean,

    _: (querying...) -> ()
}

export type Trait = {
    _entityMap: {[number]: Scoped<unknown>},
    _query: Query<unknown>,
    _processor: (...any) -> (),
    _priority: number,
    
    Apply: (self: Trait, entity: Entity, world: World, ...ComponentData<unknown>) -> (),
    Remove: (self: Trait, entity: Entity) -> (),
    isApplied: (self: Trait, entity: Entity) -> boolean

} & typeof(setmetatable({}, {}))

export type Entity = {
    _id: number,
    _world: World,
    _storage: {[number]: ComponentData<unknown>},

    Get: EntityGet,
    Add: (self: Entity, ...ComponentData<unknown>) -> (),
    Remove: (self: Entity, ...Component<unknown>) -> (),
    Clear: (self: Entity) -> (),
    Destruct: (self: Entity) -> ()
}

export type World = {

    _nextId: number,
    _storage: {[number]: Entity},
    _componentsMap: {[number]: { Trait }},
    _traitMap: {[number]: {[Trait]: boolean}},

    _applyTraits: (self: World, entity: Entity, modified: { number }) -> (),

    Import: (self: World, ...Trait) -> (),
    Entity: (self: World, ...ComponentData<unknown>) -> Entity,
    Get: (self: World, ID: number) -> Entity?,
    Despawn: (self: World, ID: number) -> (),
}

export type EntityGet = (<D>(self: Entity, component: Component<D>) -> ComponentData<D>)
& (<D, D1>(self: Entity, component: Component<D>, component1: Component<D1>) -> (ComponentData<D>, ComponentData<D1>))
& (<D, D1, D2>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>))
& (<D, D1, D2, D3>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>))
& (<D, D1, D2, D3, D4>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>, component4: Component<D4>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>))
& (<D, D1, D2, D3, D4, D5>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>, component4: Component<D4>, component5: Component<D5>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>))
& (<D, D1, D2, D3, D4, D5, D6>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>, component4: Component<D4>, component5: Component<D5>, component6: Component<D6>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>, ComponentData<D6>))

export type ScopedConstructor = (() -> Scoped<{}>)
& (<A>(A & {}) -> Scoped<A>)
& (<A, B>(A & {}, B & {}) -> Scoped<A & B>)
& (<A, B, C>(A & {}, B & {}, C & {}) -> Scoped<A & B & C>)
& (<A, B, C, D>(A & {}, B & {}, C & {}, D & {}) -> Scoped<A & B & C & D>)
& (<A, B, C, D, E>(A & {}, B & {}, C & {}, D & {}, E & {}) -> Scoped<A & B & C & D & E>)
& (<A, B, C, D, E, F>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scoped<A & B & C & D & E & F>)

export type QueryConstructor = (<D>(component: Component<D>) -> Query<ComponentData<D>>)
& (<D, D1>(component: Component<D>, component2: Component<D1>) -> Query<ComponentData<D>, ComponentData<D1>>)
& (<D, D1, D2>(component: Component<D>, component2: Component<D1>, component3: Component<D2>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>>)
& (<D, D1, D2, D3>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>>)
& (<D, D1, D2, D3, D4>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>>)
& (<D, D1, D2, D3, D4, D5>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>, component6: Component<D5>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>>)
& (<D, D1, D2, D3, D4, D5, D6>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>, component6: Component<D5>, component7: Component<D6>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>, ComponentData<D6>>)

return 0