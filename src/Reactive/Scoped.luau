--!strict
local Reactive = script.Parent
local Celesta = Reactive.Parent

local JoinData = require(Celesta.Utils.JoinData)

local Types = require(Celesta.Types)
type Scoped<D> = Types.Scoped<D>

local function Scope(...: {[unknown]: unknown})
    
    local proxy = {}
    proxy.__index = proxy

    for _, object in { ... } do
        assert(typeof(object) == 'table', 'Merge table needs to be a table')

        JoinData(object, proxy)
    end

    return setmetatable({}, proxy)
end

return (Scope :: any) :: Types.ScopedConstructor