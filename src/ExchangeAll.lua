local ExchangeDependency = require(script.Parent.Exchange)

local function exchangeDependencyAll(dependency, target)
    for _, object in target do

        if typeof(object) ~= 'table' then
            continue
        end
        
        if object.Kind == 'Component' or object.Kind == 'Bundle' then
            ExchangeDependency(object, dependency)

        elseif typeof(object) == 'table' then

            exchangeDependencyAll(dependency, object)
        end
    end

end

return exchangeDependencyAll 