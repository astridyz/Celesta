local scopeIndexes = {
    Computed = true,
    Value = true,
    Insert = true
}

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

        elseif valueType == 'table' and value.Destruct then
            value.Destruct()

        elseif valueType == 'table' then
            Cleanup(value)

        elseif valueType == 'function' and not scopeIndexes[index] then
            value()
        
        end
    end

    table.clear(scope)
end

return Cleanup