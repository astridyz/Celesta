--!strict
export type Dict<I, V> = {[I]: V}
export type Array<V> = {[number]: V}
export type DeepArray<V> = {[unknown]: V | DeepArray<V>}

type Dependency = State & {Update: (...any) -> ...any}

export type State = {
    _dependencySet: Dict<Dependency | (...any) -> ...any, boolean>,

    Destruct: (self: State) -> ()
}

export type Scoped<D> = Array<unknown> & D

export type ScopedConstructor = (() -> Scoped<{}>)
& (<A>(A & {}) -> Scoped<A>)
& (<A, B>(A & {}, B & {}) -> Scoped<A & B>)
& (<A, B, C>(A & {}, B & {}, C & {}) -> Scoped<A & B & C>)
& (<A, B, C, D>(A & {}, B & {}, C & {}, D & {}) -> Scoped<A & B & C & D>)
& (<A, B, C, D, E>(A & {}, B & {}, C & {}, D & {}, E & {}) -> Scoped<A & B & C & D & E>)
& (<A, B, C, D, E, F>(A & {}, B & {}, C & {}, D & {}, E & {}, F & {}) -> Scoped<A & B & C & D & E & F>)

export type Value<D> = State & {
    _current: any,

    Get: (self: Value<D>) -> D?,
    Set: (self: Value<D>, data: any, force: boolean?) -> (),
}

export type UseFunction<D> = (use: <VD>(value: Value<VD>) -> VD?) -> D

export type Computed<D> = State & {
    _scope: Scoped<any>,
    _processor: UseFunction<unknown>,
    _current: any,

    Get: (self: Computed<D>) -> D,
    Update: (self: Computed<D>) -> ()
}

export type Cleaning = Instance
    | RBXScriptConnection
    | (...any) -> ...any
    | {destroy: (unknown) -> ()}
    | {Destroy: (unknown) -> ()}
    | {Destruct: (unknown) -> ()}
    | {Cleaning}
    | Array<unknown>
    | Dict<unknown, unknown>

export type Merging = Dict<string, unknown>

export type Component<D> = typeof(setmetatable(
    {} :: {
        _id: number,
        _default: Merging?,

        New: (self: Component<D>, data: Merging?) -> D,
    },
    {} :: {
        __call: (self: Component<D>, data: Merging?) -> D
    }
))

export type ComponentData<D> = Scoped<D & typeof(setmetatable(
    {} :: {
        _name: string,
        _id: number,

        Value: <data>(scope: Dict<unknown, unknown>, initialData: data?) -> Value<data>,
        Computed: <data>(scope: Dict<unknown, unknown>, result: (use: <VD>(value: Value<VD>) -> VD) -> D) -> Computed<D>,
        Clean: (scope: Dict<unknown, unknown>) -> (),
    }, {} :: {
        _id: number
    }
))>

export type Query<Q...> = {
    _no: Array<Component<unknown>>,
    _need: Array<Component<unknown>>,

    No: (self: Query<Q...>, ...Component<unknown>) -> Query<Q...>,
    Match: (self: Query<Q...>, entityID: number, storage: Dict<number, ComponentData<unknown>>) -> boolean,

    --// This property doesnt really exist,
    --// it just holds the typepack
    _: (Q...) -> ()
}

export type QueryConstructor = (<D>(component: Component<D>) -> Query<ComponentData<D>>)
& (<D, D1>(component: Component<D>, component2: Component<D1>) -> Query<ComponentData<D>, ComponentData<D1>>)
& (<D, D1, D2>(component: Component<D>, component2: Component<D1>, component3: Component<D2>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>>)
& (<D, D1, D2, D3>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>>)
& (<D, D1, D2, D3, D4>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>>)
& (<D, D1, D2, D3, D4, D5>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>, component6: Component<D5>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>>)
& (<D, D1, D2, D3, D4, D5, D6>(component: Component<D>, component2: Component<D1>, component3: Component<D2>, component4: Component<D3>, component5: Component<D4>, component6: Component<D5>, component7: Component<D6>) -> Query<ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>, ComponentData<D6>>)

export type Trait = typeof(setmetatable({}, {})) & {
    _entityMap: Dict<number, Scoped<any>>,
    _query: Query<unknown>,
    _processor: (...any) -> (),
    _priority: number,
    
    Apply: (self: Trait, entity: Entity, world: World, ...ComponentData<unknown>) -> (),
    Remove: (self: Trait, entity: Entity) -> (),
    isApplied: (self: Trait, entity: Entity) -> boolean
}

export type Entity = {
    _id: number,
    _world: World,
    _storage: Dict<number, ComponentData<unknown>>,

    Get: EntityGet,
    Add: (self: Entity, ...ComponentData<unknown>) -> (),
    Remove: (self: Entity, ...Component<unknown>) -> (),
    Clear: (self: Entity) -> (),
    Destruct: (self: Entity) -> ()
}

export type EntityGet = (<D>(self: Entity, component: Component<D>) -> ComponentData<D>)
& (<D, D1>(self: Entity, component: Component<D>, component1: Component<D1>) -> (ComponentData<D>, ComponentData<D1>))
& (<D, D1, D2>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>))
& (<D, D1, D2, D3>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>))
& (<D, D1, D2, D3, D4>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>, component4: Component<D4>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>))
& (<D, D1, D2, D3, D4, D5>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>, component4: Component<D4>, component5: Component<D5>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>))
& (<D, D1, D2, D3, D4, D5, D6>(self: Entity, component: Component<D>, component1: Component<D1>, component2: Component<D2>, component3: Component<D3>, component4: Component<D4>, component5: Component<D5>, component6: Component<D6>) -> (ComponentData<D>, ComponentData<D1>, ComponentData<D2>, ComponentData<D3>, ComponentData<D4>, ComponentData<D5>, ComponentData<D6>))

export type World = {

    _nextId: number,
    _storage: Dict<number, Entity>,
    _componentsMap: Dict<number, Array<Trait>>,
    _traitMap: Dict<number, Dict<Trait, boolean>>,

    _applyTraits: (self: World, entity: Entity, modified: Array<number>) -> (),

    Import: (self: World, ...Trait) -> (),
    Entity: (self: World, ...ComponentData<unknown>) -> Entity,
    Get: (self: World, ID: number) -> Entity?,
    Despawn: (self: World, ID: number) -> (),
}

return 0