--!strict
--// Packages
local Scenario = require(script.Parent.Scenario)
local AssertScenarioMatch = Scenario.AssertScenarioMatch

local Component = require(script.Parent.Component)
local AssertComponent = Component.AssertComponent

local Types = require(script.Parent.Types)
type Query<Q...> = Types.Query<Q...>
type Self = Query<unknown>

type Component<D> = Types.Component<D>
type ComponentData<D> = Types.ComponentData<D>

type Dict<I, V> = Types.Dict<I, V>

local function checkAndSolve(object)
    for index, component in object do
        AssertComponent(component, index)
    end
end

local Query  = {}
Query.__index = Query

local function NewQuery(...)
    
    checkAndSolve({ ... })

    return setmetatable({

        _no = {},
        _on = {},
        _need = { ... }

    }, Query)
end

function Query.No(self: Self, ...: Component<unknown>)
    checkAndSolve({ ... })

    self._no = { ... }

    return self
end

function Query.On(self: Self, ...: Types.ScenarioMatch)
    
    for index, ScenarioMatch in { ... } do
        AssertScenarioMatch(ScenarioMatch, index)
    end

    self._on = { ... }

    return self
end

function Query.Match(self: Self, entityID: number, storage: Dict<unknown, Component<unknown>>)

    for _, scenarioMatch in self._on do
        if not scenarioMatch(entityID) then
            return false
        end
    end

    for _, component in self._need do
        local id = component._id

        if not storage[id] then
            return false
        end
    end

    for _, component in self._no do
        local id = component._id

        if storage[id] then
            return false
        end
    end

    return true
end

return (NewQuery :: any) :: Types.QueryConstructor