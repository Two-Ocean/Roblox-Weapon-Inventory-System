# ⚔️ Roblox Weapon Inventory System

A robust, object-oriented weapon inventory and leveling system for Roblox games. Features dynamic weapon management, XP progression, rarity tiers, and memory-efficient instance management.

## ✨ Features

- **🎒 Basic Inventory Management** - Add, remove, equip, and unequip weapons with ease
- **📊 Weapon Leveling System** - XP-based progression with configurable level curves per rarity (inspired by DiddyLevelling)
- **💎 Rarity Tiers** - Common, Rare, Epic, and Legendary weapons with unique progression paths
- **⚡ Memory Efficient** - Weapons only instantiated when equipped, stored as data otherwise
- **🔧 Modular Architecture** - Clean OOP design with separated concerns
- **🎮 Easy Integration** - Simple API for adding to your game

## 📦 Installation

1. Clone or download this repository
2. Copy the init.luau code from the `Weapon` folder in `ServerScriptService`
3. Create Weapon ModuleScript in `ServerScriptService` and paste in init.luau
4. Place the `WeaponInventory` module in `ServerScriptService`
5. Set up your weapon models in `ServerStorage.Weapons`
6. Initialize the level system in your server script

## 🚀 Quick Start

```lua
local WeaponInventory = require(game.ServerScriptService.WeaponInventory)
local WeaponLevel = require(game.ServerScriptService.Weapon.WeaponLevel)

-- Initialize rarity level curves
local function generateLevels(maxLevel, xpMultiplier)
    local levels = {{LevelRank = 1, RequiredXP = 0}}
    for i = 2, maxLevel do
        local previousXP = levels[i - 1].RequiredXP
        table.insert(levels, {
            LevelRank = i,
            RequiredXP = previousXP + (xpMultiplier * i)
        })
    end
    return levels
end

WeaponLevel.InitializeLevelsByRarity("Common", generateLevels(10, 100))
WeaponLevel.InitializeLevelsByRarity("Rare", generateLevels(25, 125))
WeaponLevel.InitializeLevelsByRarity("Epic", generateLevels(50, 200))
WeaponLevel.InitializeLevelsByRarity("Legendary", generateLevels(100, 500))

-- Create inventory for player
local inventory = WeaponInventory.new(player)

-- Add a weapon
local weaponModel = game.ServerStorage.Weapons.MythrilSpear
inventory:AddWeapon(weaponModel, {
    current = {LevelRank = 1, RequiredXP = 0},
    XP = 0
})

-- Equip weapon at index 1
inventory:EquipWeapon(1)

-- Award XP to equipped weapon
local equippedWeapon = inventory:GetEquippedWeapon()
equippedWeapon:AwardXP(50)
```

## 🏗️ Architecture

### Core Components

**`WeaponInventory`** - Manages a player's weapon collection
- Stores weapon instances
- Handles equip/unequip logic
- Provides inventory data for UI

**`Weapon`** - Individual weapon instance
- Lazy instantiation (only creates models when equipped)
- Level data management
- Visual state control (sheathed/unsheathed)

**`WeaponLevel`** - Leveling system manager
- XP tracking and level progression
- Rarity-based level curves
- Attribute syncing for equipped weapons

**`LevelHandler`** - Internal level data storage
- Maintains all level definitions by rarity
- Handles XP calculations and level-ups
- Memory-efficient data storage

## 📖 API Reference

### WeaponInventory

#### `WeaponInventory.new(player: Player)`
Creates a new inventory instance for a player.

#### `:AddWeapon(weaponModel: Model, data: table) -> boolean`
Adds a weapon to the inventory. Returns `true` on success.

**Parameters:**
- `weaponModel` - The weapon model from ServerStorage
- `data` - Table with `current` (Level) and `XP` (number)

#### `:RemoveWeapon(index: number) -> boolean`
Removes a weapon from the inventory at the specified index.

#### `:EquipWeapon(index: number) -> boolean`
Equips the weapon at the specified index. Automatically unequips previous weapon.

#### `:UnequipWeapon() -> boolean`
Unequips the currently equipped weapon.

#### `:GetEquippedWeapon() -> Weapon?`
Returns the currently equipped Weapon instance, or `nil` if none equipped.

#### `:GetInventoryData() -> table`
Returns an array of weapon data for UI display:
```lua
{
    index = number,
    name = string,
    rarity = string,
    weaponType = string,
    level = number,
    xp = number,
    maxXP = number,
    isEquipped = boolean
}
```

### Weapon

#### `Weapon.new(model: Model, owner: Player, data: table)`
Creates a new weapon instance (data only, no model instantiation).

#### `:Equip()`
Instantiates and attaches the weapon model to the character.

#### `:Unequip()`
Removes and destroys the weapon model instance.

#### `:Sheathe()`
Shows sheathed version, hides equipped version.

#### `:Unsheathe()`
Shows equipped version, hides sheathed version.

#### `:AwardXP(xp: number)`
Awards XP to the weapon. Automatically handles level-ups and attribute syncing.

#### `:GetLevelData() -> table`
Returns the weapon's level data including Current, NextLevel, CurrentXP, and Rarity.

#### `:GetRarity() -> string`
Returns the weapon's rarity tier.

#### `:GetWeaponType() -> string`
Returns the weapon's type.

### WeaponLevel

#### `WeaponLevel.InitializeLevelsByRarity(rarity: string, levels: table)`
Initializes the level progression for a rarity tier.

#### `WeaponLevel.AwardXp(weaponKey: string, xp: number)`
Awards XP to a weapon by its unique key.

#### `WeaponLevel.SyncAttributes(weaponModel: Model, weaponKey: string)`
Syncs level data to model attributes for UI/visual updates.

## 🎨 Weapon Model Setup

Your weapon models should have:
- `WeaponType` attribute (string) - e.g., "Sword", "Spear"
- `Rarity` attribute (string) - "Common", "Rare", "Epic", or "Legendary"
- `PropWeld` - Motor6D for attaching to character
- Corresponding sheathed model in character's Torso

## 🔧 Configuration

Edit level curves by modifying the `generateLevels` function:
```lua
-- Higher maxLevel = more levels
-- Higher xpMultiplier = steeper XP curve
WeaponLevel.InitializeLevelsByRarity("Legendary", generateLevels(100, 500))
```

## 📝 License

MIT License - Feel free to use in your projects!

## 🤝 Contributing

Contributions welcome! Feel free to open issues or submit pull requests.

---

Made with ❤️ for the Roblox development community
