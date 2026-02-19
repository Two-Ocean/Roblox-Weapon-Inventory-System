--!nonstrict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ProfileStore = require(game.ServerScriptService.Modules.ProfileStore)

local connections = {}

local weaponProfile = ProfileStore.New("WeaponInventory", {
	Weapons = {}
})
local Profiles: {[Player]: typeof(weaponProfile:StartSessionAsync())} = {}

local WeaponLevel = require(script.Parent.Weapon.WeaponLevel)
local WeaponInventory = require(script.Parent.WeaponInventory)

local NetPackets = require(ReplicatedStorage.NetPackets)

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

local function saveInventory(player)
	local profile = Profiles[player]
	local inventory = WeaponInventory.GetInventory(player)
	if not profile or not inventory then return end

	local savedWeapons = {}
	for _, weaponData in ipairs(inventory:GetInventoryData()) do
		table.insert(savedWeapons, {
			modelname = weaponData.name,
			levelData = {
				current = { LevelRank = weaponData.level, RequiredXP = weaponData.maxXP },
				XP = weaponData.xp,
			}
		})
	end

	profile.Data.Weapons = savedWeapons
end

Players.PlayerAdded:Connect(function(player)
	connections[player] = {}
	local profile = weaponProfile:StartSessionAsync(`{player.UserId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			Profiles[player] = nil
			player:Kick(`Profile session end - Please rejoin`)
		end)

		if player.Parent == Players then
			Profiles[player] = profile

			local playerInv = WeaponInventory.new(player)
			for _, weaponData in ipairs(profile.Data.Weapons) do
				playerInv:AddWeapon(
					game.ServerStorage.Weapons:FindFirstChild(weaponData.modelname),
					{ current = weaponData.levelData.current, XP = weaponData.levelData.XP }
				)
			end

			local function onCharacterAdded(char)
				playerInv:UpdatePlayerCharacter(char)
				local equippedWeaponIndex = player:GetAttribute("WeaponEquipped")
				print(equippedWeaponIndex)
				if equippedWeaponIndex then
					playerInv:EquipWeapon(equippedWeaponIndex)
				end
				player:SetAttribute("WeaponEquipped", nil)

				if connections[player].died then connections[player].died:Disconnect() end
				connections[player].died = player.Character.Humanoid.Died:Connect(function(char)
					local inventory = WeaponInventory.GetInventory(player)
					if inventory then
						player:SetAttribute("WeaponEquipped", inventory.equippedIndex)
						inventory:UnequipWeapon()
					end
				end)
			end

			connections[player].char = player.CharacterAdded:Connect(onCharacterAdded)
			if player.Character then onCharacterAdded(player.Character) end

		end
	else
		player:Kick(`Profile load fail - Please rejoin`)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	saveInventory(player)

	local profile = Profiles[player]
	if profile ~= nil then
		profile:EndSession()
	end

	local inventory = WeaponInventory.GetInventory(player)
	if inventory then
		inventory:Destroy()
	end
	
	if connections[player] then
		if connections[player].char then connections[player].char:Disconnect() end
		if connections[player].died then connections[player].died:Disconnect() end
		connections[player] = nil
	end
end)

NetPackets.GetInventoryData.OnServerInvoke = function(player)
	local inventory = WeaponInventory.GetInventory(player)
	if inventory then
		return inventory:GetInventoryData()
	end
	return {}
end

NetPackets.EquipWeapon.OnServerEvent:Connect(function(player, index)
	local inventory = WeaponInventory.GetInventory(player)
	if inventory then
		inventory:EquipWeapon(index)
	end
end)

NetPackets.UnequipWeapon.OnServerEvent:Connect(function(player, index)
	local inventory = WeaponInventory.GetInventory(player)
	if inventory then
		inventory:UnequipWeapon()
	end
end)

NetPackets.DeleteWeapon.OnServerEvent:Connect(function(player, index)
	local inventory = WeaponInventory.GetInventory(player)
	if inventory then
		inventory:RemoveWeapon(index)
	end
end)

print("Weapon Inventory System initialized")


--local WeaponInventory = require(game.ServerScriptService.WeaponInventory)
--local inventory = WeaponInventory.GetInventory(game.Players.YPCOcean)
--if inventory then
--	inventory:AddWeapon(game.ServerStorage.Weapons.Fairfrozen,{
--		current = {LevelRank = 1, RequiredXP = 0},
--		XP = 150,
--	} )
--end
