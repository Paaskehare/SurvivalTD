"use strict";
var NotificationMessage, NotificationPrompt, PlayerChat, PushNotification, WaveNotification;

NotificationPrompt = function(event) {
  var BottomNotifications, Message, msg;
  msg = event.message || '';
  BottomNotifications = $('#BottomNotifications');
  Message = PushNotification(BottomNotifications, $.Localize(msg));
  return Message.DeleteAsync(1.5);
};

PushNotification = function(panel, text) {
  var Message;
  Message = $.CreatePanel('Label', panel, '');
  Message.SetHasClass('NotificationMessage', true);
  Message.hittest = false;
  Message.text = text;
  return Message;
};

PlayerChat = function(event) {
  var LeftNotifications, Message, Timeout, getWaveNumbers, msg, text, waves;
  text = event.text || '';
  LeftNotifications = $('#LeftNotifications');
  Timeout = 10;
  getWaveNumbers = function(list) {
    var k, wave;
    return ((function() {
      var results;
      results = [];
      for (k in list) {
        wave = list[k];
        results.push(wave.slice('creep_wave_'.length));
      }
      return results;
    })()).sort(function(a, b) {
      return a - b;
    });
  };
  if (text === '-air') {
    waves = getWaveNumbers(g_GameState.Settings.FlyingWaves);
    msg = $.Localize('custom_game_flying_waves') + ' ' + waves.join(' / ');
    Message = PushNotification(LeftNotifications, msg);
    return Message.DeleteAsync(Timeout);
  } else if (text === '-boss') {
    waves = getWaveNumbers(g_GameState.Settings.BossWaves);
    msg = $.Localize('custom_game_boss_waves') + ' ' + waves.join(' / ');
    Message = PushNotification(LeftNotifications, msg);
    return Message.DeleteAsync(Timeout);
  }
};

NotificationMessage = function(event) {
  var LeftNotifications, Message, Timeout, msg;
  msg = event.message || '';
  LeftNotifications = $('#LeftNotifications');
  Timeout = 10;
  msg = $.Localize(msg);
  Message = PushNotification(LeftNotifications, msg);
  return Message.DeleteAsync(Timeout);
};

WaveNotification = function(event) {
  var Message, Timeout, TopNotifications, msg, round, unit_name;
  round = event.Round;
  unit_name = event.UnitName;
  TopNotifications = $('#TopNotifications');
  Timeout = 5;
  msg = $.Localize('Round') + ' ' + round + ': ' + $.Localize(unit_name);
  Message = PushNotification(TopNotifications, msg);
  return Message.DeleteAsync(Timeout);
};

(function() {
  GameEvents.Subscribe('wave_notification', WaveNotification);
  GameEvents.Subscribe('custom_error_message', NotificationPrompt);
  GameEvents.Subscribe('player_chat', PlayerChat);
  return GameEvents.Subscribe('team_notification', NotificationMessage);
})();
