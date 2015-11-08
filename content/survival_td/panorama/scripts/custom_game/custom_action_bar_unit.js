"use strict";

var Elements = {};
var Unit = -1;

function UpdateUnitUI() {

    if (Unit === -1) return;

    var DamageMin = Entities.GetDamageMin(Unit)
      , DamageMax = Entities.GetDamageMax(Unit)
      , Range  = Entities.GetAttackRange(Unit)
      , MoveSpeed = Entities.GetBaseMoveSpeed(Unit)
      , Health = Entities.GetHealth(Unit)
      , MaxHealth = Entities.GetMaxHealth(Unit)
      , Armor = Entities.GetArmorForDamageType(Unit, DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL)

      , canAttack = Entities.HasAttackCapability(Unit)
      , canMove   = Entities.HasMovementCapability(Unit)

      , HealthPercentage = Entities.GetHealthPercent(Unit)
      ;

    Elements.HealthBarPercentage.SetHasClass('unfriendly', Entities.IsEnemy(Unit));

    Elements.HealthBarPercentage.style.width = HealthPercentage + '%';
    Elements.HealthBarLabel.text = Health + ' / ' + MaxHealth;

    Elements.AttributeDamage.text = canAttack ? (DamageMin === DamageMax ? DamageMin : (DamageMin + ' - ' + DamageMax) ) : '-';
    Elements.AttributeRange.text = canAttack ? Range : '-';
    Elements.AttributeMoveSpeed.text = canMove ? MoveSpeed : '-';
    Elements.AttributeArmor.text = Armor;

    UpdateAbilityUI();

    $.Schedule(0.1, UpdateUnitUI);
}

function UpdateAbilityUI()
{
  Elements.AbilityPanel.data().SetUnit(Unit);
}

function MakeAbilityUI() {
    //var Unit = $.GetContextPanel().GetAttributeInt( 'queryUnit', -1 );

    Elements.AbilityPanel.RemoveAndDeleteChildren();
    //Elements.AbilityPanel.SetAttributeInt( 'queryUnit', Unit );
    Elements.AbilityPanel.BLoadLayout( 'file://{resources}/layout/custom_game/custom_action_bar_abilities.xml', false, false );
}

function SetUnit(queryUnit) {
  Unit = queryUnit;
  UpdateUnitUI();
  UpdateAbilityUI();
}

/*function UpdateAbilityUI() {
  Elements.AbilityPanel.data().setUnit()
}*/

(function(){
    $.GetContextPanel().data().SetUnit = SetUnit;

    Elements = {
        HealthBarPercentage: $('#UnitHealthBarPercentage'),
        HealthBarLabel: $('#UnitHealthBarLabel'),
        AttributeRange: $('#UnitAttributeRange'),
        AttributeDamage: $('#UnitAttributeDamage'),
        AttributeMoveSpeed: $('#UnitAttributeMoveSpeed'),
        AttributeArmor: $('#UnitAttributeArmor'),
        AbilityPanel: $('#UnitAbilities')
    };

    //GameEvents.Subscribe( "dota_ability_changed", RebuildAbilityUI );

    UpdateUnitUI();
    MakeAbilityUI();
    //UpdateAbility(); // initial update of dynamic state
})();
