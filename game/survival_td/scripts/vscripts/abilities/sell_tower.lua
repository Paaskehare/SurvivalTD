sell_tower = class ({})

function sell_tower:OnSpellStart()
    print("[SurvivalTD] used sell_tower")
    local tower = self:GetCaster()
    local player = tower:GetPlayerOwner()
    local hero   = player:GetAssignedHero()

    local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_coins.vpcf"

    local TowerAbsOrigin = tower:GetAbsOrigin()

    for i=1,10 do 
        local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, tower )
        ParticleManager:SetParticleControl( particle, 0, TowerAbsOrigin )
        ParticleManager:SetParticleControl( particle, 1, TowerAbsOrigin )
    end

    local towerName = tower:GetUnitName()
    local towerAttr = GameMode.Towers[towerName]

    if towerAttr ~= nil then
        local SellMultiplier = self:GetLevelSpecialValueFor( "price_multiplier", self:GetLevel() - 1 )
        local SellPrice = math.floor(towerAttr.GoldCost * SellMultiplier)
        tower:EmitSound("Tower.Sell.Coins")

        hero:SetGold( hero:GetGold() + SellPrice, false)
        print("[SurvivalTD] Sold tower for ".. SellPrice)

        -- Show popup with e.g. +18 for the sellprice

        local symbol = 0 -- "+" presymbol
        local color = Vector(255, 200, 33) -- Gold
        local lifetime = 2
        local digits = string.len(tostring(SellPrice)) + 1
        print("[SurvivalTD] digits: ".. digits)
        local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
        local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, tower, player )
        ParticleManager:SetParticleControl(particle, 1, Vector(symbol, SellPrice, 0))
        ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
        ParticleManager:SetParticleControl(particle, 3, color)

    end
    --local GoldCost = GameMode.Towers[tower:GetName()].GoldCost
    --local SellPrice = math.floor(GoldCost * 0.75)

    --
    

    -- Give the Particles some time to fade away
    tower:ForceKill(false)
    Timers:CreateTimer(2, function() 
        if tower.Platform ~= nil then
            tower.Platform:Destroy()
        end
        
        tower:Destroy()
    end)
end