local function Destruct(object)
    for dependency in object._dependencySet do
        
        if not dependency.Destruct then
            continue
        end

        dependency.Destruct()
    end
end

return Destruct