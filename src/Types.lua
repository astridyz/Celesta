--!strict
export type Data = {[string]: any}

export type StateObject = {
    class: string,
    _dependencies: {[any]: boolean},
    _dependents: {[{destroy: <S>(self: S) -> ()}]: boolean},
}

export type useFunction = <data>(addValue: {get: () -> data}) -> data

export type Value<data, O> = StateObject & {
    set: (self: O, data: any, force: boolean?) -> (),
    get: (self: O) -> data,
    destroy: (self: O) -> (),

    Computed: (self: O, result: (use: useFunction) -> ...any) -> Computed<unknown>
}

export type Scoped<O> = {any} & {
    Computed: (self: O, value: Value<unknown, unknown>, result: (use: useFunction) -> ...any) -> Computed<unknown>,
    Value: <data>(self: O, initialData: data) -> Value<data, unknown>
}

export type Computed<O> = StateObject & {
    update: (self: O) -> (),
    destroy: (self: O) -> ()
}

export type Component = typeof(setmetatable(
    {} :: {
        name: string,
        new: (parcialData: Data?) -> ComponentData & Scoped<unknown>
    },
    {} :: {
        __call: (self: unknown, parcialData: Data?) -> ComponentData & Scoped<unknown>
    }
))

export type ComponentData = {
    _name: string,
    [string]: Value<any, unknown>
}

export type Trait = {
    _requirements: {[string]: Component},
    apply: (entity: any, world: any) -> (),
    remove: (entity: unknown) -> (),
    isApplied: (Entity: unknown) -> boolean
}

export type Initter<entity> = (world: World, entity: entity, scope: Scoped<unknown>) -> ()

export type Entity = number | Instance

export type World = {
    size: number,
    scheduleTraits: (traits: {Trait}) -> (),

    get: Get,
    
    spawn: ((...ComponentData) -> Entity)
    & ((identifier: Instance, ...ComponentData) -> Entity),

    despawn: (entity: Entity) -> (),
    insert: (entity: Entity, ...ComponentData) -> ()
}

export type Get = ((entity: Entity, component: Component) -> ComponentData)
& ((entity: Entity, component1: Component, component2: Component) -> (ComponentData, ComponentData))
& ((entity: Entity, component1: Component, component2: Component, component3: Component) -> (ComponentData, ComponentData, ComponentData))
& ((entity: Entity, component1: Component, component2: Component, component3: Component, component4: Component) -> (ComponentData, ComponentData, ComponentData, ComponentData))
& ((entity: Entity, component1: Component, component2: Component, component3: Component, component4: Component, component5: Component) -> (ComponentData, ComponentData, ComponentData, ComponentData, ComponentData))

return {}