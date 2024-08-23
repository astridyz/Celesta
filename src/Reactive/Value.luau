--!strict
local Destruct = require(script.Parent.Destruct)
local Outdate = require(script.Parent.OutdateAll)
local Update = require(script.Parent.UpdateAll)

local Types = require(script.Parent.Parent.Types)
type Self<value> = Types.Value<value>

local Value = {}
Value.__index = Value

local function NewValue<value>(
    scope: Types.Scoped,
    value: value?
): Types.Value<value>

    return setmetatable({
        
        _value = value,
        _dependencySet = {},
        _scope = scope,
        Destruct = Destruct

    }, Value) :: any
end

function Value.Set<value>(
    self: Self<value>,
    newValue: value,
    force: boolean?
): value?

    local current = self._value

    if newValue == current and not force then
        return
    end

    Outdate(self)
    self._value = newValue
    Update(self)

    return newValue
end

function Value.Get<value>(self: Self<value>): value
    return self._value
end

return NewValue