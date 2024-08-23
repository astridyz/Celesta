local Clean = require(script.Parent.Reactive.Clean)
local JoinData = require(script.Parent.Utils.JoinData)

local Scoped = require(script.Parent.Reactive.Scoped)
local Value = require(script.Parent.Reactive.Value)
local Computed = require(script.Parent.Reactive.Computed)

local Types = require(script.Parent.Types)
type Self<default> = Types.Component<default>

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
        _default = default,

        [COMPONENT_MARKER] = true

    }, Component) :: any
end

function Component.New<default>(
    self: Self<default>,
    mergeData: Merging
): default
    
    local data = Scoped(
        GLOBAL_METHODS,
        self :: any
    )

    mergeData = mergeData or {}

    local default = self._default

    if default then
        JoinData(default, mergeData)
    end

    for index, value in mergeData do
        data[index] = data:Value(value)
    end

    return data
end

function Component.__call<default>(self: Self<default>, mergeData: Merging): default
    return self:New(mergeData)
end

local function AssertType(object, index)
    assert(typeof(object) == 'table', 'Component #' .. index .. ' is invalid: not a table')
end

local function AssertComponent(object, index)
    AssertType(object, index)

    assert(object[COMPONENT_MARKER],
        'Component #' .. index .. ' is invalid: has no marker. Possible Component Instance passed instead'
    )
end

local function AssertComponentData(object, index)
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