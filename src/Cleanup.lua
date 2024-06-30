local function Cleanup(scope: {unknown})
    
    for index, value in scope do
        local valueType = typeof(value)

        if valueType == 'thread' then
            task.cancel(value)

        elseif valueType == 'table' and value.destroy then
            value:destroy()

        elseif valueType == 'table' and value.Destroy then
            value:Destroy()

        elseif valueType == 'table' and value.Disconnect then
            value:Disconnect()

        elseif valueType == 'table' then
            Cleanup(value)

        end

    end

    table.clear(scope)
end

return Cleanup