--// Packages
local Types = require(script.Parent.Types)
type Value<D> = Types.Value<D>

local T = {}

--[[

local character = Celesta.Component {
    age = t.Number(18)
}

]]

function T.Number(default: number)
    
    return function(merge: number)
        
        return 
    end
end

--[[

local default = {
    age = function()

    end
}

local function instantiate()


end

]]

return T