-- Air/Ground attack gracefully "borrowed" from DotaCraft: github.com/MNoya/DotaCraft/

function findNewEnemyInRadius(Team, Origin, AttackRange, Test)
    local enemies = FindUnitsInRadius(
        Team, 
        Origin, 
        nil, 
        AttackRange, 
        DOTA_UNIT_TARGET_TEAM_ENEMY, 
        DOTA_UNIT_TARGET_BASIC, 
        DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_CLOSEST,
        false
    )

    for _,enemy in pairs(enemies) do
        if Test(enemy) then
            return enemy
        end
    end

    return nil
end

-- When the unit tries to attack a flying unit, disable it
function PreventFlyingAttack( event )
    local target = event.target -- The target of the attack
    local attacker = event.attacker

    if target and target:HasFlyMovementCapability() then

        local newTarget = findNewEnemyInRadius(
            attacker:GetTeamNumber(), 
            attacker:GetAbsOrigin(),
            attacker:GetAttackRange(),
            (function(unit) return not unit:HasFlyMovementCapability() end)
        )

        if not newTarget then
            --if not attacker:HasModifier("modifier_disarmed") then
            --    attacker:AddNewModifier(attacker, nil, "modifier_disarmed", {})
            --end
            return attacker:Stop()
        end

        --if attacker:HasModifier("modifier_disarmed") then
        --    attacker:RemoveModifierByName("modifier_disarmed")
        --end
        -- Send a move-to-target order.
        -- Could also be a move-aggresive/swap target so it still attacks other valid targets
        ExecuteOrderFromTable({ UnitIndex = attacker:GetEntityIndex(), 
                                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, -- DOTA_UNIT_ORDER_MOVE_TO_TARGET
                                TargetIndex = newTarget:GetEntityIndex(), 
                                Queue = false
                            }) 
    end
end

-- When the unit tries to attack a ground unit, disable it
function PreventGroundAttack( event )
    local target = event.target -- The target of the attack
    local attacker = event.attacker

    if target and target:HasGroundMovementCapability() then

        local newTarget = findNewEnemyInRadius(
            attacker:GetTeamNumber(), 
            attacker:GetAbsOrigin(),
            attacker:GetAttackRange(),
            (function(unit) return not unit:HasGroundMovementCapability() end)
        )

        if not newTarget then 
            --if not attacker:HasModifier("modifier_disarmed") then
            --    attacker:AddNewModifier(attacker, nil, "modifier_disarmed", {})
            --end
            return attacker:Stop()
        end

        --if attacker:HasModifier("modifier_disarmed") then
        --    attacker:RemoveModifierByName("modifier_disarmed")
        --end

        -- Send an attack order.
        ExecuteOrderFromTable({ UnitIndex = attacker:GetEntityIndex(), 
                                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, -- DOTA_UNIT_ORDER_MOVE_TO_TARGET
                                TargetIndex = newTarget:GetEntityIndex(), 
                                Queue = false
                            }) 
    end
end