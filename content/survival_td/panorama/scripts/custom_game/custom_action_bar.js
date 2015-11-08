"use strict";

var ActionBarUnitPanel = null;

var MakeActionBar = function(Panel) {
  var unitPanel = $.CreatePanel('Panel', Panel, '');

  //unitPanel.SetAttributeInt( 'queryUnit', queryUnit );
  unitPanel.BLoadLayout( 'file://{resources}/layout/custom_game/custom_action_bar_unit.xml', false, false );

  return unitPanel;
};

/*var UpdateActionBar = function() {
  ActionBarUnitPanel.data().SetUnit(queryUnit);
}*/

var MakeSelectionBar = function(Panel, units) {

  /*var isSame = true;
  var lastValue = Entities.GetUnitName(units[0]);*/

  for (var unit of units) {
    //isSame = !!(isSame && lastValue == Entities.GetUnitName(unit));
    var selectionPanel = $.CreatePanel('Panel', Panel, '');
    selectionPanel.SetAttributeInt( 'queryUnit', unit);
    selectionPanel.BLoadLayout('file://{resources}/layout/custom_game/custom_action_bar_portrait.xml', false, false );
  }

  /* create ability panel so we can upgrade all towers simultaniously 
  if (isSame) {

  }*/
};

var MakeBuildMenu = function() {
  var buildMenu = $('#BuildMenu');
  buildMenu.RemoveAndDeleteChildren();
  buildMenu.BLoadLayout( 'file://{resources}/layout/custom_game/custom_build_menu.xml' , false, false);
};

var UpdateActionBar = function() {
  var unitInfo = $('#UnitInfo')
    , UnitPortraitLabel = $('#UnitPortraitLabel')
    , UnitPortraitImage = $('#UnitPortraitImage')
    ;

  if ( !unitInfo )
    return;

  //unitInfo.RemoveAndDeleteChildren();

  var PlayerID = Players.GetLocalPlayer();

  var selectedUnits = Players.GetSelectedEntities(PlayerID);

  if (selectedUnits.length === 1) {
    var queryUnit = Players.GetLocalPlayerPortraitUnit();

    var UnitName = Entities.GetUnitName(queryUnit);
    var UnitNameLocalized = $.Localize(UnitName);

    var PortraitImageSrc = 'file://{resources}/images/custom_game/towers/default.png';

    if (UnitName.startswith('tower_')) {
      PortraitImageSrc = 'file://{resources}/images/custom_game/towers/' + UnitName + '.png';
    } else if (Entities.IsHero(queryUnit)) {
      PortraitImageSrc = 'file://{images}/heroes/' + UnitName + '.png';
    }

    UnitPortraitImage.SetImage(PortraitImageSrc);
    UnitPortraitLabel.text = UnitNameLocalized;

    ActionBarUnitPanel.data().SetUnit(queryUnit);
  } /*else {
    MakeSelectionBar(unitInfo, selectedUnits);
  }*/

};

function UpdateGameInfo() {
  var GoldLabel = $('#PlayerGold');
  var TierLabel = $('#TierLevel');

  var PlayerID = Game.GetLocalPlayerID();
  var playerInfo = Game.GetPlayerInfo( PlayerID );

  GoldLabel.text = playerInfo.player_gold;
  TierLabel.text = playerInfo.player_level;

  $.Schedule(0.1, UpdateGameInfo);
}

function UpdateLives(event) {
  var LivesLabel = $('#PlayerLives');

  LivesLabel.text = event.lives;

  //UpdateGameInfo();
}

(function() {
  MakeBuildMenu();

  ActionBarUnitPanel = MakeActionBar($('#UnitInfo'));

  GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateActionBar );
  GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateActionBar );
  GameEvents.Subscribe( "dota_player_update_query_unit", UpdateActionBar );
  GameEvents.Subscribe( "update_lives", UpdateLives );
  //GameEvents.Subscribe( "tier_upgraded", UpdateGameInfo );

  UpdateGameInfo();
  var $ContextPanel = $.GetContextPanel();

  if (Game.IsHUDFlipped()) {
    $ContextPanel.MoveChildAfter($('#ActionMinimap'), $('#ActionBarContainer'));
  }

  /* pass initial lives show on the HUD */
  UpdateLives({lives: g_GameState.Settings.InitialLives});

  /*GameUI.SetMouseCallback(function(event) {
    $.Msg(GameUI.GetCursorPosition());
    $.Msg(event);
  });*/
})();