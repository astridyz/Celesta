--!strict
--// Packages
local State = script.Parent

local Select = require(State.Parent.Select)
local clearStateObject = require(State.Parent.Clear)
local exchangeDependency = require(State.Parent.Exchange)

local Value = require(script.Parent.Value)

local Types = require(State.Parent.Types)
type useFunction = Types.useFunction

type Value<D, O> = Types.Value<D, O>
type Computed<O> = Types.Computed

--// This
local function Computed<D>(...): Computed<unknown>

    debug.profilebegin('new computed')

    local value, result = Select(
        { ... }, 'table', 'function'
    )

    value = value or Value()

    local Computed = {
        Kind = 'Computed' :: 'Computed',
        _dependencies = {},
        _dependents = {}
    } :: Computed<unknown>
    
    local function use(addValue)

        if not addValue._dependents[Computed] or
            not Computed._dependencies[addValue] then

            exchangeDependency(addValue, Computed)
        end

        return addValue:get()
    end

    function Computed.Update()
        value:set(result(use :: any))
    end

    function Computed.Destruct()
        clearStateObject(Computed)

        table.clear(Computed)
    end

    Computed.Update()

    debug.profileend()

    return Computed
end

return Computed :: (<D>(value: Value<D, unknown>, result: <D>(use: useFunction) -> ...any) -> Computed<unknown>)
& (<D>(result: <D>(use: useFunction) -> ...any) -> Computed<unknown>)