"use strict";

var Unit = -1;
var _AbilityPanels = [];
var ABILITY_MAX_COUNT = 16; /* number of ability panels to generate */

function MakeAbilityPanel( abilityListPanel )
{
	var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "" );
	//abilityPanel.SetAttributeInt( "ability", ability );
	//abilityPanel.SetAttributeInt( "queryUnit", queryUnit );
	abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/custom_action_bar_ability.xml", false, false );
	return abilityPanel;
}

function UpdateAbilityList()
{
	var abilityListPanel = $( "#ability_list" );
	if ( !abilityListPanel )
		return;

	//abilityListPanel.RemoveAndDeleteChildren();

	for ( var i = 0; i < _AbilityPanels.length; i++)
	{
		var ability = Entities.GetAbility( Unit, i);

		_AbilityPanels[i].data().SetData(Unit, Entities.GetAbility( Unit, i ));
	}
	/*for ( var i = 0; i < Entities.GetAbilityCount( Unit ); ++i )
	{
		var ability = Entities.GetAbility( Unit, i );
		if ( ability == -1 )
			continue;

		if ( Abilities.IsHidden(ability) || Abilities.GetAbilityType(ability) == ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES )
			continue;

		if ( Abilities.GetAbilityName(ability) == 'build_tower' )
			continue;
		
		AbilityPMakeAbilityPanel( abilityListPanel, ability, Unit );
	}*/
}

function MakeAbilityPanels() {
	var abilityListPanel = $( "#ability_list" );
	if ( !abilityListPanel ) return;

	abilityListPanel.RemoveAndDeleteChildren();

	for (var i = 0; i < ABILITY_MAX_COUNT; i++) {
		_AbilityPanels[i] = MakeAbilityPanel(abilityListPanel); 
	}
}

function SetUnit(queryUnit) {
	Unit = queryUnit;
	UpdateAbilityList();
}

(function()
{
	$.GetContextPanel().data().SetUnit = SetUnit;

	MakeAbilityPanels();

	GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateAbilityList );
	
	UpdateAbilityList(); // initial update
})();
