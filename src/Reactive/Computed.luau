--!strict
local Destruct = require(script.Parent.Destruct)
local OutdateAll = require(script.Parent.OutdateAll)
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
        _listening = {},
        _value = nil,
        _updated = false,
        _busy = false,
        Destruct = Destruct

    }, Computed) :: any

    self:_update()

    return self
end

function Computed._update<value>(self: Self<value>): boolean

    if self._updated then return false end

    local oldListening = self._listening
    local newListening = {}

    local function Use<engaged>(state: Types.UsedAs<engaged>): engaged
        
        if typeof(state) ~= 'table' then
            return state
        end

        if state._scope == nil then
            error('Invalid state: Dead state added')
        end

        local depSet = state._dependencySet
        newListening[state] = depSet

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

    for listening, depSet in oldListening do depSet[self] = nil end
    for listening, depSet in newListening do depSet[self] = Computed._update :: any end
    self._listening = newListening

    self._value = newValue :: any
    self._updated = true
    self._busy = false

    OutdateAll(self)
    UpdateAll(self)
    
    return true
end

function Computed.Get<value>(self: Self<value>): value
    self:_update()
    return self._value
end

return NewComputed