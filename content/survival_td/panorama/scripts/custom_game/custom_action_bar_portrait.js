"use strict";

function SelectUnit() {
	var Unit = $.GetContextPanel().GetAttributeInt( 'queryUnit', -1 );

	GameUI.SelectUnit(Unit, false);
}

(function(){
	var UnitPortraitImage = $('#UnitPortraitImage');

	var Unit = $.GetContextPanel().GetAttributeInt( 'queryUnit', -1 );

	var UnitName = Entities.GetUnitName(Unit);
  var UnitNameLocalized = $.Localize(UnitName);

  var PortraitImageSrc = 'file://{resources}/images/custom_game/towers/default.png';

  if (UnitName.startswith('tower_')) {
    PortraitImageSrc = 'file://{resources}/images/custom_game/towers/' + UnitName + '.png';
  } else if (Entities.IsHero(Unit)) {
    PortraitImageSrc = 'file://{images}/heroes/' + UnitName + '.png';
  }

  UnitPortraitImage.SetImage(PortraitImageSrc);
})();