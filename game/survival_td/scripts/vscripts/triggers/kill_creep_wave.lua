function EndPointTouch(trigger)
    local wave_class_name = "npc_dota_creep_lane"


    print("[SurvivalTD] Touched endpoint")
    local caller = trigger.caller
    local activator = trigger.activator
    local UnitName = activator:GetUnitName()

    print("[SurvivalTD] creep died: " .. UnitName)

    if not activator:GetClassname() == wave_class_name or (not UnitName == "creep_wave_19") then return end

    local team = GameMode:GetTeamOwningArea(caller:GetAbsOrigin())
    local strTeamID = tostring(team)

    if team and activator:IsAlive() then

        local lives = GameMode.TeamLives[strTeamID]

        if lives > 0 then
            local lifeCount = GameMode:IsBossWave(UnitName) and 3 or 1
            lives = lives - lifeCount

            if UnitName == ("creep_wave_" .. GameMode.TotalRounds) then
                for _,player in pairs(GameMode:GetPlayersOnTeam(team)) do
                    local hero = player:GetAssignedHero()
                    hero.killedLastWave = true
                end
                GameMode:CheckGameOver()
            end

            -- save the lives of the player
            GameMode.TeamLives[strTeamID] = lives
            CustomNetTables:SetTableValue( "game_state", "lives", GameMode.TeamLives)

            for _,player in pairs(GameMode:GetPlayersOnTeam(team)) do
                -- Send event to update the UI
                CustomGameEventManager:Send_ServerToPlayer( player, "update_lives", {lives = lives} )
                if lives <= 0 then
                    GameMode:PromptError(player, "message_player_dead", "Player.Lost.Life")
                    GameMode:OnGameOver(player)
                else
                    GameMode:PromptError(player, "You just lost a life! " .. lives .. " Remaining", "Player.Lost.Life")
                end
            end
        end
        
        activator:Kill(nil, activator)
    end
end