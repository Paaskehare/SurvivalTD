build_tower = class ({})

function build_tower:PositionCollides(position)

    local UnitWidth       = 128
    local UnitWidthHalf   = UnitWidth / 2
    local BlockingSize    = UnitWidthHalf

    local collided = false

    local BlockingEntities = Entities:FindAllInSphere(GetGroundPosition(position, nil), BlockingSize)

    for _,blk in pairs(BlockingEntities) do
        local snapped = GameMode:SnapToBuildGrid(blk:GetAbsOrigin())

        --local parent = blk:GetMoveParent()

        if blk:GetClassname() ~= "dota_item_wearable" then

            -- If X or Y of the block is less than 128 units away from our current position, we can't build here
            if not ((snapped.x > position.x and (snapped.x - position.x) >= UnitWidth) or
                    (snapped.x < position.x and (position.x - snapped.x) >= UnitWidth) or 
                    (snapped.y > position.y and (snapped.y - position.y) >= UnitWidth) or 
                    (snapped.y < position.y and (position.y - snapped.y) >= UnitWidth)) then

                -- We got a collission, no need to continue looking
                collided = true
                break
            end
        end
    end

    return collided
end

function build_tower:StartBuild(unit, build_time, handler)
    local buildTime = build_time or 5
    local eventHandler = handler or nil
    local currentHealth = 1
    local timerTimeout = .03

    local tower_state = unit:FindAbilityByName("hidden_tower_states")

    unit:SetHealth(currentHealth)
    --unit:ApplyDataDrivenModifier(unit, nil, "modifier_state_building", {duration = buildTime})
    --unit:AddSpeechBubble(0, "Building ..", buildTime, 0, 0)

    -- make the unit unable to do anything while building
    tower_state:ApplyDataDrivenModifier(unit, unit, "modifier_state_building_process", {duration = buildTime})

    -- attack system
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

function build_tower:PopupMessage(presymbol, number, color, unit, player)
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

function build_tower:OnSpellStart()
    print("[SurvivalTD] used build_tower")
    local caster = self:GetCaster()
    local player = caster:GetPlayerOwner()

    local tower = player.vTowerQueue
    local towerAttr = GameMode.Towers[tower]

    --[[
    towerAttr current contains these values
    {
        GoldCost   <-- gold cost
        BuildTime  <-- build time
        Level      <-- hero level required to build
        Portrait   <-- "hero" portrait of the unit
    }
    --]]

    -- If there's nothing to build, just return
    if tower == nil then return end

    if caster:GetLevel() < towerAttr.Level then
        -- not high enough level
        return GameMode:PromptError(player, "error_tower_not_unlocked")
    elseif caster:GetGold() < towerAttr.GoldCost then
        -- not enough gold
        return GameMode:PromptError(player, "dota_hud_error_not_enough_gold")
    end

    print("[SurvivalTD] Building tower: '" .. tower .. "'")
    local target = self:GetCursorPosition()

    if not GameMode:IsWithinTeamBounds(caster:GetTeam(), target) then
        return GameMode:PromptError(player, "error_outside_buildgrid")
    end

    print("[SurvivalTD] X: " .. target.x .. " Y: " .. target.y .. " Z: " .. target.z)

    if target.z == GameMode.BuildGridHeight then
        local position = GameMode:SnapToBuildGrid(target)

        -- Build the tower
        if not build_tower:PositionCollides(position) then
            print("[SurvivalTD] Inside build grid")
            
            -- Possible bases:
            --   models/props_structures/urn001_base001.vmdl
            --   models/props_teams/logo_teams_tintable.vmdl
            --local towerPlatform = Entities:CreateByClassname("prop_dynamic")
            --towerPlatform:SetModel("models/props_teams/logo_teams_tintable.vmdl")
            local towerPlatform = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/props_teams/logo_teams_tintable.vmdl"})
            towerPlatform:SetRenderColor(145, 145, 145)
            towerPlatform:SetModelScale(0.40)
            towerPlatform:SetAbsOrigin(GetGroundPosition(position, nil))

            print("[SurvivalTD] Plopping tower: " .. tower)
            local towerUnit = CreateUnitByName(tower, position, false, player, caster, player:GetTeam())
            towerUnit.Platform = towerPlatform
            towerUnit:SetForwardVector(Vector(0, 1, 0 )) -- Face tower north
            towerUnit:SetHullRadius(32.0)                -- Hull Size
            towerUnit:AddAbility("hidden_tower_states")

            --local hiddenAbilities = towerUnit:FindAbilityByName("hidden_tower_states")
            --hiddenAbilities:SetLevel(1)

            --if towerUnit:GetName() == "tower_frost_level_2" then
            --towerUnit:SetMaterialGroup("dragon_blue_color")
            --end

            -- for some reason npc_dota_building is invulnerable by default
            if towerUnit:GetClassname() == "npc_dota_building" then
                towerUnit:RemoveModifierByName("modifier_invulnerable")
            end
            -- Subtract Build cost
            caster:SpendGold(towerAttr.GoldCost, 0)
            EmitSoundOn("Tower.Buy.Coins", towerUnit)
            EmitSoundOn("Tower.Buy.Place", towerUnit)

            -- Show the Build Cost above the tower
            build_tower:PopupMessage(1, towerAttr.GoldCost, nil, towerUnit, player)

            -- make sure all abilities are level 1
            for i=1,15 do 
                local ability = towerUnit:GetAbilityByIndex(i)

                if ability ~= nil then 
                    ability:SetLevel(1)
                end
            end

            build_tower:StartBuild(towerUnit, towerAttr.BuildTime, function() 
                print("[SurvivalTD] Finished building tower")
                towerUnit:SetControllableByPlayer(player:GetPlayerID(), true)
                CustomGameEventManager:Send_ServerToPlayer( player, "tower_built", {tower = tower} )
            end)

        end
    else
        print("[SurvivalTD] Not inside build grid")
    -- error user
    end
end