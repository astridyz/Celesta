local function Select(args: {any}, ...: string): (any, any, any, any)

    local types = { ... }
    local result = {}

    for index, targetType in types do

        if args[index] == nil then

            if result[index] then
                result[index + 1] = false
            else
                result[index] = false
            end

            continue
        end

        if typeof(args[index]) ~= targetType then

            if typeof(args[index]) == types[index + 1] then

                result[index + 1] = args[index]
                continue
            end

            result[index] = false
            continue
        end

        result[index] = args[index]
    end

    return result[1], result[2], result[3], result[4]
end

return Select