-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

require('mechanics')
-- "preload" the upgrade tower ability, so we can extend that in other upgrade abilities
require('abilities/upgrade_tower')


--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

function GameMode:PromptError(player, message, sound)
  sound = sound or "General.CantAttack"
  EmitSoundOnClient(sound, player)
  CustomGameEventManager:Send_ServerToPlayer( player, "custom_error_message", {message = message} )
end

function GameMode:IsWithinTeamBounds(team, position)
  local bounds = GameMode.TeamBoundaries[team]

  if bounds then
    return (bounds.nw and bounds.se and
            position.x > bounds.nw.x and position.x < bounds.se.x and 
            position.y < bounds.nw.y and position.y > bounds.se.y)
  end
  return false
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  local player = hero:GetPlayerOwner()

  if player == nil then return end

  --local EntPlayerID = GameMode.TeamToEntPlayer[player:GetTeam()]

  DebugPrint("setting tower queue")
  player.vTowerQueue = nil

  DebugPrint("setting initial gold")
  -- This line for example will set the starting gold of every hero to 100 unreliable gold
  hero:SetGold(GameMode.InitialGold, false)

  -- apply physics
  Physics:Unit(hero)
  DebugPrint("adding modifier")
  hero:AddNewModifier(hero, nil, "modifier_movespeed_cap", {})
  DebugPrint("setting auto unstuck")
  hero:SetAutoUnstuck(false)
  DebugPrint("setting ground behavior")
  hero:SetGroundBehavior(PHYSICS_GROUND_NOTHING)
  DebugPrint("setting nav collission type")
  hero:SetNavCollisionType(PHYSICS_NAV_NONE)

  DebugPrint("setting hero killed last wave")

  hero.killedLastWave = false

  --if EntPlayerID then

  --  local ent_bounds_ne = Entities:FindByName(nil, "player" .. EntPlayerID .. "_bound_ne"):GetAbsOrigin()
  --  local ent_bounds_sw = Entities:FindByName(nil, "player" .. EntPlayerID .. "_bound_sw")

  --  hero.bounds_ne = ent_bounds_ne:GetAbsOrigin()
  --  hero.bounds_sw = ent_bounds_sw:GetAbsOrigin()
  --end

  DebugPrint("creating timer")
  Timers:CreateTimer(function() 
    local position = hero:GetAbsOrigin()
    hero:SetAbsOrigin(Vector(position.x, position.y, 500))
    return .03
  end) 

  DebugPrint("leveling abilities")

  local buildAbility = hero:FindAbilityByName("build_tower")
  local upgradeAbility = hero:FindAbilityByName("upgrade_tier")
  local invincibilityAbility = hero:FindAbilityByName("custom_ability_invincibility")
  --hero:UpgradeAbility(buildAbility)

  if buildAbility ~= nil then buildAbility:SetLevel(1) end
  if upgradeAbility ~= nil then upgradeAbility:SetLevel(1) end
  if invincibilityAbility ~= nil then invincibilityAbility:SetLevel(1) end

  DebugPrint("resetting ability points")
  hero:SetAbilityPoints(0)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

function GameMode:SnapToBuildGrid(target)
    local UnitWidth       = 128
    local UnitWidthHalf   = UnitWidth / 2

    local x = UnitWidthHalf * math.floor((target.x + 0.5) / UnitWidthHalf) + (UnitWidthHalf / 2)
    local y = UnitWidthHalf * math.floor((target.y + 0.5) / UnitWidthHalf) + (UnitWidthHalf / 2)

    local pos = Vector(x, y, GameMode.BuildGridHeight)

    --[[DebugDrawBox(
        pos, 
        Vector(-UnitWidthHalf, -UnitWidthHalf, 0), --Vector(pos.x - 32, pos.y - 32, pos.z), 
        Vector(UnitWidthHalf, UnitWidthHalf, UnitWidthHalf), --Vector(pos.x + 32, pos.y + 32, pos.z + 32),
        200, 0, 0, 5,
        1.0
    )--]]

    return pos
