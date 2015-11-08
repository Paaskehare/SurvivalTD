upgrade_tier = class ({})

function upgrade_tier:OnSpellStart()
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local Level  = self:GetLevel()
    local MaxLevel = self:GetMaxLevel()
    local GoldCost = self:GetGoldCost(Level)

    local XPAmount  = self:GetLevelSpecialValueFor("experience", Level)

    print("[SurvivalTD] Upgrade Tier")
    print("[SurvivalTD] Gold Cost: " .. GoldCost)
    print("[SurvivalTD] Experience Gain: " .. GoldCost)

    if (Level < MaxLevel) then
        caster:AddExperience(XPAmount, 0, false, true)
        caster:SetAbilityPoints(0)
        self:SetLevel(Level + 1)

        CustomGameEventManager:Send_ServerToPlayer( player, "tier_upgraded", {} )
    end
end