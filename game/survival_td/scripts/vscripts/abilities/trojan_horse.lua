-- Trojan Horse Servants created by Azarak
function HorseVisualInit(event)
	local horse = event.caster
	local ability = event.ability
	local rotation = 90
	local offset = 100
	local horseDir = horse:GetForwardVector()
	for i =1,4 do
		local spawnPos = horse:GetAbsOrigin()
		local rotationDir = RotatePosition(Vector(0,0,0), QAngle(0,rotation*i-45,0), horseDir)
		local finalPos = spawnPos + rotationDir*offset
		local meepo = CreateUnitByName("meepo_dummy_unit", finalPos, false, nil, nil, horse:GetTeam())
		meepo:SetAbsOrigin(finalPos)
		meepo:StartGesture(ACT_DOTA_RUN)
		meepo:SetForwardVector(horseDir)
		meepo.number = i
		ability:ApplyDataDrivenModifier(horse, meepo, "modifier_meepo_visual", {})
	end
end

function HorseVisualFollow(event)
	local horse = event.caster
	local meepo = event.target
	if horse:IsAlive() == false then
		meepo:RemoveSelf()
		return
	end
	local horseDir = horse:GetForwardVector()
	local offset = 100
	local rotation = 90
	local spawnPos = horse:GetAbsOrigin()
	local rotationDir = RotatePosition(Vector(0,0,0), QAngle(0,rotation*meepo.number-45,0), horseDir)
	local finalPos = spawnPos + rotationDir*offset
	meepo:SetAbsOrigin(finalPos)
	meepo:SetForwardVector(horseDir)
end