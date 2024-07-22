--// Packages
local Clean = require(script.Parent.Reactive.Clean)
local JoinData = require(script.Parent.Utils.JoinData)

local Scoped = require(script.Parent.Reactive.Scoped)
local Value = require(script.Parent.Reactive.Value)
local Computed = require(script.Parent.Reactive.Computed)

local Types = require(script.Parent.Types)

local COMPONENT_MARKER = {}
local ID = 0

local GlobalDataMethods = {
    Value = Value,
    Computed = Computed,
    Clean = Clean
}

local function Component<data>(default: data?): Types.Component<data>

    local name = debug.info(1, 's') .. debug.info(1, 'l')

    assert(
        default == nil or typeof(default) == 'table',
        'Default data needs to be a table.'
    )

    ID += 1
    local Component = {
        _name = name,
        _id  =  ID
    }

    function Component.New(mergeData)

        local data = Scoped(
            GlobalDataMethods,
            Component
        )

        mergeData = mergeData or {}

        if default then
            JoinData(default, mergeData)
        end

        for index, value in mergeData do
            data[index] = data:Value(value)
        end

        return data
    end

    local Meta = {}
    
    function Meta:__call(data)
        return Component.New(data)
    end

    Component[COMPONENT_MARKER] = true
    setmetatable(Component, Meta)

    return Component
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
    New = Component,
    AssertComponent = AssertComponent,
    AssertComponentData = AssertComponentData
}