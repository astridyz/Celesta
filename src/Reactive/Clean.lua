local function Clean(object)

    if typeof(object) == 'function' then
        object()

    elseif typeof(object) == 'Instance' then
        object:Destroy()

    elseif typeof(object) == 'RBXScriptConnection' then
        object:Disconnect()

    elseif typeof(object) == 'table' then
        
        if object.Destroy then
            object:Destroy()
        
        elseif object.destroy then
            object:destroy()
        
        elseif object.Destruct then
            object.Destruct()

        else

            for _, task in object do
                Clean(task)
            end

        end

        table.clear(object)
    end

end

return Clean