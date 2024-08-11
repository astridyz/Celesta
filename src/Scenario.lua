--!strict
--// Packages
local InvertDict = require(script.Parent.Utils.InvertDict)

--// Typing
local Types = require(script.Parent.Types)
type Self = Types.Scenario
type ScenarioState = Types.ScenarioState

type Entity = Types.Entity

--// This
local Scenario = {}
Scenario.__index = Scenario

--// Functions
local function NewScenario(...: ScenarioState): Types.Scenario
    local order = { ... }
    local states = InvertDict(order)

    return setmetatable({

        _tracking = {},
        _order = order,
        _states = states

    }, Scenario) :: any
end

function Scenario.Patch(self: Self, entity: Entity, state: ScenarioState?)

    local id = entity._id

    local stateToAdd = state or self._order[1]
    assert(self._states[stateToAdd], 'State not provided at default data.')

    self._tracking[id] = stateToAdd

    local world = entity._world

    if world then
        world:_applyTraits(entity)
    end
end

function Scenario.Next(self: Self, entity: Entity)

    local id = entity._id

    local state = self._tracking[id]
    assert(state, 'Entity is not added to scenario. Cannot perform function')

    local nextStateIndex = self._states[state] + 1
    local nextState = self._order[nextStateIndex]

    if not nextState then
        return
    end

    self._tracking[id] = nextState

    local world = entity._world

    if world then
        world:_applyTraits(entity)
    end
end

function Scenario.Contain(self: Self, entity: Entity, state: ScenarioState?)
    
    local id = entity._id
    local entityState = self._tracking[id]

    if not entityState then
        return false
    end

    if state then
        
        if entityState == state then
            return true
        end

        return false
    end

    return true
end

local function AssertScenarioMatch(object: unknown, index: number)
    assert(typeof(object) == 'function', 'Scenario matching #' .. index .. ' is invalid: not a function.')
end

return {
    New = NewScenario,
    AssertScenarioMatch = AssertScenarioMatch
}