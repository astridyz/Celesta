--!strict
--// Packages
local Destruct = require(script.Parent.Destruct)

local Types = require(script.Parent.Parent.Types)
type Computed<D> = Types.Computed<D>
type Self = Computed<unknown>

type Value<D> = Types.Value<D>

type Dict<I, V> = Types.Dict<I, V>

local Computed = {}
Computed.__index = Computed

local function NewComputed<D>(scope: Dict<unknown, unknown>, processor: Types.UseFunction<D>): Computed<D>
    
    local self = (setmetatable({

        _scope = scope,
        _processor = processor,
        _current = nil,
        Destruct = Destruct

    }, Computed) :: any) :: Computed<D>

    table.insert(scope :: {}, self.Destruct)

    self:Update()

    return self
end

function Computed.Update(self: Self)
    
    local function Use<D>(value: Value<D>): D
        value._dependencySet[self] = true

        return value:Get() :: D
    end

    self._current = self._processor(Use)
end

function Computed.Get(self: Self)
    return self._current
end

return NewComputed