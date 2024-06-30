local function updateAll(target, ...: any?)
    for dependent in target._dependents do

        local depType = typeof(dependent)

        if depType == 'function' then
            dependent(...)
        end

        if depType == 'table' and dependent.update then
            dependent:update(...)
        end
    end
end

return updateAll