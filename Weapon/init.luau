--!nonstrict
local HttpService = game:GetService("HttpService")
local WeaponLevel = require(script.WeaponLevel)

local Weapon = {}
Weapon.__index = Weapon

function Weapon.new(model : BasePart, owner : Player, data)
	if typeof(model) ~= "Instance" then error("Invalid weapon model") return end
	if typeof(owner) ~= "Instance" or not owner:IsA("Player") then error("Invalid owner") return end

	local self = setmetatable({}, Weapon)
	self.weaponKey = `{owner.UserId}-{model.Name}-{HttpService:GenerateGUID(false)}`

	self.weaponModelName = model.Name
	self.ownerChar = owner.Character
	self.ownerPlr = owner
	self.welds = {}
	self.weaponType = model:GetAttribute"WeaponType"
	self.rarity = model:GetAttribute"Rarity" or "Common"

	self.weaponModel = nil
	self.sheatheModel = nil
	self.isEquipped = false

	self.Level = WeaponLevel.InitializeWeapon(nil, {
		Linked = self.weaponKey,
		Current = data.current,
		CurrentXP = data.XP,
		Rarity = self.rarity
	})

	return self
end

function Weapon:Equip()
	if self.isEquipped then 
		warn("Weapon already equipped")
		return 
	end

	self.weaponModel = game.ServerStorage.Weapons:FindFirstChild(self.weaponModelName):Clone()

	local weapKey = Instance.new("StringValue")
	weapKey.Parent = self.weaponModel
	weapKey.Name = "WeaponKey"
	weapKey.Value = self.weaponKey

	self.weaponModel.Parent = self.ownerChar:FindFirstChild("Hilt", true)
	self.weaponModel:FindFirstChild("PropWeld").Part0 = self.ownerChar.Hilt

	self.sheatheModel = self.ownerChar.Torso:FindFirstChild(self.weaponModelName)

	WeaponLevel.SyncAttributes(self.weaponModel, self.weaponKey)

	self.isEquipped = true
	self:Sheathe()
end

function Weapon:Unequip()
	if not self.isEquipped then return end

	self.sheatheModel.Transparency = 1
	self.weaponModel.Transparency = 1

	if self.weaponModel then
		self.weaponModel:Destroy()
		self.weaponModel = nil
	end

	self.sheatheModel = nil
	self.isEquipped = false
end

function Weapon:Sheathe()
	if not self.isEquipped then return end
	self.sheatheModel.Transparency = 0
	self.weaponModel.Transparency = 1
end

function Weapon:Unsheathe()
	if not self.isEquipped then return end
	self.sheatheModel.Transparency = 1
	self.weaponModel.Transparency = 0
end

function Weapon:GetLevelData()
	return self.Level
end

function Weapon:GetWeaponType()
	return self.weaponType
end

function Weapon:GetRarity()
	return self.rarity
end

function Weapon:GetNextLevel()
	return self.Level.NextLevel
end

function Weapon:AwardXP(xp)
	WeaponLevel.AwardXp(self.weaponKey, xp)
	if self.isEquipped and self.weaponModel then
		WeaponLevel.SyncAttributes(self.weaponModel, self.weaponKey)
	end
end

function Weapon:UpdatePlayerCharacter(char)
	self.ownerChar = char
end

function Weapon:Destroy()
	if self.isEquipped then
		self:Unequip()
	end
	WeaponLevel.CleanupWeapon(self.weaponKey)
end

return Weapon