local ExchangeDependency = require(script.Parent.Exchange)

local function exchangeDependencyAll(dependency, table)
    for _, object in table do
        
        if object.Kind == 'Component' or object.Kind == 'Bundle' then
            ExchangeDependency(object, dependency)

        elseif typeof(object) == 'table' then

            exchangeDependencyAll(dependency, object)
        end
    end

end

return exchangeDependencyAll 