"use strict";
function NotificationPrompt(event) {
    var msg = event.message || '';

    var BottomNotifications = $('#BottomNotifications');

    var Message = $.CreatePanel('Label', BottomNotifications, '');

    Message.SetHasClass('NotificationMessage', true);
    Message.hittest = false;
    Message.text = $.Localize(msg);

    Message.DeleteAsync(1.5);
}

function NextRoundPrompt(params) {
	var RoundNumber = params.RoundNumber
	  , TotalRounds = params.TotalRounds;

	var CurrentWaveName = 'creep_wave_' + RoundNumber;
	var NextWaveName    = 'creep_wave_' + (RoundNumber + 1);

	var LeftNotifications = $('#LeftNotifications');

	var Message = $.CreatePanel('Label', LeftNotifications, '');

	Message.SetHasClass('NotificationMessage', true);
	Message.hittest = false;
	Message.text = 'blabhablasd';
}

/* initialization */
(function() {
    GameEvents.Subscribe('custom_error_message', NotificationPrompt)
})();