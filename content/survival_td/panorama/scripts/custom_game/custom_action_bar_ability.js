"use strict";

/* workaround to show ability icons for abilities with custom icons */
var CustomAbilityRoot = 'file://{images}/custom_game/spellicons/';
var CustomAbilities = [
	'build_tower'
];

var CostAbilities = [
	'upgrade_tower',
	'upgrade_tier'
];

var Ability = -1;
var Unit    = -1;

String.prototype.StartsWith = function(string) {
	return (this.substr(0, string.length) == string);
};

function isCustomAbility(abilityName)
{
	for (var ability of CustomAbilities) {
		if (ability == abilityName) return true;
	}

	return false;
}

function isCostAbility(abilityName)
{
	for (var ability of CostAbilities) {
		if (abilityName.StartsWith(ability)) return true;
	}

	return false;
}

function UpdateAbility()
{
	var $ContextPanel = $.GetContextPanel();

	if ( Unit == -1 || Ability == -1 || Abilities.IsHidden(Ability) || Abilities.GetAbilityType(Ability) == ABILITY_TYPES.ABILITY_TYPE_ATTRIBUTES || Abilities.GetAbilityName(Ability) == 'build_tower' )
	{
		$ContextPanel.visible = false;
		$.Schedule( 0.1, UpdateAbility );
		return;
	} else {
		$ContextPanel.visible = true;
	}

	var ability = Ability;
	var queryUnit = Unit;
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( ability );

	var noLevel =( 0 == Abilities.GetLevel(ability) );
	var isCastable = !Abilities.IsPassive(ability) && !noLevel;
	var manaCost = Abilities.GetManaCost( ability );
	var hotkey = Abilities.GetKeybind( ability, queryUnit );
	var unitMana = Entities.GetMana( queryUnit );
	var CostAbility = isCostAbility(abilityName);

	$ContextPanel.SetHasClass( "no_level", noLevel );
	$ContextPanel.SetHasClass( "is_passive", Abilities.IsPassive(ability) );
	$ContextPanel.SetHasClass( "no_mana_cost", ( manaCost == 0 ) );
	$ContextPanel.SetHasClass( "insufficient_mana", ( manaCost > unitMana ) );
	$ContextPanel.SetHasClass( "auto_cast_enabled", Abilities.GetAutoCastState(ability) );
	$ContextPanel.SetHasClass( "toggle_active", Abilities.GetToggleState(ability) );
	$ContextPanel.SetHasClass( "no_gold_cost", !CostAbility);

	abilityButton.enabled = isCastable;
	
	//$( "#HotkeyText" ).text = hotkey;
	$( "#AbilityImage" ).abilityname = abilityName;
	$( "#AbilityImage" ).contextEntityIndex = queryUnit;

	if (isCustomAbility(abilityName)) {
		var AbilityImageLocation = CustomAbilityRoot + Abilities.GetAbilityTextureName(ability) + '.png';
		$("#AbilityImage").SetImage(AbilityImageLocation);
	}

	if (CostAbility) {
		if (abilityName.StartsWith('upgrade_tower')) {
			var UnitName = Entities.GetUnitName(queryUnit);
			var UpgradedUnitName = '';

			if (UnitName.match(/_level_[0-9]$/)) {
				var UnitLevel = parseInt(UnitName.substr(-1));
				UpgradedUnitName = UnitName.substr(0, UnitName.length - 1) + (UnitLevel + 1);
			} else {
				UpgradedUnitName = UnitName + '_level_2';
			}
			var UpgradedUnit = g_GameState.Towers[UpgradedUnitName];

			if (UpgradedUnit !== null) {
				$( "#GoldCost" ).text = UpgradedUnit.GoldCost;
			}
		} else if (abilityName == 'upgrade_tier') {
			var tierUpgradeCost = g_GameState.Settings.TierCosts[Abilities.GetLevel(ability)];

			if (tierUpgradeCost > 0)
				$( "#GoldCost" ).text = tierUpgradeCost;
		}
	}

	$( "#ManaCost" ).text = manaCost;
	
	if ( Abilities.IsCooldownReady( ability ) )
	{
		$ContextPanel.SetHasClass( "cooldown_ready", true );
		$ContextPanel.SetHasClass( "in_cooldown", false );
	}
	else
	{
		$ContextPanel.SetHasClass( "cooldown_ready", false );
		$ContextPanel.SetHasClass( "in_cooldown", true );
		var cooldownLength = Abilities.GetCooldownLength( ability );
		var cooldownRemaining = Abilities.GetCooldownTimeRemaining( ability );
		var cooldownPercent = Math.ceil( 100 * cooldownRemaining / cooldownLength );
		$( "#CooldownTimer" ).text = Math.ceil( cooldownRemaining );
		$( "#CooldownOverlay" ).style.width = cooldownPercent+"%";
	}
	
	$.Schedule( 0.1, UpdateAbility );
}

function AbilityShowTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	var abilityName = Abilities.GetAbilityName( Ability );
	// If you don't have an entity, you can still show a tooltip that doesn't account for the entity
	//$.DispatchEvent( "DOTAShowAbilityTooltip", abilityButton, abilityName );
	
	// If you have an entity index, this will let the tooltip show the correct level / upgrade information
	$.DispatchEvent( "DOTAShowAbilityTooltipForEntityIndex", abilityButton, abilityName, Unit );
}

function AbilityHideTooltip()
{
	var abilityButton = $( "#AbilityButton" );
	$.DispatchEvent( "DOTAHideAbilityTooltip", abilityButton );
}

function ActivateAbility()
{
	var abilityName = Abilities.GetAbilityName(Ability);

	Abilities.ExecuteAbility( Ability, Unit, false );
}

function DoubleClickAbility()
{
	Abilities.CreateDoubleTapCastOrder( Ability, Unit );
}

function RightClickAbility()
{
	if ( Abilities.IsAutocast(Ability) )
	{
		Game.PrepareUnitOrders( { OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO, AbilityIndex: Ability, UnitIndex: Unit } );
	}
}

function SetData(queryUnit, queryAbility)
{
	Unit = queryUnit;
	Ability = queryAbility;
}

(function()
{
	$.GetContextPanel().data().SetData = SetData;
	UpdateAbility(); // initial update of dynamic state
})();


