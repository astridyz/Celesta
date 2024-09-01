--!strict
local Package = script.Parent
local Reactive = Package.Parent
local State = require(Package)

local Destruct = require(Reactive.Destruct)

local Types = require(Reactive.Parent.Types)
type Computed<value> = Types.Computed<value>

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
        Destruct = Destruct

    }, Computed) :: any

    self:_update()

    return self
end

function Computed._update<value>(self: Computed<value>): boolean

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
    for listening, depSet in newListening do depSet[self] = Computed._update end
    self._listening = newListening

    State.Outdate(self)
    self._value = newValue :: any
    self._updated = true
    State.Update(self)
    
    return true
end

function Computed.Get<value>(self: Computed<value>): value
    self:_update()
    return self._value
end

return NewComputed