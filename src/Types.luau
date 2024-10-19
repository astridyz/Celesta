--!strict
export type State<value = unknown> = UserState & {
    _value: value,
    _scope: Scoped,

    Get: (self: State<value>) -> value,
}

export type dependencySet<state> =  {[state]: (self: any) -> boolean}
    
export type UserState = {
    _dependencySet: dependencySet<UserState>,
    _updated: boolean,
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
    _listening: { [State]: dependencySet<UserState> },

    Destruct: (self: Computed<value>) -> ()
}

export type UseFunction<engaged> = (state: UsedAs<engaged>) -> engaged
export type UsedAs<engaged> = State<engaged> | engaged

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
export type ID = number

export type Component<default = {}> = typeof(setmetatable(
    {} :: {
        _id: ID,
        _default: Merging?,

        New: (self: Component<default>, data: Merging?) -> default,
    },
    {} :: {
        __call: (self: Component<default>, data: Merging?) -> default
    }
))

export type ComponentData<data> = Scoped<data & {
    _name: string,
    _id: ID,

    Value: <value>(scope: Scoped, initialData: value?) -> Value<value>,
    Computed: <value>(scope: Scoped, processor: UseFunction<value>) -> Computed<value>,
    Clean: (scope: Scoped) -> (),
}>

export type Query<querying...> = {
    _no: { Component<unknown> },
    _need: { Component<unknown> },
    _all : { Component<unknown> },

    No: (self: Query<querying...>, ...Component<unknown>) -> Query<querying...>,
    Match: (self: Query<querying...>, entityID: ID, storage: {[number]: ComponentData<unknown>}) -> boolean,

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
}

export type Entity = {
    _id: ID,
    _world: World,
    _storage: {[number]: ComponentData<unknown>},

    Get: EntityGet,
    Add: (self: Entity, ...ComponentData<unknown>) -> (),
    Remove: (self: Entity, ...Component<unknown>) -> (),
    Clear: (self: Entity) -> (),
    Destruct: (self: Entity) -> ()
}

export type Archetype = {
    traits: { Trait },
    typeSet: {[number]: boolean},
    hash: Hash
}

export type Hash = string

export type World = {
    _traitMap: {[number]: {[Trait]: boolean}},
    _traitArchetypes: {[Trait]: Archetype},
    _archetypeIndex: {[string]: Archetype},
    _nextId: number,
    _componentsIndex: {[number]: { string }},
    _storage: {[number]: Entity},

    _applyTraits: (self: World, entity: Entity, modified: { number }) -> (),

    Import: (self: World, ...Trait) -> (),
    Entity: (self: World, ...ComponentData<unknown>) -> Entity,
    Get: (self: World, ID: number) -> Entity,
    Contains: (self: World, ID: number) -> boolean,
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

return 0;