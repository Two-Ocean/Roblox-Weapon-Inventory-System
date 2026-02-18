--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponLevel = require(script.Parent.Weapon.WeaponLevel)
local WeaponInventory = require(script.Parent.WeaponInventory)


local sampleData = {
	current = {LevelRank = 1, RequiredXP = 0},
	XP = 100,
}
local commonBase = {{LevelRank = 1, RequiredXP = 0}}

local function generateLevelsWithBase(maxLevel, xpMultiplier)
	local levels = table.clone(commonBase)
	for i = #levels + 1, maxLevel do
		local previousXP = levels[i - 1].RequiredXP
		local xpIncrease = xpMultiplier * i
		table.insert(levels, {
			LevelRank = i,
			RequiredXP = previousXP + xpIncrease
		})
	end
	return levels
end

WeaponLevel.InitializeLevelsByRarity("Common", generateLevelsWithBase(10, 100))
WeaponLevel.InitializeLevelsByRarity("Rare", generateLevelsWithBase(25, 125))
WeaponLevel.InitializeLevelsByRarity("Epic", generateLevelsWithBase(50, 200))
WeaponLevel.InitializeLevelsByRarity("Legendary", generateLevelsWithBase(100, 500))


Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Once(function(char)
		local playerInv = WeaponInventory.new(player)
	end)
end)

print("Weapon Inventory System initialized")


