--!strict
--// Packages
local InvertDict = require(script.Parent.Utils.InvertDict)

local Types = require(script.Parent.Types)
type Scenario = Types.Scenario
type ScenarioState = Types.ScenarioState

type Entity = Types.Entity

local Scenario = {}
Scenario.__index = Scenario
Scenario.Kind = 'Scenario'

local function NewScenario(...: ScenarioState): Scenario
    local order = { ... }
    local states = InvertDict(order)

    local scenario = {
        _tracking = {},
        _order = order,
        _states = states
    }

    setmetatable(scenario, Scenario)

    return scenario :: any
end

function Scenario.Patch(self: Scenario, entity: Entity, state: ScenarioState?)

    local id = entity._id
    local world = entity._world

    local stateToAdd = state or self._order[1]
    assert(self._states[stateToAdd], 'State not provided at default data.')

    self._tracking[id] = stateToAdd

    if world then
        world:_applyTraits(entity)
    end
end

function Scenario.Next(self: Scenario, entity: Entity)
    local id = entity._id
    local world = entity._world

    local state = self._tracking[id]
    assert(state, 'Entity is not added to scenario. Cannot perform function')

    local nextStateIndex = self._states[state] + 1
    local nextState = self._order[nextStateIndex]

    if not nextState then
        return
    end

    self._tracking[id] = nextState

    if world then
        world:_applyTraits(entity)
    end
end

function Scenario.__call(self: Scenario, expectedState: ScenarioState, removePrevious: boolean?)

    assert(self._states[expectedState], 'State not provided at default data.')
    
    return function(entityID: number)

        local state = self._tracking[entityID]

        if not state then
            return false
        end

        if removePrevious then
            if state ~= expectedState then
                return false
            end
        end

        local expectedStateId = self._states[expectedState]
        local actualStateId = self._states[state]

        if actualStateId < expectedStateId then
            return false
        end

        return true
    end
end

local function AssertScenarioMatch(object: unknown, index: number)
    assert(typeof(object) == 'function', 'Scenario matching #' .. index .. ' is invalid: not a function.')
end

return {
    New = NewScenario,
    AssertScenarioMatch = AssertScenarioMatch
}