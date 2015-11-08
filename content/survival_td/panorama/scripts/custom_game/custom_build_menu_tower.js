"use strict";
function TowerBuild() 
{
    var ContextPanel = $.GetContextPanel();

    var towerName = ContextPanel.GetAttributeString('tower', '')
      , towerLevel = ContextPanel.GetAttributeInt('level', -1)
      , towerCost = ContextPanel.GetAttributeInt('cost', -1)
      , heroLevel = Players.GetLevel(Game.GetLocalPlayerID())
      ;

    if (heroLevel < towerLevel) return;

    GameEvents.SendCustomGameEventToServer('build_tower_phase', {tower: towerName});

    /*var Hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
    var Ability = Entities.GetAbilityByName(Hero, 'build_tower');

    Abilities.ExecuteAbility(Ability, Hero, false);*/
}

function TowerShowTooltip()
{
    var ContextPanel = $.GetContextPanel();

    var tower = ContextPanel.GetAttributeString('tower', '');
    var AttacksEnabled = ContextPanel.GetAttributeString('AttacksEnabled', '');
    var MinDamage = ContextPanel.GetAttributeInt('MinDamage', 0);
    var MaxDamage = ContextPanel.GetAttributeInt('MaxDamage', 0);
    var Range = ContextPanel.GetAttributeInt('Range', 0);
    var button = $('#TowerButton');

    var AttackCapability = AttacksEnabled == 'ground' ? 'Ground Only' : 
                          (AttacksEnabled == 'air'    ? 'Air Only'    : 'Ground &amp; Air');

    var text = '<b>' + $.Localize(tower) + '</b><br/>'
             + $.Localize('Damage') + ': ' + ( MinDamage == MaxDamage ? String(MinDamage) : (MinDamage + ' - ' + MaxDamage) ) + '<br/>'
             + $.Localize('Range') + ': ' + Range + '<br/>'
             + $.Localize('Attacks') + ': ' + AttackCapability + '<br/><br/>'
             + $.Localize(tower + '_Description');

    $.DispatchEvent('DOTAShowTextTooltipStyled', text, 'TowerTooltip');
}

function TowerHideTooltip()
{
    var button = $('#TowerButton');
    $.DispatchEvent('DOTAHideTextTooltip', button);
}

function UpdateTowerLayout()
{
    var ContextPanel = $.GetContextPanel()
      , towerCost = $('#TowerCost')
      , towerImage = $('#TowerImage')
      , hotkeyText = $('#TowerHotkeyText')
      ;

    var tower = ContextPanel.GetAttributeString('tower', '');
    var portrait = ContextPanel.GetAttributeString('portrait', '');
    var goldCost = ContextPanel.GetAttributeInt('cost', -1);
    var hotkey   = ContextPanel.GetAttributeString('hotkey', '');

    /*towerImage.heroname = portrait;*/
    towerImage.SetImage('file://{resources}/images/custom_game/towers/' + tower + '.png');
    towerCost.text = String(goldCost);
    hotkeyText.text = hotkey;

    if (hotkey !== "" && ContextPanel.GetAttributeInt('hotkeybound', 0) === 0) {
      Game.AddCommand( "+CustomBuild_" + tower, TowerBuild, "", 0 );
      ContextPanel.SetAttributeInt('hotkeybound', 1);
    }
}

(function() {
    UpdateTowerLayout();
})();