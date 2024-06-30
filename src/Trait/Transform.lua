local function arrayToDictionary<value>(array: {value}): {[string]: value}
    local dictionary = {}

    for _, component in array do
        dictionary[component.name] = component
    end

    return dictionary
end

return arrayToDictionary