export type Level = {
	LevelRank: number;
	RequiredXP: number;
}

export type WeaponLevelObject = {
	Linked : string;
	Current: Level;
	CurrentXP: number;
	NextLevel: Level; 
	Rarity: string;

}

local weapon_handler = {
	["all_levels"] = {};
	["weapons"] = {};
}

function weapon_handler.InitializeWeapon(weapon, data: WeaponLevelObject)
	data = data or {}
	local rarity = data.Rarity or "Common"
	
	local current : Level = data.Current or weapon_handler.all_levels[rarity][1] 
	local next_level = weapon_handler.all_levels[rarity][current.LevelRank+1]
	
	print("Next level:", next_level)
	data = {
		Linked = data.Linked;
		Current = current;
		CurrentXP = data.CurrentXP or 0;
		NextLevel = next_level;
		Rarity = rarity;
	}
	
	if weapon_handler.weapons[data.Linked] then
		warn(`Weapon ({data.Linked}) already exists in the level handler`)
		return
	end

	weapon_handler.weapons[data.Linked] = data
	
	return data
end

function weapon_handler.CreateLevelsByRarity(rarity: string, data: {LevelRank: number, RequiredXP: number})
	weapon_handler.all_levels[rarity] = weapon_handler.all_levels[rarity] or {}

	for i, v in weapon_handler.all_levels[rarity] do
		if v.LevelRank == data.LevelRank then
			return
		elseif v.RequiredXP == data.RequiredXP then
			return
		end
	end

	weapon_handler.all_levels[rarity][data.LevelRank] = data
end

function weapon_handler.LevelUp(weaponKey: string)
	local weapon_data = weapon_handler.weapons[weaponKey]
	local rarity = weapon_handler.all_levels[weapon_data.Rarity]

	local old_level = weapon_data.Current
	local new_level: Level = weapon_data.NextLevel
	local next_level: Level = rarity[new_level.LevelRank + 1]

	if not new_level then
		warn("No next level available")
		return
	end

	local xpForThisLevel = new_level.RequiredXP - old_level.RequiredXP
	weapon_data.CurrentXP = weapon_data.CurrentXP - xpForThisLevel

	weapon_data.Current = new_level
	weapon_data.NextLevel = next_level

	print("Leveled up:", weapon_data)
end

function weapon_handler.AwardXP(weaponKey : string, XP: number)
	local weapon_data = weapon_handler.weapons[weaponKey]

	weapon_data.CurrentXP = weapon_data.CurrentXP + XP

	while weapon_data.NextLevel do
		local xpNeededForNextLevel = weapon_data.NextLevel.RequiredXP - weapon_data.Current.RequiredXP

		if weapon_data.CurrentXP >= xpNeededForNextLevel then
			weapon_handler.LevelUp(weaponKey)
		else
			break
		end
	end
end

function weapon_handler.SyncAttributes(weaponModel: Model, weaponKey: string)
	local data = weapon_handler.weapons[weaponKey]
	if not data then
		warn("No weapon data found for key:", weaponKey)
		return
	end

	weaponModel:SetAttribute("Level", data.Current.LevelRank)
	weaponModel:SetAttribute("XP", data.CurrentXP)
	if data.NextLevel then
		local xpNeeded = data.NextLevel.RequiredXP - data.Current.RequiredXP
		weaponModel:SetAttribute("MaxXP", xpNeeded)
	end
end

function weapon_handler.CleanupWeapon(weaponKey: string)
	weapon_handler.weapons[weaponKey] = nil
end

return weapon_handler

