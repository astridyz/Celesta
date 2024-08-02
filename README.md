# Celesta
A new theoretical pattern applied in a library.

## Info
Celesta applies *entities*, *traits* and *components* to create a world.

## Usage
Creating components and scheduling traits

```lua
local World = Celesta.World()

--// Default data for components
local Velocity = Celesta.Component {
    current = 16
}

local Character = Celesta.Component {
    model = 'none'
}

local Query = Celesta.Query(Velocity, Character)

local Trait = Celesta.Trait(Query, 0, function(entity, world, scope, velocity, character)

    local current = velocity.current

    local char = character.model:Get()
    local humanoid = char.Humanoid

    --// Everytime "current" changes, the computed
    --// will change the humanoid walkspeed to the current's value
    Celesta.Computed(scope, function(use)
        humanoid.WalkSpeed = use(current)
    end)
end)


World:Import(Trait)
```

Spawn entities with sets of components

```lua
local function setupPlayer(player)

    World:Entity(
        Player(),
        Velocity(),
        Instance {
            roblox = player
        },
        Character {
            model = player.Character
        }
    )

end

game.Players.PlayerAdded:Connect(setupPlayer)
```