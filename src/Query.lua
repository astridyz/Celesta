--!strict
--// Packages
local Scenario = require(script.Parent.Scenario)
local Component = require(script.Parent.Component)

local AssertScenarioMatch = Scenario.AssertScenarioMatch
local AssertComponent = Component.AssertComponent

local Types = require(script.Parent.Types)
type Query<Q...> = Types.Query<Q...>

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

    local query = {
        _no = {},
        _on = {},
        _need = { ... }
    }

    setmetatable(query, Query)

    return query
end

function Query.No(self: Query<unknown>, ...: Component<unknown>)
    checkAndSolve({ ... })

    self._no = { ... }

    return self
end

function Query.On(self: Query<unknown>, ...: Types.ScenarioMatch)
    for index, ScenarioMatch in { ... } do
        AssertScenarioMatch(ScenarioMatch, index)
    end

    self._on = { ... }

    return self
end

function Query.Match(self: Query<unknown>, entityID: number, storage: Dict<number, Component<unknown>>)

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