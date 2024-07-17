--!strict
--// Packages
local Select = require(script.Parent.Select)
local ExchangeDependency = require(script.Parent.Exchange)

local Types = require(script.Parent.Types)
type World = Types.World
type Trait = Types.Trait
type Entity = Types.Entity
type Component = Types.Component
type Datatype = Types.Datatype
type ID = Types.ID

local function World(): World

    debug.profilebegin('new world')

    local World = {
        Kind = 'World' :: 'World',
        _entities = {},
        _traits = {},
        Size = 0
    } :: World

    local function ScheduleTrait(trait: Trait)
        World._traits[trait._requirements] = trait
    end

    local function ApplyTraits(entity: Entity)
        debug.profilebegin('apply trait')

		for componentSet, trait in World._traits do

            --// If entity has the trait requirements
            if entity.Has(componentSet) then

                --// If its applied we continue
				if trait.IsApplied(entity) then
                    continue
				end

                --// If its not we apply
                trait.Apply(
                    entity,
                    World,
                    --// Sending all datatypes from the trait requirements
                    --// The order is the parameters of the .Intersect() function
                    entity.Get(table.unpack(componentSet))
                )

                continue
			end
			
            --// If it is applied and the entity doesnt have the requirements
            --// anymore, we remove the trait
			if trait.IsApplied(entity) then
                trait.Remove(entity)
            end
        end

        debug.profileend()
    end

    function World.ScheduleTrait(...: Trait)
        for _, trait in { ... } do
            ScheduleTrait(trait :: any)
        end
    end
    
    local function addDatatypeToEntity(entity, datatype)

        assert(
            datatype.Kind or datatype.Kind == 'Datatype',
            'Attempt to add a invalid datatype to entity'
        )

        local name = datatype._name
        
        entity._storage[name] = datatype
    end

    local function addDataGroupToEntity(entity, group)
        for _, object in group do
            addDatatypeToEntity(entity, object)
        end
    end

    local function addDataToEntity(entity, ...)
        for _, object in { ... } do
        
            --// In case there's no Kind, it must be a array of datatypes
            --// Then, we loop over it to find every datatype on this array
            if not object.Kind then
            
                addDataGroupToEntity(entity, object)
                continue
            end

            if object.Kind == 'Datatype' then
                addDatatypeToEntity(entity, object)
            end
        end
    end

    local function removeDatatypeFromEntity(entity, component)
        if not entity.Has(component) then
            return
        end

        local name = component.Name

        entity._storage[name].Destruct()

        --// Setting it to nil right after destructing
        --// To remove all traits
        entity._storage[name] = nil
    end

    local function removeDataFromEntity(entity, ...)
        for _, object in { ... } do

            if not object.Kind then

                removeDataFromEntity(entity, table.unpack(object))
                continue
            end

            if object.Kind == 'Component' then
                removeDatatypeFromEntity(entity, object)

            elseif object.Kind == 'Bundle' then
                removeDataFromEntity(entity, table.unpack(object._set))

            end
        end
    end

    local function getComponent(entity, ...)
        local results = {} :: {boolean | Datatype}

        for _, component in { ... } do

            local datatype = entity._storage[component.Name]

            if not datatype then
                table.insert(results, false)
            end
            
            table.insert(results, datatype)
        end

        return table.unpack(results)
    end

    function World.Get(entityID: Types.ID)
        local entity = World._entities[entityID]

        if not entityID then
            return
        end

        return entity
    end

    local function GenerateEntity(ID: ID?)
        debug.profilebegin('new entity')

        World.Size += 1

        local entityID = ID or World.Size
        
        if World._entities[entityID] then
            error('Entity ID already taken')
        end

        local Entity = {
            Kind = 'Entity' :: 'Entity',
            _id = entityID,
            _storage = {},
            _dependencies = {},
            _dependents = {}
        } :: Entity

        function Entity.Add(...: Datatype | {Datatype})
            addDataToEntity(Entity, ...)

            ApplyTraits(Entity)

            return Entity
        end

        function Entity.Remove(...)
            removeDataFromEntity(... :: any)

            ApplyTraits(Entity)
            
            return Entity
        end

        function Entity.ChildOf(targetEntity: Entity)
            ExchangeDependency(targetEntity, Entity)

            return Entity
        end

        function Entity.Get(...: any): ...any
            return getComponent(Entity, ...)
        end

        function Entity.Has(...: any)
            for _, object in { ... } do

                if typeof(object) ~= 'table' then
                    continue
                end

                --// In case there's no kind
                --// It must be an array of components
                if not object.Kind then

                    if not Entity.Has(table.unpack(object)) then
                        return false
                    end

                    continue
                end

                --// If is a component, we check it
                if object.Kind == 'Component' then
                    
                    if not Entity._storage[object.Name] then
                        return false
                    end

                elseif object.Kind == 'Bundle' then
                    
                    if not Entity.Has(table.unpack(object._set)) then
                        return false
                    end
                
                end
            end

            return true
        end

        function Entity.Clear()
            for _, datatype in Entity._storage do
                datatype.Destruct()
            end

            table.clear(Entity._storage)

            ApplyTraits(Entity)
        end

        function Entity.Destruct()
            Entity.Clear()

            table.clear(Entity)
            World._entities[entityID] = nil
        end

        if typeof(entityID) == 'Instance' then
            entityID.Destroying:Connect(function()

                Entity.Destruct()
            end)
        end

        World._entities[entityID] = Entity

        debug.profileend()
        
        return Entity
    end

    function World.Entity(...)
        debug.profilebegin('spawn entity')

        local args = { ... }
        local entity

        if Select(args, 'Instance') then
            entity = GenerateEntity(args[1])
            table.remove(args, 1)

        else
            entity = GenerateEntity()
        end

        addDataToEntity(entity, table.unpack(args :: {Datatype}))

        print('Spawning entity:', entity)

        ApplyTraits(entity)

        debug.profileend()

        return entity
    end

    function World.Despawn(entityID: ID)
        local entity = World._entities[entityID]

        if not entity then
            return
        end

        entity.Destruct()
    end

    debug.profileend()

    return World
end

return World