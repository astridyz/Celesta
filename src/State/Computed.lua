--!strict
--// Packages
local State = script.Parent

local clearStateObject = require(State.Parent.Clear)
local exchangeDependency = require(State.Parent.Exchange)

local Types = require(State.Parent.Types)
type StateObject = Types.StateObject
type useFunction = Types.useFunction

type Value<D, O> = Types.Value<D, O>
type Computed<O> = Types.Computed<O>

--// This
local function Computed<D>(value: Value<D, unknown>, result: <D>(use: useFunction) -> ...any): Computed<unknown>

    local Computed = {
        _dependencies = {},
        _dependents = {},
        class = 'Computed'
    } :: Computed<unknown>
    
    local function use(addValue)

        if not addValue._dependents[Computed] or
            not Computed._dependencies[addValue] then

            exchangeDependency(addValue, Computed)
        end

        return addValue:get()
    end

    function Computed:update()
        value:set(result(use :: any))
    end

    function Computed:destroy()
        clearStateObject(Computed)

        table.clear(Computed)
    end

    Computed:update()

    return Computed
end

return Computed