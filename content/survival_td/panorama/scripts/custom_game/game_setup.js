var Difficulties = {
    easy: 0,
    normal: 1,
    hard: 2
};

function DifficultyChanged(value)
{
    if (!Game.GameStateIs(DOTA_GameState.DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP))
        return;

    if (value === Difficulties.easy || value === Difficulties.normal || value === Difficulties.hard)
    {
        GameEvents.SendCustomGameEventToServer('player_changed_difficulty', {difficulty: value});

        var HealthPercentage = (10 * value) + 100;

        $('#GameSetupSubLabel').text = $.Localize('custom_game_creep_health') + ' ' + HealthPercentage + '%';
    }
}

(function() {
    /* make sure easy mode is selected */
    /*$('#GameSetupDifficultyEasy').SetAttributeString('checked', 'checked');*/
    $('#GameSetupSubLabel').text = $.Localize('custom_game_creep_health') + ' 100%';

})();