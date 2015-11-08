"use strict";
var NextRoundTime = 0;
var CurrentRound  = 1;
var RoundTime     = 1;
var WavePrefix    = 'creep_wave_'; 
var GameSettings;

var humanTime = function(time) {
    time = Math.floor(time);
    var minutes = Math.floor(time / 60);
    var seconds = time - (minutes * 60);

    if (seconds < 10)
        seconds = '0' + seconds;

    return minutes + ':' + seconds;
};

function IsFlyingWave(waveName) {
    $.Each(GameSettings.FlyingWaves, function(value) {
        if (value == waveName) return true;
    });

    return false;
}

function IsBossWave(waveName) {
    $.Each(GameSettings.BossWaves, function(value) {
        if (value == waveName) return true;
    });

    return false
}

function UpdateRoundTimer() {
    var GameTime = Game.GetGameTime();
    var TimeLeft = NextRoundTime > GameTime ? NextRoundTime - GameTime : 0;
    var NextRoundPercent = TimeLeft > 0 ? Math.floor((TimeLeft / RoundTime) * 10000) / 100 : 0;
    var CurrentRoundName = WavePrefix + CurrentRound;

    var IsFlying = IsFlyingWave(CurrentRoundName);
    var IsBoss   = IsBossWave(CurrentRoundName);

    $('#RoundTimerRoundText').text = 'Round: ' + CurrentRound;
    $('#RoundTimerCountDownText').text = humanTime(TimeLeft);
    $('#RoundTimerBarPercentage').style.width = NextRoundPercent + '%';

    $('#RoundTimerRoundName').text = $.Localize(CurrentRoundName);

    var RoundTypeLabel = $('#RoundTimerRoundType');

    RoundTypeLabel.SetHasClass('flying', IsFlying);
    RoundTypeLabel.SetHasClass('boss',   IsBoss);
    RoundTypeLabel.text = IsFlying ? 'Flying' : IsBoss ? 'Boss' : '';

    $.Schedule(0.5, UpdateRoundTimer);
}

function NextRoundEvent(event) {
    NextRoundTime = event.time;
    CurrentRound  = event.round;
    RoundTime     = event.roundtime;

    $.Msg(RoundTime);
}

/* Initialization */
(function() {
    GameEvents.Subscribe( "next_round_timer", NextRoundEvent);

    GameSettings = g_GameState.Settings;

    UpdateRoundTimer();
})();