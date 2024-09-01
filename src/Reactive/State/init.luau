--!strict
local Types = require(script.Parent.Parent.Types)
type UserState = Types.UserState

local function Outdate(target: UserState)
    for dependent in target._dependencySet do
        dependent._updated = false
        Outdate(dependent)
    end
end

local function Update(target: UserState)
    for dependent, update in target._dependencySet do

        if typeof(dependent) == 'table' and update(dependent) then
        elseif typeof(dependent) == 'function' then dependent() end
    end
end

local function Cast(target: any): Types.State?
    return
        if typeof(target) == 'table' and
        typeof(target._dependencySet) == 'table'
    then target else nil
end

return {
    Outdate = Outdate,
    Update = Update,
    Cast = Cast
}