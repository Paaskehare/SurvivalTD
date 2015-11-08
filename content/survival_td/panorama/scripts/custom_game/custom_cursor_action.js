"use strict";

var drawContainer = null
  , active = false
  , player = null
  , particle = null
  , rangeParticle = null
  , unitSize = 128
  , unitSizeHalf = unitSize >> 1
  ;

function SnapToGrid64(coord){
  return 64*Math.floor(0.5+coord/64);
}

function SnapToGrid32(coord){
  return 32+64*Math.floor(coord/64);
}

function GhostParticleTicker() {
  if (active) $.Schedule(0.01, GhostParticleTicker); 

  var mPos = GameUI.GetCursorPosition();
  var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);

  GamePos[0] = SnapToGrid32(GamePos[0]);
  GamePos[1] = SnapToGrid32(GamePos[1]);
  GamePos[2] = GamePos[2] + 1; // #JustValveThings

  if (GamePos[0] > 10000000) // fix for borderless windowed players
  {
    GamePos = [0,0,0];
  }

  if (particle !== null) {
    Particles.SetParticleControl(particle, 0, GamePos); 
    //Particles.SetParticleControl(particle, 2, [0,255,0]);           /* color */
  }

  if (rangeParticle !== null) {
    Particles.SetParticleControl(rangeParticle, 0, GamePos);
    /*Particles.SetParticleControl(rangeParticle, 1, [300,0,0]); */
  }
}

function GhostParticleStart(params) {
  //var entIndex = params.entIndex;
  //var MaxScale = params.MaxScale;
  var AttackRange = params.AttackRange;

  player = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
  active = true;

  if (particle !== null) { Particles.DestroyParticleEffect(particle, true); }
  if (rangeParticle !== null) { Particles.DestroyParticleEffect(rangeParticle, true); }

  drawContainer.hittest = true;
  /*drawContainer.SetAcceptsFocus(true);
  drawContainer.SetFocus();*/

  particle = Particles.CreateParticle("particles/ui_mouseactions/square_sprite.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, player);
  //Particles.SetParticleControlEnt(particle, 1, entIndex, ParticleAttachment_t.PATTACH_ABSORIGIN_FOLLOW, "follow_origin", Entities.GetAbsOrigin(entIndex), true);
  Particles.SetParticleControl(particle, 1, [unitSizeHalf,0,0]);
  Particles.SetParticleControl(particle, 2, [0,255,0]);           /* color */
  Particles.SetParticleControl(particle, 3, [100,0,0]);           /* alpha */

  /*rangeParticle = Particles.CreateParticle("particles/ui_mouseactions/radius_indicator_sprite.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, player);*/
  if (AttackRange > 0) {
    rangeParticle = Particles.CreateParticle("particles/ui_mouseactions/radius_indicator_sprite.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, player);
    /*rangeParticle = Particles.CreateParticle("particles/ui_mouseactions/range_display.vpcf", ParticleAttachment_t.PATTACH_ABSORIGIN, player);*/
    Particles.SetParticleControl(rangeParticle, 1, [AttackRange,0,0]);      /* range / thickness / speed */
  }

  GhostParticleTicker(); 
}

function GhostParticleEnd(params) {
  active = false;

  if (particle !== null) {
    Particles.DestroyParticleEffect(particle, true);
    particle = null;
  }

  if (rangeParticle !== null) {
    Particles.DestroyParticleEffect(rangeParticle, true);
    rangeParticle = null;
  }

  drawContainer.hittest = false;
  /*drawContainer.SetAcceptsFocus(false);*/
}

function LeftMouseClicked() {
  var mPos = GameUI.GetCursorPosition();
  var GamePos = Game.ScreenXYToWorld(mPos[0], mPos[1]);

  /*var Hero = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
  var Ability = Entities.GetAbilityByName(Hero, 'build_tower');

  Abilities.ExecuteAbility(Ability, Hero, false);*/

  if (GamePos[0] > 10000000) { return; }

  GameEvents.SendCustomGameEventToServer('build_tower_cast', {position: GamePos}); 

  if (!GameUI.IsShiftDown()) {
    GhostParticleEnd();
  }
}

function RightMouseClicked() {
  GhostParticleEnd();
  GameEvents.SendCustomGameEventToServer('build_tower_cancel', {});
}

function ESCPressed() {
  GhostParticleEnd();
  GameEvents.SendCustomGameEventToServer('build_tower_cancel', {}); 
}

(function() {
    drawContainer = $.GetContextPanel();

    GameEvents.Subscribe( 'build_tower_ghost_enable',  GhostParticleStart );
    GameEvents.Subscribe( 'build_tower_ghost_disable', GhostParticleEnd   );
})();