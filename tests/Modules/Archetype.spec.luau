--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Celesta = require(ReplicatedStorage.Celesta)
local World = Celesta.World
local Trait = Celesta.Trait
local Component = Celesta.Component
local Query = Celesta.Query

return function()
	describe("Archetype", function()
		it("should create an archetype with components id", function()
			local world = World()
			local c1, c2 = Component(), Component()

			local trait1 = Trait(Query(c1, c2), 0, function() end)

			world:Import(trait1)

			local compoundArchetypeHash = c1._id .. "_" .. c2._id
			expect(world._archetypeIndex[compoundArchetypeHash]).to.be.ok()
		end)

		it("should merge compatible unity archetypes in the compound archetype", function()
			local world = World()
			local c1, c2 = Component(), Component()

			local trait1 = Trait(Query(c1, c2), 0, function() end)
			local trait2 = Trait(Query(c1), 0, function() end)
			local trait3 = Trait(Query(c2), 0, function() end)

			world:Import(trait1, trait2, trait3)

			local compoundArchetypeHash = c1._id .. "_" .. c2._id
			local compoundArchetype = world._archetypeIndex[compoundArchetypeHash]

			expect(table.find(compoundArchetype.traits, trait1)).to.be.ok()
			expect(table.find(compoundArchetype.traits, trait2)).to.be.ok()
			expect(table.find(compoundArchetype.traits, trait3)).to.be.ok()
		end)

		it("should not merge imcompatible unity archetypes", function()
			local world = World()
			local c1, c2, c3 = Component(), Component(), Component()

			local trait1 = Trait(Query(c1, c2), 0, function() end)
			local trait2 = Trait(Query(c3), 0, function() end)

			world:Import(trait1, trait2)

			local compoundArchetypeHash = c1._id .. "_" .. c2._id
			local compoundArchetype = world._archetypeIndex[compoundArchetypeHash]

			expect(table.find(compoundArchetype.traits, trait2)).to.be.never.ok()
		end)
	end)
end
