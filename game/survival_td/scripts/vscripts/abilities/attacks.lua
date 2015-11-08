-- Acquire valid attackable targets if the target is idle or in Attack-Move state
function AutoAcquire( event )
    local unit = event.target

    if IsValidEntity(unit) and unit:IsIdle() then
        local target = FindAttackableEnemies(unit)
        if target then
            --print(unit:GetUnitName()," now attacking -> ",target:GetUnitName(),"Team: ",target:GetTeamNumber())
            ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), 
                                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, -- DOTA_UNIT_ORDER_MOVE_TO_TARGET
                                TargetIndex = target:GetEntityIndex(), 
                                Queue = false
                            })
            --unit:MoveToTargetToAttack(target)
        end
    end
end

function FindAttackableEnemies( unit )
    local radius = unit.AcquisitionRange
    local enemies = FindEnemiesInRadius( unit, radius )
    local player = unit:GetPlayerOwner()
    local hero = player and player:GetAssignedHero() or nil

    for _,target in pairs(enemies) do
        if UnitCanAttackTarget(unit, target) then --and 
          --((hero and GameMode:IsWithinHeroBounds(hero, target:GetAbsOrigin())) or hero == nil) then -- uncommented for now, since it's unnescessary
            return target
        end
    end
    return nil
end