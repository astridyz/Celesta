--!strict
export type Data = {[string]: any}

export type State = {
    _dependencies: {[any]: boolean},
    _dependents: {[{destroy: <S>(self: S) -> ()}]: boolean},
    Destruct: () -> ()
}

export type useFunction = <data>(addValue: {get: () -> data}) -> data

export type Value<O, D = any> = State & {
    Kind: 'Value',
    set: (self: O, data: any, force: boolean?) -> (),
    get: (self: O) -> D,
}

export type Scoped<O, D> = State & D & {State} & {
    Kind: 'Scoped',
    Computed: (self: O, value: Value<unknown, unknown>, result: (use: useFunction) -> ...any) -> Computed,
    Value: <data>(self: O, initialData: data) -> Value<unknown, data>,
    Insert: (...any) -> ()
}

export type Computed = State & {
    Kind: 'Computed',
    Update: () -> ()
}

export type World = {
    Kind: 'World',
    _entities: {[ID]: Entity},
    _traits: {[{Component}]: Trait},
    Size: number,
    Get: (entityID: ID) -> Entity?,
    ScheduleTrait: (...Trait) -> (),

    Entity: ((identifier: Instance, ...Component) -> Entity)
    & ((...Component) -> Entity),

    Despawn: (entityID: ID) -> ()
}

export type Requisite<D> = {
    Instantiate: () -> D
}

export type Intersection<Reqs...> = (Reqs...) -> ()

export type Trait = State & {
    Kind: 'Trait',
    _applied: {[Entity]: Scoped<unknown, unknown>},
    _requirements: {Component},
    Apply: (entity: Entity, world: World) -> (),
    Remove: (entity: Entity) -> (),
    IsApplied: (entity: Entity) -> boolean
}

export type ID = number | Instance

export type Entity = State & {
    Kind: 'Entity',
    _id: ID,
    _storage: {[string]: Datatype},
    Add: (datatype: Datatype) -> Entity,
    Remove: (component: Component) -> Entity,
    ChildOf: (targetEntity: Entity) -> Entity,
    Get: EntityGet,
    Has: (...Component) -> boolean,
    Clear: () -> (),
    Destruct: () -> ()
}

export type EntityGet = ((component: Component) -> Datatype)
& ((component1: Component, component2: Component) -> (Datatype, Datatype))
& ((component1: Component, component2: Component, component3: Component) -> (Datatype, Datatype, Datatype))
& ((component1: Component, component2: Component, component3: Component, component4: Component) -> (Datatype, Datatype, Datatype, Datatype))
& ((component1: Component, component2: Component, component3: Component, component4: Component, component5: Component) -> (Datatype, Datatype, Datatype, Datatype, Datatype))

export type Component = State & typeof(setmetatable(
    {} :: {
        Instantiate: (defaultData: Data?) -> Datatype,
        Name: string,
        Kind: 'Component',
    },
    {} :: {
        __call: (self: unknown, defaultData: Data?) -> Datatype
    }
))

export type Datatype = Scoped<unknown, {
    _name: string,
    [string]: Value<unknown, unknown>
}>

return 0 