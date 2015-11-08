"use strict";
var unitSize = 128
  , unitSizeHalf = unitSize >> 1
  , Towers = []
  , TowerGrid = [
    ['tower_archer', 'tower_slow', 'tower_mortar'],
    ['tower_skyfury', 'tower_frost', 'tower_splash', 'tower_boulder'],
    ['tower_lightning', 'tower_deranged'],
    ['tower_berserk', 'tower_halt', 'tower_nova']
  ]
  , GridNodes = []
  ;

var OnAbilityUsed = function() {
    $.Msg('Ability used');
}

var AddTowerToGrid = function(Panel, Tower, tower_name, HeroLevel) {
    var towerNode = $.CreatePanel('Panel', Panel, ''); 
        towerNode.SetAttributeString('tower', tower_name);
        towerNode.SetAttributeString('portrait', Tower.Portrait);
        towerNode.SetAttributeString('hotkey', Tower.Hotkey);
        towerNode.SetAttributeString('AttacksEnabled', Tower.AttacksEnabled);
        towerNode.SetAttributeInt('cost', Tower.GoldCost);
        towerNode.SetAttributeInt('level', Tower.Level);
        towerNode.SetAttributeInt('MinDamage', Tower.AttackDamageMin); 
        towerNode.SetAttributeInt('MaxDamage', Tower.AttackDamageMax);
        towerNode.SetAttributeInt('Range', Tower.AttackRange);
        towerNode.SetHasClass('Unavailable', !!(HeroLevel < Tower.Level));
        towerNode.BLoadLayout('file://{resources}/layout/custom_game/custom_build_menu_tower.xml', false, false);
    GridNodes.push(towerNode);
};

function CreateBuildMenu() {
    var BuildMenuGrid = $('#BuildMenuGrid');
    var HeroLevel = Players.GetLevel(Game.GetLocalPlayerID());

    BuildMenuGrid.RemoveAndDeleteChildren(); 

    for (var row of TowerGrid) {
        if (row.length === 0) continue;

        var GridRow = $.CreatePanel('Panel', BuildMenuGrid, '');
            GridRow.AddClass('TowerGridRow');

        for (var tower_name of row) {
            var tower = Towers[tower_name];

            if (!tower || tower.IsUpgrade) continue;
            AddTowerToGrid(GridRow, tower, tower_name, HeroLevel);
        }
    }
}

function UpdateBuildMenu() {
    for (var towerNode of GridNodes) {
        var HeroLevel = Players.GetLevel(Game.GetLocalPlayerID());
        towerNode.SetHasClass('Unavailable', !!(HeroLevel < towerNode.GetAttributeInt('level', 0)));
    }
}

function TierUpgraded() {
    UpdateBuildMenu();
    /* small timeout to allow for panorama to read the new hero level */
    $.Schedule(0.5, UpdateBuildMenu);
}

/* Initialization */
(function() {

    Towers = g_GameState.Towers;

    //GameEvents.Subscribe('tower_build', OnTowerBuild);
    GameEvents.Subscribe('dota_player_used_ability', OnAbilityUsed);
    GameEvents.Subscribe('tier_upgraded', TierUpgraded);

    /* Initial setup */
    CreateBuildMenu();

}());
/*$('#build_tower_archer').onactivate = function() {

	$.Msg(this);

	GameEvents.SendCustomGameEventToServer( "want_build_tower", { 'tower': 'tower_archer' } );
}*/