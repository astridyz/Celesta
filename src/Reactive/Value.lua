--!strict
--// Packages
local Destruct = require(script.Parent.Destruct)
local UpdateAll = require(script.Parent.UpdateAll)

local Types = require(script.Parent.Parent.Types)
type Value<D> = Types.Value<D>
type Self = Value<unknown>
type Dict<I, V> = Types.Dict<I, V>

local Value = {}
Value.__index = Value

local function NewValue<D>(scope: Dict<unknown, unknown>, initialData: D?): Value<D>

    local self = (setmetatable({

        _current = initialData,
        _dependencySet = {},
        Destruct = Destruct

    }, Value) :: any) :: Value<D>

    table.insert(scope :: {}, self.Destruct)

    return self
end

function Value.Set(self: Self, data: any, force: boolean?)
    local current = self._current

    if data == current and not force then
        return
    end

    self._current = data
    UpdateAll(self)
end

function Value.Get(self: Self)
    return self._current
end

return NewValue