end

function GameMode:IsFlyingWave(wave)
  for i=0,#GameMode.FlyingWaves do
    if GameMode.FlyingWaves[i] == wave then
      return true
    end
  end
  return false
end

function GameMode:IsBossWave(wave)
  for i=0,#GameMode.BossWaves do
    if GameMode.BossWaves[i] == wave then
      return true
    end
  end
  return false
end

function GameMode:SpawnCreepWave(unit, player, round)

  local round = round or 0

  local EntTeamID = GameMode.TeamToEntTeam[player:GetTeam()]
  local strTeamID = tostring(player:GetTeam())

  local spawn = Entities:FindByName(nil, "player" .. EntTeamID .. "_wavespawner")
  local waypoint = Entities:FindByName(nil, "player" .. EntTeamID .. "_waypoint1")
  local spawnLocation = spawn:GetAbsOrigin()

  local i = 0
  -- Only spawn one unit if it's a boss wave
  local creepCount = (not GameMode:IsBossWave(unit)) and GameMode.CreepCount or 1

  local healthMultiplier = GameMode.DifficultyHealth[ GameMode.TeamDifficulty[strTeamID] ]

  Timers:CreateTimer(function()

    if i < creepCount then
      local creep = CreateUnitByName(unit, spawnLocation, true, nil, nil, DOTA_TEAM_NOTEAM)

      -- difficulty level doesnt kick in until level 3
      if round > 2 and healthMultiplier > 1.0 then
        local health = creep:GetBaseMaxHealth() * healthMultiplier
        creep:SetBaseMaxHealth(health)
        creep:SetMaxHealth(health)
        creep:SetHealth(health)
      end

      creep:SetForwardVector(Vector(-1, 0, 0)) -- make the creeps point west when spawning
      creep:SetInitialGoalEntity(waypoint)

      i = i + 1
      return .5
    end
  end)
end

function GameMode:FormatWaveAnnounce(wave)
  local isBoss = GameMode:IsBossWave(wave)
  local isFlying = GameMode:IsFlyingWave(wave)

  return string.format("<font color=\"#00aeff\">%s</font>%s%s",
    wave,
    (isBoss and " (<font color=\"#be7fe5\">Boss</font>)" or ""),
    (isFlying and " (<font color=\"#ff8800\">Flying</font>)" or "")
  )
end

