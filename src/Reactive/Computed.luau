--!strict
local Destruct = require(script.Parent.Destruct)
local UpdateAll = require(script.Parent.UpdateAll)

local Types = require(script.Parent.Parent.Types)
type Self<value> = Types.Computed<value>

local Computed = {}
Computed.__index = Computed

local function NewComputed<value>(
    scope: Types.Scoped,
    processor: Types.UseFunction<value>
): Types.Computed<value>
    
    local self = setmetatable({
        _scope = scope,
        _processor = processor,
        _dependencySet = {},
        _value = nil,
        Destruct = Destruct

    }, Computed) :: any

    self:Update()

    return self
end

function Computed.Update<value>(self: Self<value>): boolean

    local function Use<engaged>(state: Types.UsedAs<engaged>): engaged
        
        if typeof(state) ~= 'table' then
            return state
        end

        if state._scope == nil then
            error('Invalid state: Dead state added')
        end

        state._dependencySet[self] = true

        return state:Get()
    end

    local success, newValue = pcall(self._processor, Use)

    if not success then
        self:Destruct()

        return false
    end

    if self._value == newValue then
        return false
    end

    self._value = newValue :: any
    UpdateAll(self)
    
    return true
end

function Computed.Get<value>(self: Self<value>): value
    return self._value
end

return NewComputed