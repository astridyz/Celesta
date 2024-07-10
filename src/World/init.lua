--!strict
--!nolint UninitializedLocal
--// Packages
local Cleanup = require(script.Parent.Cleanup)

local Types = require(script.Parent.Types)
type World = Types.World
type Entity = Types.Entity

type Trait = Types.Trait
type ComponentData = Types.ComponentData

local function World(): World

    debug.profilebegin('new world')

    local Class = {
        size = 0
    }

    local Datas = {}
    local Traits = {}

    local EntityMap = {}

    function Class.scheduleTraits(traits: {Trait})
        for _, trait in traits do
            Traits[trait._requirements] = trait
        end
    end

    local function scheduleComponent(component)
        local componentName = component._name or component.name

        assert(componentName)

        if not Datas[componentName] then
            Datas[componentName] = {}
        end
    end

    local function createEntity(ID: Instance?)
        Class.size += 1

        local entity = ID or Class.size

        EntityMap[entity] = {
            components = {},
            traits = {}
        }

        return entity
    end

    function Class.get(entity, ...)
        
        if not EntityMap[entity] then
            return
        end

        local results = {}

        for _, component in { ... } do
            local componentData = Datas[component.name][entity]
            
            table.insert(results, componentData)
        end

        return table.unpack(results)
    end

    local function addComponentDataToEntity(entity: Entity, componentData)
        local componentName = componentData._name

        -- print('Adding component:', componentName)

        scheduleComponent(componentData)

        EntityMap[entity].components[componentName] = true
        
        Datas[componentName][entity] = componentData
    end

    local function hasComponent(entity: Entity, component)
        scheduleComponent(component)

        return Datas[component.name][entity] and true
    end

    local function hasComponentSet(entity, componentSet)
        for _, component in componentSet do

            if not hasComponent(entity, component) then
                return false
            end
        end

        return true
    end

    local function applyTraits(entity: Entity)
        debug.profilebegin('apply trait')

        -- print('Starting to apply to:', entity)

        for componentSet, trait in Traits do
            
            if not hasComponentSet(entity, componentSet) then

                -- print(entity, 'doesnt have the component set', componentSet)

                if not trait.isApplied(entity) then
                    continue
                end

                -- print('Removing trait from:', entity)

                trait.remove(entity)

                EntityMap[entity].traits[trait] = nil

                continue
            end

            if trait.isApplied(entity) then
                continue
            end
            
            trait.apply(entity, Class)

            EntityMap[entity].traits[trait] = true
        end

        debug.profileend()
    end
    
    local function removeComponentFromEntity(entity, component)
        
        if not Datas[component.name][entity] then
            error('Attempt to remove inexistent component')
        end

        table.clear(Datas[component.name][entity])
        EntityMap[entity].components[component.name] = nil

        applyTraits(entity)

    end

    function Class.spawn(...)
        debug.profilebegin('spawn entity')

        local args = { ... }
        local entity

        if typeof(args[1]) == 'Instance' then
            entity = createEntity(args[1])
            table.remove(args, 1)
        else
            entity =  createEntity()
        end

        print('Spawning entity: ', entity)

        for _, componentData in args do
            addComponentDataToEntity(entity, componentData)
        end

        applyTraits(entity)

        if typeof(entity) == 'Instance' then

            entity.Destroying:Connect(function()

                Class.despawn(entity)
            end)
        end

        debug.profileend()

        return entity
    end

    function Class.despawn(entity)

        for trait in EntityMap[entity].traits do
            trait.remove(entity)
        end

        for componentName in EntityMap[entity].components do
            local componentData = Datas[componentName][entity]

            Cleanup(componentData)
        end

        EntityMap[entity] = nil
    end

    function Class.remove(entity, ...: Types.Component)

        if not EntityMap[entity] then
            error('Entity doesnt exist')
        end
        
        for _, component in { ... } do
            removeComponentFromEntity(entity, component)
        end

    end

    function Class.insert(entity, ...: ComponentData)
        for _, componentData in { ... } do
            addComponentDataToEntity(entity, componentData)
        end

        applyTraits(entity)
    end

    debug.profileend()

    return Class :: World
end

return World