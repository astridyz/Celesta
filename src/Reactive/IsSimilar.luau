--!strict
--// from: https://github.com/dphfox/Fusion/blob/push-pull-execution/src/Utility/isSimilar.luau

local function isSimilar(
	a: unknown, 
	b: unknown
): boolean
	local typeA = typeof(a)
	local isTable = typeA == "table"
	local isUserdata = typeA == "userdata"
	return
		if not (isTable or isUserdata) then
			a == b or (a ~= a and b ~= b)
		elseif typeA == typeof(b) and (isUserdata or table.isfrozen(a :: any) or getmetatable(a :: any) ~= nil) then
			a == b
		else
			false
end

return isSimilar