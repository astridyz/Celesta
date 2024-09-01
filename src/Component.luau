--!strict
local Celesta = script.Parent
local Reactive = require(Celesta.Reactive)

local Clean = Reactive.Clean
local Scoped = Reactive.Scoped
local Value = Reactive.Value
local Computed = Reactive.Computed
local JoinData = require(Celesta.Utils.JoinData)

local Types = require(Celesta.Types)
type Component<D> = Types.Component<D>
type Merging = Types.Merging

local ID = 0
local COMPONENT_MARKER = {}

local GLOBAL_METHODS = {
    Value = Value,
    Computed = Computed,
    Clean = Clean
}

local Component = {}
Component.__index = Component

local function NewComponent<default>(default: default?): Types.Component<default>
    
    ID += 1
    return setmetatable({

        _id = ID,
        _default = default or {},

        [COMPONENT_MARKER] = true

    }, Component) :: any
end

function Component.New<default>(
    self: Component<default>,
    mergeData: Merging
): default
    
    local data = Scoped(
        GLOBAL_METHODS,
        self
    ) :: any

    mergeData = mergeData or {}
    JoinData(self._default, mergeData)

    for index, value in mergeData do
        data[index] = data:Value(value)
    end

    return data
end

function Component.__call<default>(self: Component<default>, mergeData: Merging): default
    return self:New(mergeData)
end

local function AssertType(object, index: number)
    assert(typeof(object) == 'table', 'Component #' .. index .. ' is invalid: not a table')
end

local function AssertComponent(object, index: number)
    AssertType(object, index)

    assert(object[COMPONENT_MARKER],
        'Component #' .. index .. ' is invalid: has no marker. Possible Component Instance passed instead'
    )
end

local function AssertComponentData(object, index: number)
    AssertType(object, index)

    local metatable = getmetatable(object)

    assert(metatable, 'Component data #' .. index .. ' is invalid: has no metatable')

    assert(metatable[COMPONENT_MARKER],
        'Component #' .. index .. ' is invalid: Possible Component passed instead of a Component Instance'
    )

end

return {
    New = NewComponent,
    AssertComponent = AssertComponent,
    AssertComponentData = AssertComponentData
}