function GameMode:SpawnNextWave(team, delay)
  local delay = delay or 0

  local heroes = HeroList:GetAllHeroes()

  local EntTeamID = GameMode.TeamToEntTeam[team]
  local strTeamID = tostring(team)

  print("[SurvivalTD] " ..strTeamID)

  local waveInfo = GameMode.WaveInfo[strTeamID]

  if not waveInfo then return end

  local CurrentGameTime = GameRules:GetGameTime()

  waveInfo.Round = waveInfo.Round + 1

  local CurrentRound = waveInfo.Round

  if CurrentRound > GameMode.TotalRounds then return end

  waveInfo.UnitName = "creep_wave_" .. CurrentRound
  waveInfo.Count = (not GameMode:IsBossWave(waveInfo.UnitName)) and GameMode.CreepCount or 1

  local NextRoundName = "creep_wave_" .. (CurrentRound + 1)

  CustomNetTables:SetTableValue( "game_state", "teamstate", GameMode.WaveInfo )

  --if GameMode:IsFlyingWave(NextRoundName) then
  --  GameRules:SendCustomMessage("Next Round is Air! - Build some air towers now if you haven't already", 1, 1)
  --elseif GameMode:IsBossWave(NextRoundName) then
  --  GameRules:SendCustomMessage("Next Round is a boss wave! Only one enemy, but huge bounty", 1, 1)
  --end

  local IsNextFlying = GameMode:IsFlyingWave(NextRoundName)
  local IsNextBoss   = GameMode:IsBossWave(NextRoundName)

  -- Next round starts

  -- make sure we don't go past the previous nextroundtime
  if waveInfo.NextRoundTime > 0 and ((CurrentGameTime + delay) > waveInfo.NextRoundTime) then
    delay = (CurrentGameTime + delay) - waveInfo.NextRoundTime
  end

  Timers:CreateTimer(delay, function()
    
    waveInfo.NextRoundTime = CurrentGameTime + GameMode.RoundTime

    for _,player in pairs(GameMode:GetPlayersOnTeam(team)) do

      local hero = player:GetAssignedHero()

      if hero and hero:IsAlive() then
        -- the builder starts with the initial gold for round 1
        print("[SurvivalTD] Checking if round is above one")
        if CurrentRound > 1 then
          hero:SetGold(hero:GetGold() + GameMode.GoldPerRound, false)
        end
        -- Spawn the wave
        print("[SurvivalTD] Spawning the wave")
        GameMode:SpawnCreepWave(waveInfo.UnitName, player, CurrentRound)

        if IsNextFlying or IsNextBoss then
          CustomGameEventManager:Send_ServerToPlayer( player, "team_notification", {
            message = IsNextFlying and "custom_game_next_wave_flying" or "custom_game_next_wave_boss"
          })

          if NextRoundName == GameMode.FlyingWaves[1] then
            CustomGameEventManager:Send_ServerToPlayer( player, "team_notification", {
              message = IsNextFlying and "custom_game_next_wave_flying_tip"
            })
          end

          if NextRoundName == GameMode.BossWaves[1] then
            CustomGameEventManager:Send_ServerToPlayer( player, "team_notification", {
              message = IsNextFlying and "custom_game_next_wave_boss_tip"
            })
          end
        end

        CustomGameEventManager:Send_ServerToPlayer( player, "wave_notification", {UnitName = waveInfo.UnitName, Round = CurrentRound} )

        print("[SurvivalTD] sending next_round_timer to client JS")

        CustomGameEventManager:Send_ServerToPlayer( player, "next_round_timer", {
          time = waveInfo.NextRoundTime, 
          round = CurrentRound, 
          roundtime = GameMode.RoundTime
        })
      end
    end
  end)

  -- Start a timer that will spawn the next wave

  print("[SurvivalTD] Starting timer for next wave")

  -- make sure the next wave isn't invoked elsewhere
  local TimerRound = CurrentRound

  Timers:CreateTimer(GameMode.RoundTime, function()
    local info = GameMode.WaveInfo[strTeamID]

    if TimerRound == info.Round then
      print("[SurvivalTD] timer expired .. spawning next wave")
      GameMode:SpawnNextWave(team)
    end
  end)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  GameRules:SendCustomMessage("#chat_command_info", 1, 1)

  -- loop over the teams and start their initial waves
  for team=DOTA_TEAM_FIRST, DOTA_TEAM_COUNT do
    local EntTeam = GameMode.TeamToEntTeam[team]
    if EntTeam then
      GameMode:SpawnNextWave(team)
    end
  end
  
  Timers:CreateTimer(0, function()
    -- Set time of day to keep it sunny all the time
    GameRules:SetTimeOfDay(0.5)

    return 30.0 -- Rerun this timer every 30 game-time seconds 
  end)
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()

  GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( GameMode, 'FilterExecuteOrder' ), self)

  LinkLuaModifier("modifier_movespeed_cap", "abilities/modifier_movespeed_cap", LUA_MODIFIER_MOTION_NONE)

  -- Constants for difficulty
  GameMode.DIFFICULTY_EASY = 0
  GameMode.DIFFICULTY_NORMAL = 1
  GameMode.DIFFICULTY_HARD = 2

  GameMode.DifficultyHealth = {
    [GameMode.DIFFICULTY_EASY]   = 1.0, -- 100%
    [GameMode.DIFFICULTY_NORMAL] = 1.1, -- 110%
    [GameMode.DIFFICULTY_HARD]   = 1.2  -- 120%
  }

  -- entities in the map are named by player id's, but we want to reference them by team
  GameMode.TeamToEntTeam = {
    [DOTA_TEAM_GOODGUYS] = 0,
    [DOTA_TEAM_BADGUYS]  = 1,
    [DOTA_TEAM_CUSTOM_1] = 2,
    [DOTA_TEAM_CUSTOM_2] = 3,
    [DOTA_TEAM_CUSTOM_3] = 4,
    [DOTA_TEAM_CUSTOM_4] = 5,
    [DOTA_TEAM_CUSTOM_5] = 6,
    [DOTA_TEAM_CUSTOM_6] = 7,
    [DOTA_TEAM_CUSTOM_7] = 8,
    [DOTA_TEAM_CUSTOM_8] = 9
  }

  -- Initial Variables
  GameMode.CurrentRound = 0
  GameMode.InitialLives = 10
  GameMode.RoundTime    = 65
  GameMode.FastSpawnDelay = 15
  GameMode.InitialGold  = 100
  GameMode.GoldPerRound = 55
  GameMode.CreepCount   = 16
  GameMode.TotalRounds  = 34
  GameMode.CreepTeam    = DOTA_TEAM_CUSTOM_8
  GameMode.GameWinner   = GameMode.CreepTeam
  GameMode.FlyingWaves  = {"creep_wave_8", "creep_wave_14", "creep_wave_20", "creep_wave_26", "creep_wave_29"}
  GameMode.BossWaves    = {"creep_wave_9", "creep_wave_19", "creep_wave_34"}


  GameMode.TeamLives  = {
    [tostring(DOTA_TEAM_GOODGUYS)] = GameMode.InitialLives,
    [tostring(DOTA_TEAM_BADGUYS)]  = GameMode.InitialLives,
    [tostring(DOTA_TEAM_CUSTOM_1)] = GameMode.InitialLives,
    [tostring(DOTA_TEAM_CUSTOM_2)] = GameMode.InitialLives
  }

  GameMode.TeamDifficulty = {
    [tostring(DOTA_TEAM_GOODGUYS)] = GameMode.DIFFICULTY_EASY,
    [tostring(DOTA_TEAM_BADGUYS)]  = GameMode.DIFFICULTY_EASY,
    [tostring(DOTA_TEAM_CUSTOM_1)] = GameMode.DIFFICULTY_EASY,
    [tostring(DOTA_TEAM_CUSTOM_2)] = GameMode.DIFFICULTY_EASY
  }

  GameMode.WaveInfo = {
    [tostring(DOTA_TEAM_GOODGUYS)] = {Round = 0, Count = 0, UnitName = "", NextRoundTime = 0},
    [tostring(DOTA_TEAM_BADGUYS)]  = {Round = 0, Count = 0, UnitName = "", NextRoundTime = 0},
    [tostring(DOTA_TEAM_CUSTOM_1)] = {Round = 0, Count = 0, UnitName = "", NextRoundTime = 0},
    [tostring(DOTA_TEAM_CUSTOM_2)] = {Round = 0, Count = 0, UnitName = "", NextRoundTime = 0}
  }

  local GetBoundaryEntityPos = (function(team, corner)
    local entTeamID = GameMode.TeamToEntTeam[team]
    local ent_bounds = Entities:FindByName(nil, "team" .. entTeamID .. "_bound_" .. corner)

    if IsValidEntity(ent_bounds) then
      return ent_bounds:GetAbsOrigin()
    else
      return Vector(0,0,0)
    end
  end)

  GameMode.TeamBoundaries = {
    [DOTA_TEAM_GOODGUYS] = {
        nw = GetBoundaryEntityPos(DOTA_TEAM_GOODGUYS, "nw"),
        se = GetBoundaryEntityPos(DOTA_TEAM_GOODGUYS, "se")
    },
    [DOTA_TEAM_BADGUYS]  = {
        nw = GetBoundaryEntityPos(DOTA_TEAM_BADGUYS, "nw"),
        se = GetBoundaryEntityPos(DOTA_TEAM_BADGUYS, "se")
    },
    [DOTA_TEAM_CUSTOM_1] = {
        nw = GetBoundaryEntityPos(DOTA_TEAM_CUSTOM_1, "nw"),
        se = GetBoundaryEntityPos(DOTA_TEAM_CUSTOM_1, "se")
    },
    [DOTA_TEAM_CUSTOM_2] = {
        nw = GetBoundaryEntityPos(DOTA_TEAM_CUSTOM_2, "nw"),
        se = GetBoundaryEntityPos(DOTA_TEAM_CUSTOM_2, "se")
    }
  }

  GameMode.BuildGridHeight = 256

  -- Loading tower values

  GameMode.Towers = {}
  local UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

  print("[SurvivalTD] Initializing Build_Tower: ")

  for key,value in pairs(UnitKV) do

      if key:find("tower_") then
          GameMode.Towers[key] = {
            GoldCost  = value.GoldCost or 10,
            BuildTime = value.BuildTime or 1,
            Level     = value.RequiresLevel or 0,
            Hotkey    = value.Hotkey or "",
            Portrait  = value.Portrait or "",
            AttackDamageMin = value.AttackDamageMin or 0,
            AttackDamageMax = value.AttackDamageMax or 0,
            AttackRange = value.AttackRange or 0,
            IsUpgrade = (value.IsUpgrade == 1) or false,
            AttacksEnabled = value.AttacksEnabled or "ground,air"
          }
          --CustomNetTables:SetTableValue( "towers", key, GameMode.Towers[key] );
          print(string.format("[SurvivalTD] Tower: %q Costs: %i", key, value.GoldCost))
      end

      --build_tower.vGoldCosts[]
  end

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "spawn_wave", Dynamic_Wrap(GameMode, 'SpawnWaveConsoleCommand'), "A console command example", FCVAR_CHEAT )

  --local OutOfWorldVector = Vector(11000,11000,0)

  CustomGameEventManager:RegisterListener( "build_tower_cast", function(eventSourceIndex, args)
    local player = PlayerResource:GetPlayer(args.PlayerID)

    if not player.vTowerQueue then return end

    local hero = player:GetAssignedHero()
    if hero == nil then return end

    local ability = hero:FindAbilityByName("build_tower")
    if ability == nil then return end

    print("[SurvivalTD] build tower cast")

    local position = Vector(args.position['0'], args.position['1'], args.position['2'])

    hero:CastAbilityOnPosition(position, ability, args.PlayerID)
  end)

  CustomGameEventManager:RegisterListener( "build_tower_cancel", function(eventSourceIndex, args)
    local player = PlayerResource:GetPlayer(args.PlayerID)

    player.vTowerQueue = nil
  end)

  CustomGameEventManager:RegisterListener( "build_tower_phase", function(eventSourceIndex, args)
    local player = PlayerResource:GetPlayer(args.PlayerID)

    if args.tower == nil then return end

    local tower = args.tower

    local towerAttr = GameMode.Towers[tower]

    local AttackRange = towerAttr and towerAttr.AttackRange or 0
    -- Dummy function, it just returns the first key from the table given
    --local tower = (function( t ) for k,v in pairs(t) do return k; end end)(args.tower)

    print("Builder wants to build tower: " .. tower)

    player.vTowerQueue = tower
    --player.vTowerUnit  = CreateUnitByName(tower, OutOfWorldVector, false, nil, nil, player:GetTeam())

    --CustomGameEventManager:Send_ServerToPlayer(player, "building_helper_enable", {["state"] = "active", ["size"] = size, ["entIndex"] = player.mgd:GetEntityIndex(), ["MaxScale"] = fMaxScale} )
    --CustomGameEventManager:Send_ServerToPlayer(player, "build_tower_ghost_enable", {["state"] = "active", ["size"] = 256, ["entIndex"] = player.vTowerUnit:GetEntityIndex(), ["MaxScale"] = 256} )
    CustomGameEventManager:Send_ServerToPlayer(player, "build_tower_ghost_enable", {AttackRange = AttackRange})
  end)

  -- custom units do not supporting casting lua abilities for whatever reason
  local CastUnitAbilityFix = (function(eventSourceIndex, args)
    local player = PlayerResource:GetPlayer(args.PlayerID)
    local abilityIndex = args.ability
    local unitIndex    = args.unit

    ExecuteOrderFromTable({
      UnitIndex = unitIndex,
      OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
      AbilityIndex = abilityIndex
    })
  end)

  local PlayerChangedDifficulty = (function(eventSourceIndex, args)

    if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
      local player = PlayerResource:GetPlayer(args.PlayerID)
      strTeamID = tostring(player:GetTeam())

      local difficulty = args.difficulty

      if difficulty == GameMode.DIFFICULTY_EASY or difficulty == GameMode.DIFFICULTY_NORMAL or difficulty == GameMode.DIFFICULTY_HARD then
        GameMode.TeamDifficulty[strTeamID] = difficulty
        CustomNetTables:SetTableValue( "game_state", "difficulty", GameMode.TeamDifficulty )
      end
    end

  end)

  --CustomGameEventManager:RegisterListener( "sell_tower", CastUnitAbilityFix )
  --CustomGameEventManager:RegisterListener( "upgrade_tower", CastUnitAbilityFix )
  CustomGameEventManager:RegisterListener( "player_changed_difficulty", PlayerChangedDifficulty )

  CustomNetTables:SetTableValue( "game_state", "towers", GameMode.Towers )
  CustomNetTables:SetTableValue( "game_state", "settings", {
    InitialLives = GameMode.InitialLives,
    FlyingWaves  = GameMode.FlyingWaves,
    BossWaves    = GameMode.BossWaves,
    TotalRounds  = GameMode.TotalRounds,
    BuildGridHeight = GameMode.BuildGridHeight,
    TierCosts    = {40, 80, 120, 0} -- Upgrade cost of level 2,3,4
  })

  CustomNetTables:SetTableValue( "game_state", "lives", GameMode.TeamLives)
  CustomNetTables:SetTableValue( "game_state", "difficulty", GameMode.TeamDifficulty)
  CustomNetTables:SetTableValue( "game_state", "teamstate", GameMode.WaveInfo)

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

