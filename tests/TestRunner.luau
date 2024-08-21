local function tester(name: string)

    local self = {
        result = {},
        tests = {},
        name = name,
    }
    function self:run(...: () -> ())
        for _,job in {...} do
            local name = debug.info(job, 'n')
            local test = tester(name)

            table.insert(self.tests, test)
            test.result = table.pack(pcall(job, test))
        end
    end
    return self
end
return tester('global')