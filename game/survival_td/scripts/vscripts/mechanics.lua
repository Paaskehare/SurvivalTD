-- Ground/Air Attack mechanics
function FindEnemiesInRadius( unit, radius )
	local team = unit:GetTeamNumber()
	local position = unit:GetAbsOrigin()
	local target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	return FindUnitsInRadius(team, position, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, target_type, flags, FIND_CLOSEST, false)
end

function UnitCanAttackTarget( unit, target )

	if not IsValidEntity(unit) then return false end

	if unit == nil or target == nil or (not unit:HasAttackCapability()) then
		return false
	end

	local enabled_attacks = GetEnabledAttacks(unit)
	local target_type = GetMovementCapability(target)

	return string.match(enabled_attacks, target_type)
end

-- Returns "air" if the unit can fly
function GetMovementCapability( unit )
	if unit == nil then return "" end

	if unit:HasFlyMovementCapability() then
		return "air"
	else 
		return "ground"
	end
end

-- Searches for "EnabledAttacks" in the KV files
-- Default by omission is "ground,air", other possible returns should be "ground,air" or "air"
function GetEnabledAttacks( unit )
	local unitName = unit:GetUnitName()
	local enabled_attacks

	local TowerUnit = GameMode.Towers[unitName]

	if not unit:IsHero() then
		enabled_attacks = TowerUnit and TowerUnit["AttacksEnabled"] or nil
	end

	return enabled_attacks or "ground,air"
end