-- Gets the team owning the current area or nil
function GameMode:GetTeamOwningArea(position)
  --local heroes = HeroList:GetAllHeroes()

  --for _,hero in pairs(heroes) do
  --  if (GameMode:IsWithinTeamBounds(hero, position)) then 
  --    return hero:GetPlayerOwner() 
  --  end
  --end

  for team=DOTA_TEAM_FIRST, DOTA_TEAM_COUNT do
    local EntTeam = GameMode.TeamToEntTeam[team]
    if EntTeam and GameMode:IsWithinTeamBounds(team, position) then
      return team
    end
  end

  return nil
end

function GameMode:GetPlayersOnTeam(team)
  local playerCount = PlayerResource:GetPlayerCountForTeam(team)

  local players = {}

  if playerCount > 0 then
    for i=1,playerCount do

      local PlayerID = PlayerResource:GetNthPlayerIDOnTeam(team, i)

      if PlayerResource:IsValidPlayerID(PlayerID) then
        table.insert(players, PlayerResource:GetPlayer(PlayerID))
      end
    end
  end

  --if playerCount > 0 then
  --  local i = 0
  --  return (function()
  --    i = i + 1
  --    local PlayerID = PlayerResource:GetNthPlayerIDOnTeam(team, i)
  --
  --    if i <= playerCount and PlayerResource:IsValidPlayerID(PlayerID) then 
  --      return PlayerResource:GetPlayer(PlayerID)
  --    end
  --  end)
  --end

  return players
