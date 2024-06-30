local function clearStateObject(object)
    for dependent in object._dependents do
        dependent:destroy()
    end

    for dependency in object._dependencies do
        dependency._dependents[object] = nil
    end
end

return clearStateObject