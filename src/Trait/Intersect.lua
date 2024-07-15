local Types = require(script.Parent.Parent.Types)
type Intersection<R...> = Types.Intersection<R...>
type Component = Types.Component
type Datatype = Types.Datatype

local Intersect = table.pack

return Intersect
    :: ((component: Component) -> Intersection<Datatype>)
    & ((component: Component, component2: Component) -> Intersection<Datatype, Datatype>)
    & ((component: Component, component2: Component, component3: Component) -> Intersection<Datatype, Datatype, Datatype>)
    & ((component: Component, component2: Component, component3: Component, component4: Component) -> Intersection<Datatype, Datatype, Datatype, Datatype>)
    & ((component: Component, component2: Component, component3: Component, component4: Component, component5: Component) -> Intersection<Datatype, Datatype, Datatype, Datatype, Datatype>)
    & ((component: Component, component2: Component, component3: Component, component4: Component, component5: Component, component6: Component) -> Intersection<Datatype, Datatype, Datatype, Datatype, Datatype, Datatype>)
    & ((component: Component, component2: Component, component3: Component, component4: Component, component5: Component, component6: Component, component7: Component) -> Intersection<Datatype, Datatype, Datatype, Datatype, Datatype, Datatype, Datatype>)