end

-- Triggers when a player has lost all of his lives
function GameMode:OnGameOver(player)
  print("[SurvivalTD] game is over for player ..")

  local hero = player:GetAssignedHero()

  local units = FindUnitsInRadius(
    hero:GetTeamNumber(),   -- team number
    hero:GetAbsOrigin(),    -- radius around builder
    nil,                    -- cacheUnit
    FIND_UNITS_EVERYWHERE,  -- radius
    DOTA_UNIT_TARGET_TEAM_FRIENDLY, -- teamFilter
    DOTA_UNIT_TARGET_ALL, -- type filter
    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 
    FIND_ANY_ORDER, -- order
    false -- canGrowCache
  )

  for _,unit in pairs(units) do
    if unit:IsAlive() then
      unit:ForceKill(false)
    end
  end

  if hero:IsAlive() then
    hero:ForceKill(false)
  end

  GameMode:CheckGameOver()
end

-- Check if all players are dead, and then end the game
function GameMode:CheckGameOver()
  local heroes = HeroList:GetAllHeroes()

  for _,hero in pairs(heroes) do
    if hero:IsAlive() and not hero.killedLastWave then
      return
    end
  end

  GameRules:SendCustomMessage("Game will end in 20 seconds", 1, 1)

  GameMode:TriggerGameEnd(20.0)
