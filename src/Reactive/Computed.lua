--!strict
--// Packages
local Destruct = require(script.Parent.Destruct)

local Types = require(script.Parent.Parent.Types)
type Dict<I, V> = Types.Dict<I, V>

local function Computed<D>(
    scope: Dict<unknown, unknown>,
    processor: (use: <VD>(value: Types.Value<VD>) -> VD?) -> D
): Types.Computed<D>

    local Computed = {
        _dependencySet = {},
        Destruct = Destruct
    }

    local currentData = nil
    
    local function Use<VD>(value: Types.Value<VD>)
        value._dependencySet[Computed] = true

        return value:Get()
    end

    function Computed:Get()
        return currentData
    end

    function Computed:Update()
        currentData = processor(Use)
    end

    table.insert(scope :: {}, Computed.Destruct)

    Computed:Update()

    return Computed
end

return Computed