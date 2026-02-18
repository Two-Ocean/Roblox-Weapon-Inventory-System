local level_handler = require(script:WaitForChild('LevelHandler'))

local WeaponLevel = {}

function WeaponLevel.InitializeLevelsByRarity(rarity: string, level_list: {level_handler.Level})
	for _, level in level_list do
		level_handler.CreateLevelsByRarity(rarity, level)
	end
end

function WeaponLevel.InitializeWeapon(weapon: Model, data: level_handler.WeaponLevelObject)
	return level_handler.InitializeWeapon(weapon, data)
end


function WeaponLevel.AwardXp(weaponKey, xp)
	level_handler.AwardXP(weaponKey, xp)
end

function WeaponLevel.SyncAttributes(weapon, weaponKey)
	level_handler.SyncAttributes(weapon, weaponKey)
end

function WeaponLevel.CleanupWeapon(weaponKey)
	level_handler.CleanupWeapon(weaponKey)
end

return WeaponLevel