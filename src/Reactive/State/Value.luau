--!strict
local Package = script.Parent
local Reactive = Package.Parent
local State = require(Package)

local Destruct = require(Reactive.Destruct)
local IsSimilar = require(Reactive.IsSimilar)

local Types = require(Reactive.Parent.Types)
type Value<V> = Types.Value<V>

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
    self: Value<value>,
    newValue: value,
    force: boolean?
): value?

    local current = self._value

    if not force and IsSimilar(newValue, current) then
        return
    end

    State.Outdate(self)
    self._value = newValue

    State.Update(self)
    return newValue
end

function Value.Get<value>(self: Value<value>): value
    return self._value
end

return NewValue