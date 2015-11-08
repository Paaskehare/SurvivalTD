"use strict";

NotificationPrompt = (event) ->
	msg = event.message or ''

	BottomNotifications = $ '#BottomNotifications'

	Message = PushNotification BottomNotifications, $.Localize msg
	Message.DeleteAsync 1.5

PushNotification = (panel, text) ->
	Message = $.CreatePanel 'Label', panel, ''

	Message.SetHasClass 'NotificationMessage', true
	Message.hittest = false
	Message.text = text

	Message

PlayerChat = (event) ->
	text = event.text or ''

	LeftNotifications = $ '#LeftNotifications'
	Timeout = 10

	getWaveNumbers = (list) ->
		(wave['creep_wave_'.length ..] for k, wave of list).sort (a, b) ->
			a - b

	if text is '-air'
		waves = getWaveNumbers g_GameState.Settings.FlyingWaves
		msg = $.Localize('custom_game_flying_waves') + ' ' + waves.join ' / '

		Message = PushNotification LeftNotifications, msg
		Message.DeleteAsync Timeout

	else if text is '-boss'
		waves = getWaveNumbers g_GameState.Settings.BossWaves
		msg = $.Localize('custom_game_boss_waves') + ' ' + waves.join ' / '

		Message = PushNotification LeftNotifications, msg
		Message.DeleteAsync Timeout

NotificationMessage = (event) ->
	msg = event.message or ''

	LeftNotifications = $ '#LeftNotifications'
	Timeout = 10

	msg = $.Localize msg

	Message = PushNotification LeftNotifications, msg
	Message.DeleteAsync Timeout

WaveNotification = (event) ->
	round = event.Round
	unit_name = event.UnitName

	TopNotifications = $ '#TopNotifications'
	Timeout = 5

	msg = $.Localize('Round') + ' ' + round + ': ' + $.Localize(unit_name)

	Message = PushNotification TopNotifications, msg
	Message.DeleteAsync Timeout

# initialization
do () ->
	GameEvents.Subscribe 'wave_notification',    WaveNotification
	GameEvents.Subscribe 'custom_error_message', NotificationPrompt
	GameEvents.Subscribe 'player_chat',          PlayerChat
	GameEvents.Subscribe 'team_notification',    NotificationMessage