end

function GameMode:TriggerGameEnd(timeout)
  timeout = timeout or 30.0

  Timers:CreateTimer(timeout, function()
    GameRules:SetGameWinner(GameMode.GameWinner)
  end)

end

function GameMode:WantBuildTower()
  print("want build tower")

  --Abilities.ExecuteAbility( integer nAbilityEntIndex, integer nCasterEntIndex, boolean bIsQuickCast )
end

function GameMode:SpawnWaveConsoleCommand(...)
  local args = {...}

  local wave = args[1] or "creep_wave_1"

  print("[SurvivalTD] Spawning creep wave: " .. wave)

  local cmdPlayer = Convars:GetCommandClient()

  GameMode:SpawnCreepWave(wave, cmdPlayer, 0)

end

function GameMode:FilterExecuteOrder( filterTable )
    local units = filterTable["units"]
    local order_type = filterTable["order_type"]
    local issuer = filterTable["issuer_player_id_const"]
    local abilityIndex = filterTable["entindex_ability"]
    local targetIndex = filterTable["entindex_target"]
    local x = tonumber(filterTable["position_x"])
    local y = tonumber(filterTable["position_y"])
    local z = tonumber(filterTable["position_z"])
    local point = Vector(x,y,z)

    -- Skip Prevents order loops
    if units["0"] == nil then return true end

    local unit = EntIndexToHScript(units["0"])
    if unit and unit.skip then
        unit.skip = false
        return true
    end

    if order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
      local target = EntIndexToHScript(targetIndex)
      local errorMsg = nil

      for n, unit_index in pairs(units) do 
        local unit = EntIndexToHScript(unit_index)
        local player = unit:GetPlayerOwner()
        local hero = player and player:GetAssignedHero() or nil

        if UnitCanAttackTarget(unit, target) then --and 
          --((hero and GameMode:IsWithinHeroBounds(hero, target:GetAbsOrigin())) or hero == nil) then -- uncommented for now, since it's unnescessary

          unit.skip = true
          ExecuteOrderFromTable({ UnitIndex = unit_index, OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET, TargetIndex = targetIndex, Queue = 0})
        else
          -- stop idle acquire
          unit:SetIdleAcquire(false)
          ExecuteOrderFromTable({ UnitIndex = unit_index, OrderType = DOTA_UNIT_ORDER_STOP, Queue = 0})

          if not errorMsg then
            local target_type = GetMovementCapability(target)

            if target_type == "air" then
              GameMode:PromptError(player, "error_cant_attack_air")
            elseif target_type == "ground" then
              GameMode:PromptError(player, "error_cant_attack_ground")
            end

            errorMsg = true
          end
        end
      end

      errorMsg = nil
      return false
    end

    return true
end
