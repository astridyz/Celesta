local function Select(args: {any}, ...: string): (any, any, any, any)

    local types = { ... }
    local result = {}

    for index, targetType in types do

        if args[index] == nil then
            table.insert(result, false)
            continue
        end

        if typeof(args[index]) ~= targetType then
            table.insert(result, false)
            continue
        end

        table.insert(result, args[index])
    end

    return table.unpack(result)
end

return Select