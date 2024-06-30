local function exchangeDependency(a, b)
    a._dependents[b] = true
    b._dependencies[a] = true
end

return exchangeDependency