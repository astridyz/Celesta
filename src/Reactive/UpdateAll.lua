local function UpdateAll(target)

    for dependent in target._dependencySet do

        local depType = typeof(dependent)

        if depType == 'function' then
            dependent()
        end

        if depType == 'table' and dependent.Update then
            dependent.Update()
        end
    end
end

return UpdateAll