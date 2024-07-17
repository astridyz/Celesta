local function joinData<config, target>(config: config, target: target): config & target

    assert(type(target) == 'table', 'Target needs to be a table.')
    assert(type(config) == 'table', 'Config needs to be a table.')

    for index, default in config do

        if not target[index] then
            target[index] = default
            continue
        end

        if typeof(target[index]) == 'table' and typeof(config[index]) == 'table' then
            target[index] = joinData(config[index], target[index])
        end
    end

    return target
end

return joinData