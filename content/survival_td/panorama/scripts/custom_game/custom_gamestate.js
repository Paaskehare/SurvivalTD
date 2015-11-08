"use strict";
var g_GameState = g_GameState || {};

function OnGamestateNettableChanged(table_name, key, data) {
	if (key == "lives") {
		g_GameState.Lives = data;
	} else if (key == "difficulty") {
		g_GameState.Difficulty = data;
	} else if (key == "teamstate") {
		g_GameState.TeamState = data;
	}
}

(function() {
    g_GameState.Towers   = g_GameState.Towers   || CustomNetTables.GetTableValue( "game_state", "towers" );
    g_GameState.Settings = g_GameState.Settings || CustomNetTables.GetTableValue( "game_state", "settings" );
    g_GameState.Lives    = g_GameState.Lives    || CustomNetTables.GetTableValue( "game_state", "lives");
    g_GameState.Difficulty = g_GameState.Difficulty || CustomNetTables.GetTableValue( "game_state", "difficulty" );
    g_GameState.TeamState  = g_GameState.TeamState  || CustomNetTables.GetTableValue( "game_state", "teamstate" );

    CustomNetTables.SubscribeNetTableListener( "game_state", OnGamestateNettableChanged );
})();