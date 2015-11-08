upgrade_tower = class ({})
--SetOverrideSelectionEntity

function upgrade_tower:PopupMessage(presymbol, number, color, unit, player)
    local symbol = presymbol or 0 -- "-" presymbol
    local color = color or Vector(255, 200, 33) -- Gold
    local lifetime = 2
    local digits = string.len(tostring(number)) + 1
    local particleName = "particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf"
    local particle = ParticleManager:CreateParticleForPlayer( particleName, PATTACH_ABSORIGIN, unit, player )
    ParticleManager:SetParticleControl(particle, 1, Vector(symbol, number, 0))
    ParticleManager:SetParticleControl(particle, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(particle, 3, color)
end

function upgrade_tower:GetUpgradeLevel()
    local UnitName = self:GetCaster():GetUnitName()

    return tonumber(string.match(UnitName, '.*_level_(%d)') or 1)
end

function upgrade_tower:GetUpgradedUnitName()
    local UnitName = self:GetCaster():GetUnitName()

    local level = self:GetUpgradeLevel()

    if level > 1 then
        UnitName = string.sub(UnitName, 0, -2) .. (level + 1)
    else
        UnitName = UnitName .. '_level_' .. (level + 1)
    end

    return UnitName
end

function upgrade_tower:GetUpgradedUnit()
    local caster = self:GetCaster()

    local UnitName = self:GetUpgradedUnitName()

    print("[SurvivalTD] " .. UnitName)

    local upgradedUnit = GameMode.Towers[UnitName]

    return upgradedUnit
end

function upgrade_tower:StartBuild(unit, build_time, handler)
    local buildTime = build_time or 5
    local eventHandler = handler or nil
    local currentHealth = 1
    local timerTimeout = .03

    print("[SurvivalTD] Upgrading tower")

    local tower_state = unit:FindAbilityByName("hidden_tower_states")

    unit:SetHealth(currentHealth)
    --unit:ApplyDataDrivenModifier(unit, nil, "modifier_state_building", {duration = buildTime})
    --unit:AddSpeechBubble(0, "Building ..", buildTime, 0, 0)

    -- make the unit unable to do anything while building
    tower_state:ApplyDataDrivenModifier(unit, unit, "modifier_state_building_process", {duration = buildTime})

    unit:SetIdleAcquire(false)
    unit.AcquisitionRange = unit:GetAcquisitionRange()
    unit:SetAcquisitionRange(0)
    tower_state:ApplyDataDrivenModifier(unit, unit, "modifier_attack_system", {})

    local MaxHealth = unit:GetMaxHealth()
    local healthPertick = (MaxHealth - currentHealth) / (buildTime / timerTimeout)

    Timers:CreateTimer(function()
        if not IsValidEntity(unit) then return end -- just cancel if the unit was somehow removed from the game 

        currentHealth = currentHealth + healthPertick
        unit:SetHealth(currentHealth)

        if (currentHealth < MaxHealth) then return timerTimeout end

        -- Finished building tower
        if eventHandler ~= nil then eventHandler() end
    end) 
end

function upgrade_tower:OnSpellStart(keys)
    print("[SurvivalTD] Upgrade Tower used")

    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()
    local hero = player:GetAssignedHero()

    local UpgradedUnit = self:GetUpgradedUnit()
    local UpgradedUnitName = self:GetUpgradedUnitName()

    local towerAttr = GameMode.Towers[UpgradedUnitName]

    if UpgradedUnit ~= nil then
        local UpgradeCost = UpgradedUnit.GoldCost

        if hero:GetLevel() < UpgradedUnit.Level then
            return GameMode:PromptError(player, "error_tower_not_unlocked")
        elseif hero:GetGold() < UpgradeCost then
            return GameMode:PromptError(player, "dota_hud_error_not_enough_gold")
        elseif caster:GetHealth() < caster:GetMaxHealth() then
            return GameMode:PromptError(player, "error_tower_constructing")
        end

        local Platform = caster.Platform -- save reference to the existing platform

        local position = GameMode:SnapToBuildGrid(caster:GetAbsOrigin())

        local towerUnit = CreateUnitByName(UpgradedUnitName, position, false, player, hero, player:GetTeam())
        towerUnit.Platform = towerPlatform
        towerUnit:SetForwardVector(Vector(0, 1, 0 )) -- Face tower north
        towerUnit:SetHullRadius(32.0)                -- Hull Size
        towerUnit:AddAbility("hidden_tower_states")

        local hiddenAbilities = towerUnit:FindAbilityByName("hidden_tower_states")
        hiddenAbilities:SetLevel(1)

        -- for some reason npc_dota_building is invulnerable by default
        if towerUnit:GetClassname() == "npc_dota_building" then
            towerUnit:RemoveModifierByName("modifier_invulnerable")
        end

        towerUnit.Platform = Platform

        hero:SpendGold(UpgradeCost, 0)
        EmitSoundOn("Tower.Buy.Coins", towerUnit)

        -- Show the Build Cost above the tower
        self:PopupMessage(1, UpgradeCost, nil, towerUnit, player)

        local curlevel = self:GetUpgradeLevel()

        -- level up abilities that can be leveled
        for i=1,15 do 
            local ability = towerUnit:GetAbilityByIndex(i)

            if ability ~= nil then 
                if ability:GetMaxLevel() > curlevel then
                    print(ability:GetAbilityName())
                    ability:SetLevel(curlevel + 1)
                end
            end
        end

        upgrade_tower:StartBuild(towerUnit, towerAttr.BuildTime, function() 
            print("[SurvivalTD] Finished building tower")
            towerUnit:SetControllableByPlayer(player:GetPlayerID(), true)
            CustomGameEventManager:Send_ServerToPlayer( player, "tower_built", {tower = tower} )
        end)

        -- make sure the old unit is not doing anything when upgrading starts
        local tower_state = caster:FindAbilityByName("hidden_tower_states")
        tower_state:ApplyDataDrivenModifier(caster, caster, "modifier_building_destroy", {duration = 1})

        -- move the tower out of bounds
        caster:SetAbsOrigin(Vector(0,0,-512))
        -- wait 0.1 seconds (the think interval on attack ability) before destroying the tower
        Timers:CreateTimer(0.2, function()
            caster:Destroy()
        end)
    end

end

upgrade_tower_archer    = upgrade_tower
upgrade_tower_slow      = upgrade_tower
upgrade_tower_mortar    = upgrade_tower
upgrade_tower_frost     = upgrade_tower
upgrade_tower_lightning = upgrade_tower
upgrade_tower_splash    = upgrade_tower
upgrade_tower_skyfury   = upgrade_tower
upgrade_tower_boulder   = upgrade_tower