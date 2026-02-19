local Weapon = require(script.Parent.Weapon)

local WeaponInventory = {}
WeaponInventory.__index = WeaponInventory

local PlayerInventories = {}

function WeaponInventory.new(player)
	if PlayerInventories[player.UserId] then
		return PlayerInventories[player.UserId]
	end
	
	local self = setmetatable({}, WeaponInventory)
	self.player = player
	self.weapons = {}
	self.equippedWeapon = nil
	self.equippedIndex = nil
	self.maxWeapons = 10 
	
	PlayerInventories[player.UserId] = self
	return self
end

function WeaponInventory.GetInventory(player)
	return PlayerInventories[player.UserId]
end

function WeaponInventory:AddWeapon(weaponModel, data)
	if #self.weapons >= self.maxWeapons then
		warn("Inventory full for player:", self.player.Name)
		return false
	end
	local weapon = Weapon.new(weaponModel,self.player, data)
	table.insert(self.weapons, weapon)
end

function WeaponInventory:RemoveWeapon(index: number)
	if index < 1 or index > #self.weapons then
		warn("Invalid weapon index:", index)
		return false
	end
	
	if not self.weapons[index] then
		warn("No weapon at index:", index)
		return false
	end
	
	if self.equippedWeapon == self.weapons[index] then
		self.weapons[index]:Unequip()
		self.equippedWeapon = nil
		self.equippedIndex = nil
	end
	
	if self.equippedIndex and self.equippedIndex > index then
		self.equippedIndex = self.equippedIndex - 1
	end
	
	self.weapons[index]:Destroy()
	table.remove(self.weapons, index)
end

function WeaponInventory:EquipWeapon(index)
	if index < 1 or index > #self.weapons then
		warn("Invalid weapon index:", index)
		return false
	end
	
	if self.equippedWeapon == self.weapons[index] then
		warn("Weapon already equipped:", index)
		return false
	end
	
	if self.equippedWeapon then
		self.equippedWeapon:Unequip()
	end
	
	self.equippedWeapon = self.weapons[index]
	self.equippedIndex = index
	
	self.weapons[index]:Equip()
	return true
end

function WeaponInventory:UnequipWeapon()
	if not self.equippedWeapon then
		return false
	end
	
	self.equippedWeapon:Unequip()
	self.equippedWeapon = nil
	self.equippedIndex = nil
end

function WeaponInventory:GetEquippedWeapon()
	return self.equippedWeapon
end

function WeaponInventory:GetInventoryData()
	print(self.weapons)
	local inventoryData = {}
	for i, weapon in ipairs(self.weapons) do
		table.insert(inventoryData, {
			index = i,
			name = weapon.weaponModelName,
			rarity = weapon:GetRarity(),
			weaponType = weapon:GetWeaponType(),
			level = weapon:GetLevelData().Current.LevelRank,
			xp = weapon:GetLevelData().CurrentXP,
			maxXP = weapon:GetNextLevel().RequiredXP,
			isEquipped = (i == self.equippedIndex)
		})
	end
	return inventoryData
end

function WeaponInventory:UpdatePlayerCharacter(char)
	for _, weapon in ipairs(self.weapons) do
		weapon.ownerChar = nil
		weapon:UpdatePlayerCharacter(char)
	end
end

function WeaponInventory:Destroy()
	for _, weapon in ipairs(self.weapons) do
		weapon:Destroy()
	end
	self.weapons = {}
	self.equippedWeapon = nil
	self.equippedIndex = nil
	PlayerInventories[self.player.UserId] = nil
end

return WeaponInventory