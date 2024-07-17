local Value = require(script.Parent.Parent.State.Value)

local function ToValue(data: {[string]: any})

    assert(typeof(data) == 'table', 'Data needs to be an table.')

    local newData = {}

    for index, value in data do

        newData[index] = Value(value)
    end

    return newData
end

return ToValue