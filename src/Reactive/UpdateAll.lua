local function updateAll(target, ...)
    for dependent in target._dependentSet do

        local depType = typeof(dependent)

        if depType == 'function' then
            dependent(...)
        end

        if depType == 'table' and dependent.Update then
            dependent.Update(...)
        end
    end
end

return updateAll