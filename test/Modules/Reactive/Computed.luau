local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Computed = require(ReplicatedStorage.Packages.Celesta.Reactive.Computed)
local Value = require(ReplicatedStorage.Packages.Celesta.Reactive.Value)

return function(tester)

    local function should_update_when_root_changes(test)

        local level = Value(test, 10)
        local reqExp = Computed(test, function(use)
            return 100 * 1.1^use(level)
        end)

        assert(reqExp._value == 100 * 1.1^10, 'Didnt use the initial level')

        level:Set(15)
        assert(reqExp._value == 100 * 1.1^15, 'Didnt use the updated level')
    end
    
    local function should_unlisten_unused_states(test)

        local src1 = Value(test, 10)
        local src2 = Value(test, 20)

        local count = 0
        
        local listener = Computed(test, function(use)
            count += 1
            return if count == 1 then use(src1) elseif count == 2 then use(src2) else 'cavalo'
        end)

        assert(listener._value == 10, 'Didnt use the initial src1')

        src1:Set(15)
        assert(listener._value == 20, 'Didnt use the initial src2')

        src1:Set(17)
        assert(listener._value == 20, 'Used updated the src1')

        src2:Set(40)
        src1:Set(20)
        assert(listener._value == 'cavalo', 'Still using some src')
    end

    return tester:run(
        should_update_when_root_changes,
        should_unlisten_unused_states
    )
end