-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require("statcollection/init")
require('internal/util')
require('gamemode')

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  -- Particles can be precached individually or by folder
  -- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
  PrecacheResource("particle", "particles/econ/generic/generic_aoe_explosion_sphere_1/generic_aoe_explosion_sphere_1.vpcf", context)
  --PrecacheResource("particle", "particles/econ/items/kunkka/kunkka_torrent_base/kunkka_spell_torrent_splash_econ.vpcf", context)
  PrecacheResource("particle_folder", "particles/test_particle", context)
  --PrecacheResource("particle_folder", "particles/ui_mouseactions/square_sprite.vpcf", context)
  PrecacheResource("particle_folder", "particles/ui_mouseactions", context)

  -- Models can also be precached by folder or individually
  -- PrecacheModel should generally used over PrecacheResource for individual models
  --PrecacheResource("model_folder", "particles/heroes/antimage", context)
  --PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  --PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
  --PrecacheModel("models/heroes/viper/viper.vmdl", context)
  PrecacheModel("models/error.vmdl", context)
  PrecacheModel("models/props_teams/logo_teams_tintable.vmdl", context)

  -- Sounds can precached here like anything else
  PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context)

  -- Entire items can be precached by name
  -- Abilities can also be precached in this way despite the name
  --PrecacheItemByNameSync("example_ability", context)
  PrecacheItemByNameSync("build_tower", context)
  PrecacheItemByNameSync("sell_tower", context)
  PrecacheItemByNameSync("upgrade_tier", context)
  --PrecacheItemByNameSync("item_example_item", context)

  -- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
  -- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
  --PrecacheUnitByNameSync("npc_dota_hero_ancient_apparition", context)
  --PrecacheUnitByNameSync("npc_dota_hero_enigma", context)
  PrecacheUnitByNameSync("meepo_dummy_unit", context)

  PrecacheUnitByNameSync("npc_dota_hero_omniknight", context)

  -- Towers
  PrecacheUnitByNameSync("tower_archer", context)
  PrecacheUnitByNameSync("tower_archer_level_2", context)
  PrecacheUnitByNameSync("tower_archer_level_3", context)
  PrecacheUnitByNameSync("tower_slow", context)
  PrecacheUnitByNameSync("tower_slow_level_2", context)
  PrecacheUnitByNameSync("tower_mortar", context)
  PrecacheUnitByNameSync("tower_mortar_level_2", context)
  PrecacheUnitByNameSync("tower_mortar_level_3", context)
  PrecacheUnitByNameSync("tower_mortar_level_4", context)
  PrecacheUnitByNameSync("tower_splash", context)
  PrecacheUnitByNameSync("tower_splash_level_2", context)
  PrecacheUnitByNameSync("tower_frost", context)
  PrecacheUnitByNameSync("tower_frost_level_2", context)
  PrecacheUnitByNameSync("tower_lightning", context)
  PrecacheUnitByNameSync("tower_lightning_level_2", context)
  PrecacheUnitByNameSync("tower_skyfury", context)
  PrecacheUnitByNameSync("tower_skyfury_level_2", context)
  PrecacheUnitByNameSync("tower_boulder", context)
  PrecacheUnitByNameSync("tower_boulder_level_2", context)
  PrecacheUnitByNameSync("tower_deranged", context)
  PrecacheUnitByNameSync("tower_berserk", context)
  PrecacheUnitByNameSync("tower_halt", context)
  PrecacheUnitByNameSync("tower_nova", context)

  -- Waves
  -- npc_dota_creep_badguys_melee

  -- Precache the creep waves
  for i=1,34 do
    PrecacheUnitByNameAsync("creep_wave_" .. i, context)
  end
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:InitGameMode()
end