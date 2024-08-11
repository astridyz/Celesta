--!strict
--// Typing
local Types = require(script.Parent.Parent.Types)
type Dict<I, V> = Types.Dict<I, V>

--// This
local function ToBooleanDict<A, B>(tab: Dict<A, B>): Dict<B, A>
    local result = {}

    for index, value in tab do
        result[value] = index
    end

    return result
end

return ToBooleanDict