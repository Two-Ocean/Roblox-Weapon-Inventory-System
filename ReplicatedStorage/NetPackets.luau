local Packet = require(script.Parent.Packet)

local WeaponDataType = {
	index      = Packet.NumberU8,
	isEquipped = Packet.Boolean8,
	level      = Packet.NumberU8,
	maxXP      = Packet.NumberU16,
	name       = Packet.String,
	rarity     = Packet.String,
	weaponType = Packet.String,
	xp         = Packet.NumberU16,
}

return {
	GetInventoryData = Packet("GetInventoryData"):Response({ WeaponDataType }),
	EquipWeapon      = Packet("EquipWeapon",  Packet.NumberU8),
	UnequipWeapon    = Packet("UnequipWeapon"),
	DeleteWeapon     = Packet("DeleteWeapon", Packet.NumberU8),
}